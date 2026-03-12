# Arquitetura — vps-lab

## Diagrama de infraestrutura

```mermaid
graph TB
    Internet((Internet))

    subgraph VPS["VPS — Ubuntu 24.04 (Bork Cloud)"]
        UFW[UFW Firewall<br/>80, 443, 22]
        
        subgraph Docker["Docker Engine"]
            Traefik[Traefik<br/>Reverse Proxy + SSL]
            Coolify[Coolify<br/>PaaS UI]
            
            subgraph Apps["Aplicações"]
                Astro[Site Astro<br/>site.vpslab.dev]
                Blog[Blog Astro<br/>blog.vpslab.dev]
                API[API Node.js<br/>api.vpslab.dev]
                Uptime[Uptime Kuma<br/>status.vpslab.dev]
                Grafana[Grafana<br/>grafana.vpslab.dev]
            end
            
            subgraph Data["Dados"]
                PG[(PostgreSQL<br/>rede interna)]
                Loki[Loki<br/>logs]
                Prometheus[Prometheus<br/>métricas]
            end
        end
        
        SSH[SSH<br/>porta 22<br/>usuário deploy]
    end

    Internet --> UFW
    UFW --> Traefik
    UFW --> SSH
    
    Traefik --> Coolify
    Traefik --> Astro
    Traefik --> Blog
    Traefik --> API
    Traefik --> Uptime
    Traefik --> Grafana
    
    API --> PG
    Grafana --> Loki
    Grafana --> Prometheus
    
    Coolify -.->|gerencia| Docker

    style VPS fill:#1a1a2e,stroke:#6C47FF,color:#fff
    style Docker fill:#0d1117,stroke:#2496ED,color:#fff
    style Apps fill:#0d1117,stroke:#28a745,color:#fff
    style Data fill:#0d1117,stroke:#E95420,color:#fff
```

## Princípios de isolamento

- **Rede do banco de dados:** PostgreSQL exposto apenas na rede interna Docker. Nenhuma porta pública.
- **Acesso SSH:** Somente usuário `deploy` com chave Ed25519. Root bloqueado.
- **SSL:** Let's Encrypt automático via Traefik para todos os domínios.
- **Firewall:** Apenas portas 22, 80 e 443 abertas externamente.

## Fluxo de deploy

```
Push no GitHub
      │
      ▼
Coolify detecta via webhook
      │
      ▼
Build da imagem Docker
      │
      ▼
Deploy do container
      │
      ▼
Traefik roteia o domínio automaticamente
      │
      ▼
SSL emitido/renovado automaticamente
```
