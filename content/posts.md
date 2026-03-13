# Posts da Série vps-lab

---

## EP01 — LinkedIn

---

Adquiri uma VPS. Primeira coisa que fiz: não instalei nada.

Passei 2 horas fazendo segurança.

Por quê? Porque 3 minutos após provisionar o servidor, já tinham tentativas de login no log:

```
sshd: Invalid user admin from 185.220.101.x
sshd: Invalid user root from 45.33.32.x
sshd: Invalid user ubuntu from 193.32.126.x
```

O servidor nem tinha nada rodando ainda.

Aqui o que configurei antes de instalar qualquer coisa:

→ 1. Criei usuário não-root com sudo (adiós, root no dia a dia)
→ 2. Gerei par de chaves SSH Ed25519 e subi a pública no servidor
→ 3. Desabilitei login root via SSH e login por senha — só entra com chave
→ 4. UFW: permite apenas SSH (22), HTTP (80) e HTTPS (443)
→ 5. fail2ban: 3 tentativas erradas = ban de 24 horas
→ 6. unattended-upgrades: patches de segurança automáticos

Uma distinção importante que muita gente confunde:

Desabilitar root no SSH ≠ deletar o root.

O usuário root continua existindo. Ele só não tem porta de entrada via SSH.
Qualquer ataque de força bruta em root recebe negação na camada do protocolo,
antes de chegar a testar qualquer credencial.

Script completo, idempotente, comentado e open source:
👇 github.com/felipebossolani/vps-lab/tree/main/01-security

Próximo episódio: instalação do Coolify — self-hosted PaaS que vai substituir
minha conta no Railway.

#devops #selfhosted #linux #segurança #opensource

---

## EP01 — Twitter/X Thread

---

Tweet 1:
Provisionei uma VPS nova. 3 minutos depois já tinha isso no log:

"Invalid user root from 185.220.x.x"
"Invalid user admin from 45.33.x.x"

Nem tinha instalado nada ainda. 🧵

Tweet 2:
Antes de rodar qualquer coisa, fiz o hardening completo:

→ Usuário não-root com sudo
→ SSH só por chave Ed25519 (sem senha)
→ Root bloqueado no SSH
→ UFW com regras mínimas
→ fail2ban (3 tentativas = ban 24h)
→ Patches de segurança automáticos

Tweet 3:
Ponto que confunde muita gente:

PermitRootLogin no ≠ deletar o root

O root existe. Só não tem porta SSH aberta.
Ataque de força bruta em root = negado antes de testar credencial.

Tweet 4:
O script faz tudo em sequência, é idempotente e tem output colorido:

✓ Sistema atualizado
✓ Usuário deploy criado
✓ Chave SSH configurada
✓ SSH endurecido
✓ UFW ativo
✓ fail2ban ativo
✓ Auto-updates ativos

Tweet 5:
Script completo no GitHub 👇
github.com/felipebossolani/vps-lab/01-security

Próximo: instalação do Coolify — self-hosted PaaS.
Por que pagar Railway/Render quando você tem uma VPS?

---

## EP02 — LinkedIn

---

Instalei o Coolify. É basicamente um Heroku/Railway que roda na sua própria VPS.

Mas tem um detalhe que ninguém fala direito: ele precisa de root para instalar.

Isso criou uma tensão interessante com o EP01, onde bloqueei o login root via SSH.

A solução:

→ Coolify é instalado como root (obrigatório)
→ Durante a instalação, ele gera a própria chave SSH em /data/coolify/ssh/keys/
→ Essa chave é usada internamente para gerenciar containers
→ Meu acesso ao servidor continua sendo pelo usuário "deploy" com minha chave
→ Root não tem entrada SSH direta — continua bloqueado

O resultado: Coolify tem o que precisa, e eu não abro brecha desnecessária.

O que ficou rodando depois de ~15 minutos:

