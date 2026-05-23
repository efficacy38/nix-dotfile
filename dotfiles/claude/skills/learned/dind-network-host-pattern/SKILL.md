---
name: dind-network-host-pattern
description: Docker-in-Docker with network_mode host for multi-node simulation
tags: [docker, dind, testing, infrastructure]
---

# DinD with network_mode: host for Multi-Node Simulation

## Pattern

When simulating a multi-node deployment with Docker-in-Docker, use `network_mode: host` inside the DinD containers. This makes inner containers bind to the DinD container's network namespace, preserving the outer network's IP addressing.

## Architecture

```
Outer docker-compose (host)
├── service-a DinD container → fixed IP 10.0.0.2
│   └── inner container (network_mode: host) → binds to 10.0.0.2
├── service-b DinD container → fixed IP 10.0.0.3
│   └── inner container (network_mode: host) → binds to 10.0.0.3
```

## Key Benefits

- Existing configs with hardcoded IPs work unchanged
- True network isolation between nodes (each has its own docker daemon)
- Inner services are reachable via the DinD container's IP on the outer network

## Image Distribution

Build on host, save to per-node cache directories, load inside DinD:

```bash
# Host: save image
docker save myimage:latest | gzip > image-cache/node-a/myimage.tar.gz

# DinD entrypoint: load image
for img in /image-cache/*.tar.gz; do
    gunzip -c "$img" | docker load
done
```

## Script Interaction

Use nested exec (outer → inner) to interact with inner containers:

```bash
# Exec into inner container via outer DinD
docker compose exec -T dind-node-a \
    docker compose -f /compose/docker-compose.yml exec -T service-a <command>
```

## YAML Anchor for DinD Boilerplate

```yaml
x-dind-common: &dind-common
  image: docker:dind
  privileged: true
  environment:
    DOCKER_TLS_CERTDIR: ""
  entrypoint: ["/compose/entrypoint.sh"]
  restart: unless-stopped

services:
  dind-node-a:
    <<: *dind-common
    volumes: [...]
    networks:
      net:
        ipv4_address: 10.0.0.2
```

## Gotchas

- `docker:dind` requires `privileged: true`
- Set `DOCKER_TLS_CERTDIR=""` to disable TLS (simplifies test environments)
- DNS: add a CoreDNS container if services need FQDN resolution
- Don't mount host docker socket — it bypasses DinD isolation entirely
- Image save/load is slow; cache tarballs and skip if already present
