# Gemini Imagen — Prompts vps-lab

Use esses prompts no Gemini Imagen (Nano Banana) para refinar o logo
e gerar os assets da série.

---

## 01 — Refinamento do logo

```
Refine this tech logo concept for "vps-lab", a self-hosted infrastructure series.

Logo elements:
- Symbol: three stacked server rack units, minimalist line art style
- Top rack: prominent, full stroke border, active blue LED indicator (#3b82f6) with subtle glow
- Middle rack: medium opacity stroke, blue LED at 50% opacity
- Bottom rack: low opacity stroke, grey LED, decorative only
- Each rack has small horizontal line details representing ports/slots

Wordmark: "vps-lab" in JetBrains Mono or similar monospace font, lowercase, letter-spacing tight
Tagline below wordmark: "we ♥ self-hosted" in same monospace font, smaller, in accent blue

Style: clean, minimal, dev tool aesthetic, no gradients, flat design
Color palette: dark navy background (#0C0C1A), white/light text, single accent blue (#3b82f6)
Output: vector-style, clean lines, professional tech brand
```

---

## 02 — OG Image padrão da série

```
Create an Open Graph image (1200x630px) for "vps-lab", a Brazilian self-hosted infrastructure blog series.

Layout:
- Dark navy background (#0C0C1A)
- Left side: vps-lab logo (server stack symbol + wordmark)
- Right side: subtle technical illustration (server rack lines, network nodes, or terminal grid)
- Bottom left: "vpslab.com.br" in small monospace text
- Accent color: electric blue (#3b82f6) for highlights and borders

Style: minimal, dark, professional developer tool aesthetic
No gradients, no stock photography, flat design with subtle geometric details
Typography: monospace for all text
```

---

## 03 — OG Image por episódio (template)

```
Create an Open Graph image (1200x630px) for episode [NUMBER] of "vps-lab" series.

Episode info:
- Number: EP[XX] (large, prominent)
- Title: "[TÍTULO DO EPISÓDIO]"

Layout:
- Dark navy background (#0C0C1A)
- Top left: small vps-lab logo
- Center: large "EP[XX]" in monospace, electric blue (#3b82f6)
- Below episode number: episode title in white monospace
- Bottom: subtle server/infra line art decoration
- Bottom right: "vpslab.com.br"

Style: minimal dark tech, consistent with series identity
Same aesthetic as the series OG image but episode-specific
```

Episódios a gerar:
- EP01 — Segurança: Hardening do servidor
- EP02 — Coolify: instalação com firewall ativo
- EP03 — Site estático com Astro e CI/CD automático
- EP04 — Blog próprio sem mensalidade
- EP05 — API Node.js + PostgreSQL isolado
- EP06 — Observabilidade com Grafana + Loki
- EP07 — Custo real vs SaaS

---

## 04 — Hero image para o site

```
Create a hero illustration for "vps-lab", a self-hosted infrastructure series at vpslab.com.br.

Concept: a minimal isometric or flat illustration of a server rack or datacenter node
- Clean geometric shapes, no photorealism
- Color palette: dark navy (#0C0C1A), electric blue (#3b82f6), light grey lines
- Should feel like a developer tool landing page, not a stock photo
- Subtle: this is a background/accent element, not the main focus
- Works well at wide aspect ratio (1440×600 approx)

Style: flat design, geometric, minimal, monochromatic with single blue accent
Reference aesthetic: Vercel, Railway, Coolify landing pages
```

---

## Dicas de uso no Gemini

1. Gere sempre em alta resolução (peça 2x ou 4x quando possível)
2. Para o logo, peça variação com fundo transparente (PNG com alpha)
3. Para OG images, valide que o texto é legível em preview pequeno (social feed)
4. Use o mesmo prompt base e varie só o conteúdo do episódio para manter consistência
