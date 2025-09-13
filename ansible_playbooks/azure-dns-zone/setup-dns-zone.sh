#!/usr/bin/env bash
set -euo pipefail

# === Config ===
RESOURCE_GROUP="${RESOURCE_GROUP:-kubesoar-dns-rg}"
LOCATION="${LOCATION:-eastus}"
SUBDOMAIN="${SUBDOMAIN:-kubesoar.com}"



# === Parse flags ===
TEARDOWN=false
for arg in "$@"; do
  [[ "$arg" == "--teardown" ]] && TEARDOWN=true
done

# === Teardown path ===
if $TEARDOWN; then
  echo "Teardown requested."

  # Delete DNS zone first (so RG delete won’t hang on dependencies)
  if az network dns zone show --name "$SUBDOMAIN" --resource-group "$RESOURCE_GROUP" >/dev/null 2>&1; then
    echo "Deleting DNS zone: $SUBDOMAIN (rg: $RESOURCE_GROUP)"
    az network dns zone delete --name "$SUBDOMAIN" --resource-group "$RESOURCE_GROUP" --yes >/dev/null
  else
    echo "DNS zone $SUBDOMAIN not found (nothing to delete)."
  fi

  # Delete RG
  if az group show --name "$RESOURCE_GROUP" >/dev/null 2>&1; then
    echo "Deleting resource group: $RESOURCE_GROUP"
    az group delete --name "$RESOURCE_GROUP" --yes --no-wait
  else
    echo "Resource group $RESOURCE_GROUP not found (nothing to delete)."
  fi

  echo "Teardown initiated."
  exit 0
fi

# === Create path ===
# Ensure login
az account show >/dev/null 2>&1 || { echo "Please run: az login"; exit 1; }

# Ensure RG
if ! az group exists --name "$RESOURCE_GROUP" | grep -q true; then
  echo "Creating resource group: $RESOURCE_GROUP ($LOCATION)"
  az group create --name "$RESOURCE_GROUP" --location "$LOCATION" >/dev/null
else
  echo "Resource group $RESOURCE_GROUP already exists"
fi

# Ensure DNS zone
if ! az network dns zone show --name "$SUBDOMAIN" --resource-group "$RESOURCE_GROUP" >/dev/null 2>&1; then
  echo "Creating DNS zone: $SUBDOMAIN"
  az network dns zone create --name "$SUBDOMAIN" --resource-group "$RESOURCE_GROUP" >/dev/null
else
  echo "DNS zone $SUBDOMAIN already exists"
fi

# Print Azure NS to add in Hostinger parent (kubesoar.com)
echo "Fetching Azure name servers for $SUBDOMAIN..."
mapfile -t NS < <(az network dns zone show -g "$RESOURCE_GROUP" -n "$SUBDOMAIN" --query nameServers -o tsv)
echo
echo "=== Add this delegation in Hostinger (parent: kubesoar.com) ==="
echo "Host/Name: $(echo "$SUBDOMAIN" | sed 's/\.kubesoar\.com$//')"
echo "Type:      NS"
echo "TTL:       3600"
echo "Values:"
for s in "${NS[@]}"; do
  echo "  - ${s%.}"   # strip trailing dot if present
done
echo "=============================================================="
echo "Verify with:  nslookup -type=ns $SUBDOMAIN   or   dig NS $SUBDOMAIN"



# === Delegate aws.kubesoar.com to AWS Route53 ===
DELEGATED_SUBDOMAIN="aws"
DELEGATED_ZONE="kubesoar.com"   # parent zone in Azure DNS
AWS_NS=(
  "ns-329.awsdns-41.com."
  "ns-1529.awsdns-63.org."
  "ns-1771.awsdns-29.co.uk."
  "ns-976.awsdns-58.net."
)

echo ">> Ensuring NS record for aws.${DELEGATED_ZONE} pointing to AWS Route53..."

# Check if record set already exists
if ! az network dns record-set ns show \
      --resource-group "$RESOURCE_GROUP" \
      --zone-name "$DELEGATED_ZONE" \
      --name "$DELEGATED_SUBDOMAIN" >/dev/null 2>&1; then
  echo "Creating NS record set for aws.${DELEGATED_ZONE}"
  az network dns record-set ns create \
    --resource-group "$RESOURCE_GROUP" \
    --zone-name "$DELEGATED_ZONE" \
    --name "$DELEGATED_SUBDOMAIN" \
    --ttl 3600 >/dev/null
fi

# Add each NS if missing
for ns in "${AWS_NS[@]}"; do
  if ! az network dns record-set ns show \
        --resource-group "$RESOURCE_GROUP" \
        --zone-name "$DELEGATED_ZONE" \
        --name "$DELEGATED_SUBDOMAIN" \
        --query "nsRecords[?nsdname=='$ns']" -o tsv | grep -q "$ns"; then
    echo "Adding NS $ns to aws.${DELEGATED_ZONE}"
    az network dns record-set ns add-record \
      --resource-group "$RESOURCE_GROUP" \
      --zone-name "$DELEGATED_ZONE" \
      --record-set-name "$DELEGATED_SUBDOMAIN" \
      --nsdname "$ns" >/dev/null
  fi
done
