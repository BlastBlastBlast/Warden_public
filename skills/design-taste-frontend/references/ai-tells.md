# AI Tells Reference

A catalog of the patterns that read as "generated," gathered from production testing. None of these are absolute — the point is to notice when you're reaching for one by default rather than because the brief calls for it. Skim this before finalizing copy, decoration, and color.

## Visual & CSS
- Neon or outer glows by default — an inner border or a subtle tinted shadow reads more intentional.
- Pure black (`#000000`) — off-black, `zinc-950`, or charcoal has more depth.
- Oversaturated accent colors — desaturating slightly blends better with neutrals.
- Heavy gradient text on large headers.
- Custom mouse cursors — outdated, accessibility-hostile, and a perf cost for no real gain.

## Typography
- Inter as the unexamined default display font (a deliberate choice, it's fine).
- Oversized H1s used to create hierarchy by raw scale alone — weight and color usually do the job better.
- Serif reached for because "creative brief" — reserve it for editorial/luxury/publication work, or when the brief names a serif explicitly.
- `Fraunces` and `Instrument_Serif` specifically — the two most-reached-for LLM display serifs; when a serif is genuinely justified, rotate from a wider pool instead of reusing the same one project to project: PP Editorial New, GT Sectra Display, Cardinal Grotesque, Reckless Neue, Tiempos Headline, Recoleta, Cormorant Garamond, Playfair Display, EB Garamond, IvyPresto, Migra, Editorial Old, Saol Display, Söhne Breit Kursiv, Domaine Display, Canela, Schnyder, Tobias, NB Architekt, ITC Galliard.
- Font pairings worth knowing: `Geist` + `Geist Mono`, `Satoshi` + `JetBrains Mono`, `Cabinet Grotesk` + `Inter Tight`, `GT America` + `IBM Plex Mono`.
- Mixed-family emphasis inside a headline (dropping a random serif word into a sans headline) — use italic or bold of the same family instead.
- Italic display words with a descender (`y g j p q`) clipped by `leading-none` — use `leading-[1.1]` minimum plus a small bottom-padding reserve.

## Color
- The AI-purple/blue-glow gradient aesthetic as an unexamined default — fine when the brand actually is purple.
- Drifting the accent color across sections (a warm-grey site suddenly getting a blue CTA, a rose-accented site getting a teal badge) — one accent, used identically everywhere, reads as designed.
- The premium-consumer default palette — warm paper/cream/chalk backgrounds (`#f5f1ea`, `#f7f5f1`, `#fbf8f1`, `#efeae0`, `#ece6db`, `#faf7f1`, `#e8dfcb`), brass/clay/oxblood/ochre accents (`#b08947`, `#b6553a`, `#9a2436`, `#9c6e2a`, `#bc7c3a`, `#7d5621`), and espresso/near-black text (`#1a1714`, `#1a1814`, `#1b1814`). Nearly every generated premium-consumer site (cookware, wellness, artisan, DTC home goods) reaches for this exact family, which erases the brand. Rotate instead: cold luxury (silver-grey/chrome/smoke), forest (deep green + bone + amber), black and tan (true off-black + warm tan, no beige), cobalt + cream, terracotta + slate, olive + brick + paper, or pure monochrome + one saturated pop. Don't reuse the same family as the last premium-consumer project. The beige+brass+espresso combination is fine when the brand brief names those colors explicitly, or the identity is genuinely vintage/artisan/warm-craft and the choice can be justified for this specific brand.

## Layout & spacing
- Mathematically-perfect, evenly-distributed padding everywhere — occasional intentional asymmetry reads more considered.
- Three identical feature cards side by side — try a 2-column zigzag, an asymmetric grid, scroll-pinned, or a horizontal-scroll alternative.

## Content & data (the "Jane Doe" effect)
- Generic placeholder names ("John Doe", "Sarah Chan", "Jack Su") — use specific, locale-appropriate names instead.
- Generic avatars (SVG "egg" icons, Lucide user icons) — use believable photo placeholders or distinct styling.
- Fake-perfect numbers (`99.99%`, `50%`, `1234567`) — organic, messy numbers (`47.2%`, `+1 (312) 847-1928`) read as real.
- Startup-slop invented brand names ("Acme", "Nexus", "SmartFlow", "Cloudly") — invent something more specific and premium-sounding.
- Filler verbs ("Elevate", "Seamless", "Unleash", "Next-Gen", "Revolutionize") — replace with concrete verbs.

## External resources & components
- Hand-rolled SVG icon paths — use Phosphor/HugeIcons/Radix/Tabler; Lucide only on explicit request.
- Hand-rolled decorative SVGs (custom illustrations, logos, marks) — strongly discouraged as a default; acceptable when the brief explicitly asks for one, it's a single simple geometric mark, and you're confident in the output.
- Div-based fake screenshots (a "product preview" built from styled `<div>` rectangles simulating a task list, terminal, or dashboard) — use a real screenshot, a generated image, a real component preview, or skip the preview.
- Broken or generic Unsplash links — use `https://picsum.photos/seed/{descriptive-string}/{w}/{h}`, generated placeholders, or real assets.
- shadcn/ui left in its default, uncustomized visual state.

## Hero & top-of-page clutter
- Version labels in the hero (`V0.6`, `v2.0`, `BETA`, `INVITE-ONLY PREVIEW`, `EARLY ACCESS`, `ALPHA`) — fine only when the brief is genuinely about a launch/preview status.
- "Brand · No. 01"-style sub-eyebrows.
- A tiny tagline stacked below the CTAs ("Works with GitHub, GitLab, and self-hosted Git"), a trust micro-strip ("Used by engineering teams at..."), a pricing teaser, a feature bullet list, or a social-proof avatar row crammed into the hero — these belong in a dedicated section directly below, not stacked into the hero itself. If there's already an eyebrow or a brand strip, drop any additional tagline — one small text element per hero, at most.
- The "trusted by" logo wall living inside the hero rather than as its own section right below it.

## Section numbering & micro-labels
- Section-number eyebrows (`00 / INDEX`, `001 · Capabilities`, `002 · Featured commission`, `06 · how it works`, `05 · The honest table`) — name the topic in plain language instead.
- `01 / 4`-style pagination labels on images or bento tiles — if the viewer can count the tiles, the label adds nothing.
- Scroll cues with a section-number prefix (`Scroll · 001 Capabilities`).
- "Index of Work, 2018-2026"-style range labels as eyebrows.
- Generic step labels ("Stage 1 / Stage 2 / Stage 3", "Step 1 / Step 2 / Step 3", "Phase 01 / Phase 02 / Phase 03", "Pass One / Pass Two / Pass Three") — the actual step content (a verb like "Install", "Configure", "Ship") is the label.

## Separators, dots & typographic flourishes
- The middle dot (`·`) used as the default separator for everything — ration it to about one per line in metadata strips; prefer line breaks, hairlines, or columns for anything more.
- Decorative colored status dots before every nav item, list row, or badge — reserve dots for actual semantic state (a live server status, an availability flag), used sparingly.
- The em dash (`—`) as a design flourish, or anywhere else. It's the single most over-used AI stylistic tic in production testing — treat headlines, eyebrows, pills, body copy, quotes, attribution, captions, buttons, and alt text as if the character doesn't exist. A period, comma, parentheses, or colon always covers the same job in body copy; a regular hyphen covers headlines, labels, and quote attribution (` - `); a hyphen also covers date/number ranges (`2018-2026`, `€40-80k`) in place of an en dash used as a separator. The only dash characters that belong on the page are the regular hyphen and a minus sign in math (`-5°C`).
- `<br>`-broken, italicized headline splits ("for thirty<br>*years.*") used as a default design move — fine when the brief specifically calls for that kind of typographic drama, but it shouldn't be the reflexive choice.
- Vertical rotated text ("INDEX OF WORK, 2018-2026" rotated 90°) — an agency-portfolio cliché; use only when the brief is explicitly agency/Awwwards/experimental and it serves a real compositional purpose.
- Crosshair or hairline grid lines added purely to make the page "feel designed," with nothing they're actually organizing.

## Fake product previews
- Div-based fake product UI in the hero (a fake task list, terminal, or dashboard built from styled divs) — the single most recognizable AI-design tell. Use a real screenshot, a generated image, a real component preview, or nothing.
- Fake version footers inside fake screenshots ("v0.6.2-rc.1", "last sync 4s ago · main") — adds nothing, reads as AI immediately.

## Marketing-copy tells
- "Quietly in use at" / "Quietly trusted by" social-proof headers — plainer language ("Trusted by", "Used at", "Customers include") reads more natural, or skip the heading if the logos speak for themselves.
- Poetic section labels ("From the field", "Field notes", "Currently on the bench", "On our desks", "Loose plates") — reads as performative-craftsman; plain functional labels ("Testimonials", "Latest writing", "Now working on") or no label at all work better.
- Mock-humble industry asides ("We respect the French ones") in body copy.
- Weather/locale strips ("LIS 14:23 · 18°C") in headers or footers, unless the brief is genuinely about a place or a timezone-distributed studio.
- Micro-meta sentences sitting under an eyebrow ("Each of these is a feature we ship today, not a roadmap promise. The list will stay short on purpose.") — eyebrow + headline + body is already enough.

## Pills, labels & version stamps
- `<span>` pill overlays on top of images (`Brand · 02`, `PLATE · BRAND`, `Field notes - journal`) — let the image speak alone, or caption it directly below, outside the image.
- Invented photo-credit captions (`Field study no. 12 · Ines Caetano`, `Plate 03 · House archive`, `Frame XII · 35mm`) under stock or placeholder images — reserve real photo credit for real photographers with permission; otherwise skip the caption or keep it plainly functional ("The 6-quart, in Sage.").
- Version footers on marketing pages (`v1.4.2`, `Build 0048`, `last sync 4s ago · main`) — those are devtool/CLI fixtures, not landing-page content.
- "Reservation 412 of 800"-style live-stock counters as decoration, unless the brief is a genuine limited-run waitlist with real data.

## Decoration text strips
- A small mono-caps strip across the bottom of the hero (`BRAND. MOTION. SPATIAL.`, `TYPE / FORM / MOTION`, `DESIGN · BUILD · SHIP`) — an agency-portfolio cliché; fine only when it carries real, navigable content (a sticky bottom nav) or real status info (a cookie banner, build info on a docs site).
- A floating top-right sub-text paragraph next to a giant left-aligned section headline with no clear alignment to anything — put the sub-text directly under the headline, or build a genuine two-column header instead.

## Lists, dividers & scoring
- `border-t` and `border-b` on every row of a long list or spec table — pick one, use it sparsely, or switch to one of the alternatives in `references/patterns.md`.
- Filled-background-track progress/scoring bars as comparison visuals — a number plus a small icon, or a thin inline bar with no background track, reads less like dashboard-UI clutter on a landing page.

## Locale, time & scroll cues
- Locale/city-name/time/weather strips in the hero, footer, or nav ("Lisbon, working with founders", "1200-690 Lisbon, Portugal", "Lisbon 14:23 · 18°C") — a single contact address in the footer is fine; an atmospheric locale strip isn't, unless the brief is a genuinely globally-distributed studio, a travel brand, or tied to a real physical venue.
- Scroll cues (`Scroll`, `↓ scroll`, `Scroll to explore`, an animated mouse-wheel icon) — if someone hasn't scrolled yet, they're looking at the hero and already know what scrolling is.
- Decorative status dots with no real meaning, anywhere on the page.
