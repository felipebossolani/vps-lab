# Design System — vps-lab

Decisões de identidade visual da série vps-lab.
Documento de referência para o site, blog e assets.

---

## Logo

### Conceito
Símbolo técnico (stack de servidores) + wordmark em fonte monospace.
Três camadas empilhadas representam infraestrutura. O LED azul no topo
indica o servidor ativo — a camada que o usuário controla.

### Arquivos

| Arquivo | Uso |
|---------|-----|
| `logo/vpslab-logo.svg` | Versão principal (fundo claro) |
| `logo/vpslab-logo-dark.svg` | Versão dark mode |
| `logo/vpslab-icon.svg` | Ícone isolado (favicon, avatar, 48×48) |

### Nome
`vps-lab` — minúsculo, com hífen. Sempre.
Nunca: VPS Lab, VPSLab, vpslab.

### Tagline
`we ♥ self-hosted`
Fonte mono, letter-spacing generoso, na cor de acento azul.

---

## Paleta

| Token | Hex | Uso |
|-------|-----|-----|
| `--color-accent` | `#3b82f6` | LEDs, links, tagline, destaques |
| `--color-accent-glow` | `#3b82f6` @ 15% opacity | Halo do LED ativo |
| `--color-bg` | `#0C0C1A` | Fundo principal (dark) |
| `--color-surface` | `#13131f` | Cards, painéis |
| `--color-border` | `#1e2130` | Bordas de containers |
| `--color-text` | `#f1f5f9` | Texto principal |
| `--color-muted` | `#64748b` | Texto secundário, camadas inativas |
| `--color-muted-light` | `#94a3b8` | Detalhes, linhas decorativas |

---

## Tipografia

### Display / Wordmark
- Família: `JetBrains Mono` → fallback `Fira Code` → `Courier New` → `monospace`
- Uso: logo, títulos de seção, blocos de código destacados
- Letter-spacing: `-1.5px` no wordmark grande, normal em títulos

### Corpo
- Família: `Inter` → fallback `system-ui` → `sans-serif`
- Tamanho base: `16px`, line-height `1.7`
- Uso: parágrafos, descrições, UI geral

### Code inline
- Família: mesma do display (`JetBrains Mono`)
- Background: `--color-surface` com borda `--color-border`

---

## Componentes base

### Card de episódio
```
background: --color-surface
border: 1px solid --color-border
border-radius: 8px
padding: 1.5rem
hover: border-color → --color-accent (transition 200ms)
hover: transform: translateY(-2px)
```

### Badge de status
```
✅ Publicado  → text: --color-accent, bg: --color-accent @ 10%
🔜 Em breve   → text: --color-muted, bg: --color-surface
```

### Link
```
color: --color-accent
text-decoration: none
hover: opacity 0.8
```

---

## Princípios visuais

1. **Tipografia primeiro** — o layout respira, o texto lidera
2. **Poucos elementos** — cada componente justifica sua presença
3. **Acento com parcimônia** — o azul aparece onde importa, não em todo lugar
4. **Dark by default** — fundo escuro é o modo principal
5. **Referência técnica sutil** — infra no símbolo, não espalhada pelo layout

---

## Assets a gerar (Gemini Imagen)

- [ ] OG image padrão da série (1200×630)
- [ ] OG image por episódio (1200×630, com número e título do EP)
- [ ] Hero image para o site principal
- [ ] Variação do logo em PNG (2x, para uso em redes sociais)

Ver prompts em `gemini-prompts/`.
