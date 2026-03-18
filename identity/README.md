# vps-lab — Identidade Visual

Arquivos de identidade visual da série vps-lab.

## Estrutura

```
identity/
├── logo/
│   ├── vpslab-logo.svg        ← logo completo (fundo claro)
│   ├── vpslab-logo-dark.svg   ← logo completo (dark mode)
│   └── vpslab-icon.svg        ← ícone isolado (favicon, avatar)
├── docs/
│   └── DESIGN_SYSTEM.md       ← paleta, tipografia, componentes
└── gemini-prompts/
    └── prompts.md             ← prompts para Gemini Imagen
```

## Uso do logo

```html
<!-- site (dark mode) -->
<img src="/identity/logo/vpslab-logo-dark.svg" alt="vps-lab" height="40">

<!-- favicon -->
<link rel="icon" type="image/svg+xml" href="/identity/logo/vpslab-icon.svg">
```

## Decisões de identidade

- Nome: `vps-lab` — minúsculo, com hífen. Sempre.
- Acento: `#3b82f6` (azul elétrico)
- Fonte: JetBrains Mono para display, Inter para corpo
- Tagline: `we ♥ self-hosted`
- Dark by default
