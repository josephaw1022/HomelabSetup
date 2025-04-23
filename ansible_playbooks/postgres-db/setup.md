run this on laptop server 

```bash

podman run -d \
  --name postgres17 \
  --restart=always \
  --volume pgdata17:/var/lib/postgresql/data \
  --network host \
  -e POSTGRES_PASSWORD=password \
  postgres:17.4
```


