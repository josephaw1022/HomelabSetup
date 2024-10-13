// Global variable to hold YAML content
let yamlContent = '';

// Function to handle file input change
document.getElementById('fileInput').addEventListener('change', function (event) {
    const file = event.target.files[0];

    if (!file) {
        alert('No file selected.');
        return;
    }

    const reader = new FileReader();
    reader.onload = function (e) {
        const content = e.target.result;
        const yamlMatch = content.match(/"kubeconfig_content\.stdout":\s*"([^"]+)"/);

        if (yamlMatch) {
            // Clean up escaped newline characters and backslashes, then store YAML content
            yamlContent = yamlMatch[1].replace(/\\n/g, '\n').replace(/\\/g, '');

            // Get cluster name and IP from user inputs
            const clusterName = document.getElementById('clusterName').value || 'default';
            const clusterIp = document.getElementById('clusterIp').value || '127.0.0.1';

            // Replace server IP, cluster name, context name, and current-context in YAML content
            yamlContent = yamlContent
                .replace(/server: https:\/\/127\.0\.0\.1:6443/g, `server: https://${clusterIp}:6443`)
                .replace(/(clusters:\s*-\s*cluster:\s*[\s\S]*?name:\s*)default/g, `$1${clusterName}`)
                .replace(/(contexts:\s*-\s*context:\s*[\s\S]*?cluster:\s*)default/g, `$1${clusterName}`)
                .replace(/(contexts:\s*-\s*context:\s*[\s\S]*?name:\s*)default/g, `$1${clusterName}`)
                .replace(/current-context: default/g, `current-context: ${clusterName}`);

            // Display the modified YAML content
            document.getElementById('yamlOutput').textContent = yamlContent;
        } else {
            alert('YAML content not found in file.');
        }
    };
    reader.readAsText(file);
});

// Function to download YAML content as a file
function downloadYaml() {
    if (!yamlContent) {
        alert('No YAML content to download.');
        return;
    }

    const blob = new Blob([yamlContent], { type: 'text/yaml' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'kubeconfig.yaml';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
}

// Function to copy YAML content to clipboard
function copyToClipboard() {
    if (!yamlContent) {
        alert('No YAML content to copy.');
        return;
    }

    navigator.clipboard.writeText(yamlContent)
        .then(() => alert('YAML content copied to clipboard.'))
        .catch(err => alert('Failed to copy to clipboard.'));
}