→ Painel em coolify.vpslab.com.br com HTTPS automático (Let's Encrypt + Traefik)
→ Deploy automático via GitHub (push = deploy)
→ Reverse proxy gerenciado
→ Gerenciamento de bancos de dados
→ Portas 80/443 roteadas corretamente

Fechei a porta 8000 (acesso inicial ao painel) assim que o HTTPS entrou no ar.

Diagrama da arquitetura + checklist pós-instalação:
👇 github.com/felipebossolani/vps-lab/tree/main/02-coolify

Próximo: primeiro deploy real — site estático com Astro e CI/CD automático.

#devops #selfhosted #coolify #docker #opensource

---

## EP03 — LinkedIn

---

Push no GitHub → deploy automático → live em menos de 60 segundos.

Esse é o ciclo que configurei com Coolify + Astro.

O que fiz:

→ 1. Conectei o repositório vps-lab ao Coolify via GitHub App
→ 2. Apontei o Base Directory para /03-static-sites/example-astro
→ 3. Build pack Nixpacks detectou Astro automaticamente (sem configurar nada)
→ 4. Adicionei o domínio site.vpslab.com.br — SSL emitido em 90 segundos
→ 5. Habilitei Auto Deploy — a partir daí, push = deploy

Uma coisa que aprendi na prática:

O Base Directory no Coolify precisa apontar para onde está o package.json,
não para a raiz do repositório. Parece óbvio depois que você erra uma vez.

O site é o índice público da série — cada episódio vira um card linkando
para o código no GitHub.

Código do site + notas de deploy:
👇 github.com/felipebossolani/vps-lab/tree/main/03-static-sites

Próximo: API Node.js + PostgreSQL com o banco isolado na rede interna Docker.
Esse é o episódio onde a coisa fica séria.

#devops #selfhosted #astro #coolify #opensource

---

## EP05 — LinkedIn

---

Deploy de API com banco de dados. O detalhe que mais importa: o banco não está na internet.

Construí um encurtador de URLs (Node.js + PostgreSQL) e subi no Coolify.

O ponto técnico central do episódio:

O PostgreSQL fica isolado na rede interna Docker.
Nenhuma porta exposta no host. Nenhuma entrada pela internet.
A API fala com o banco pelo hostname interno do container.

Como funciona no Coolify:

→ Cria o banco: Databases → New → PostgreSQL
→ NÃO habilita "Publicly Accessible" (essa opção existe — não use em produção)
→ Coolify gera duas connection strings: interna e externa
→ Usa a interna na variável DATABASE_URL da API
→ Os dois containers ficam na mesma rede Docker gerenciada pelo Coolify

Resultado:

```
Internet → Traefik → API (porta 3000)
                        ↓ rede interna
                     PostgreSQL (sem porta exposta)
```

Para testar o isolamento:
- Da internet → conexão recusada ✅
- Da API → conecta normalmente ✅

O Dockerfile usa multi-stage build (imagem final sem devDependencies)
e roda com usuário não-root dentro do container.

API completa + Dockerfile + docker-compose para rodar local:
👇 github.com/felipebossolani/vps-lab/tree/main/05-backend-with-db

#devops #selfhosted #nodejs #postgresql #docker #opensource

---

## EP06 — LinkedIn

---

Como eu sei que meu servidor está saudável às 3 da manhã?

Stack de observabilidade completa, self-hosted, custo zero além do VPS.

O que sobe com um único docker-compose:

→ Grafana — dashboards de métricas e logs
→ Prometheus — coleta métricas dos containers e do host
→ Node Exporter — CPU, memória, disco do servidor
→ Loki — agrega logs de todos os containers
→ Promtail — agente que envia logs Docker para o Loki
→ Uptime Kuma — status page pública em status.vpslab.com.br

O Grafana consegue responder:
- Qual container está consumindo mais CPU agora?
- A API teve erros nas últimas 2 horas?
- O disco está cheio?
- O servidor ficou fora do ar? Por quanto tempo?

Uptime Kuma vira a página pública que você manda para quem pergunta
"seu site está fora?" — com histórico de 90 dias.

docker-compose completo + configs do Prometheus e Promtail:
👇 github.com/felipebossolani/vps-lab/tree/main/06-observability

#devops #selfhosted #grafana #observabilidade #opensource

---

## EP07 — LinkedIn

---

Quanto estou pagando de VPS vs o que pagaria em SaaS equivalente?

Fiz a conta:

| O que tenho rodando | SaaS equivalente | Custo SaaS |
| Deploy de apps | Railway/Render | ~$20/mês |
| Blog | Ghost Pro | $25/mês |
| Encurtador de URLs | Bitly Premium | $35/mês |
| Monitoramento | Datadog | $15/mês |
| Status page | Statuspage.io | $29/mês |
| PostgreSQL gerenciado | Supabase Pro | $25/mês |
| TOTAL | | ~$149/mês |

VPS (Bork Cloud): ~R$ 100/mês.

Mas vou ser honesto — self-hosted não é bala de prata.

O SaaS ainda ganha em:
→ Tempo de setup (minutos vs horas)
→ Manutenção zero
→ SLA garantido
→ Escalabilidade automática

Self-hosted faz sentido quando:
✅ São side projects sem SLA crítico
✅ Você quer aprender infraestrutura de verdade
✅ Você tem múltiplos projetos pequenos — custo fixo não escala

❌ Produto em produção com usuários pagantes sem time de infra
❌ Quando seu tempo vale mais do que a diferença de custo

Toda a série, open source:
👇 github.com/felipebossolani/vps-lab

#devops #selfhosted #engenharia #opensource
