# DESIGN.md — Doctores de Honduras

Guía de diseño para el rediseño del sitio. **Claude: leé este archivo completo antes de tocar cualquier vista o CSS.** Toda decisión visual sale de estos tokens; si algo no está definido aquí, proponelo primero, no lo inventes en el código.

Stack: **Rails 8 + Tailwind CSS** (`tailwindcss-rails`, `app/assets/tailwind/application.css`) + Hotwire (Turbo + Stimulus) + importmap. La escala `primary-*` ya existe (`app/assets/stylesheets/colors.css`) y mapea a la escala **sky** — los tokens de abajo se alinean con esas clases.

## Dirección

Directorio médico de confianza para familias hondureñas. El sitio debe sentirse **calmado, profesional y premium** — como un producto de salud moderno, no como un listado. Referencia de calidad: Apple / Linear. Referencia de tono: cercano, en español claro, sin jerga médica innecesaria.

- Mucho aire. El whitespace es parte del diseño, no espacio desperdiciado.
- Una sola cosa audaz por página (el "signature"); todo lo demás quieto y disciplinado.
- La búsqueda es la protagonista del sitio: el trabajo #1 del usuario es encontrar un doctor.

## Colores

Paleta basada en los azules actuales del brand (escala **sky** de Tailwind, ya en el repo).

```css
:root {
  /* Marca */
  --color-primary:        #0EA5E9;  /* sky-500 — acentos, iconos, links, anillo de foco */
  --color-primary-hover:  #0284C7;  /* sky-600 — relleno de botón / hover */
  --color-primary-deep:   #0C4A6E;  /* sky-900 — navbar, footer, hero de fondo */
  --color-primary-soft:   #F0F9FF;  /* sky-50  — tintes claros, fondos de realce */
  --color-primary-ring:   rgb(14 165 233 / 0.25); /* foco: sky-500 al 25% */

  /* Neutrales — escala fría (slate) para armonizar con los azules */
  --color-ink:      #0B1220;  /* texto principal */
  --color-slate:    #4B5768;  /* texto secundario */
  --color-muted:    #8B95A5;  /* labels, metadata */
  --color-line:     #E4E9F0;  /* bordes, divisores */
  --color-surface:  #F6F8FB;  /* fondos de sección alternos */
  --color-white:    #FFFFFF;

  /* Estado */
  --color-success:  #1A9E6C;  /* "Destacado", disponible */
  --color-warning:  #C77D0A;
  --color-error:    #C43D3D;
}
```

Reglas de uso:
- El azul `primary` se gana su impacto por escasez: CTAs, links, iconos activos, anillo de foco. **No** pintar secciones enteras de azul salvo hero y footer (`primary-deep`).
- Fondo dominante: blanco. Secciones alternas: `surface`. Nunca gris genérico #f5f5f5.
- **Contraste / texto blanco sobre azul (AA 4.5:1):** `sky-500` (#0EA5E9) con texto blanco da ~2.9:1 → **no** pasa AA para texto normal. Por eso:
  - Botón primario = fondo `primary-hover` (#0284C7) o más oscuro, texto blanco **bold**.
  - Hero/footer con texto blanco = `primary-deep` (#0C4A6E) → contraste holgado.
  - `sky-500` queda para **iconos, acentos, bordes y links sobre blanco** (link sobre blanco: usar `sky-700` #0369A1 para AA seguro).

## Tipografía

- **Display (títulos):** `Bricolage Grotesque` — humanista, cálida, distintiva sin perder seriedad médica. Pesos 600–700, `letter-spacing: -0.02em`.
- **Body:** `Inter` — 400/500, `font-feature-settings: "tnum"` en cifras (973 doctores, teléfonos).
- Escala:
  - Hero: `clamp(2.5rem, 6vw, 4.5rem)`, línea 1.05
  - H2 sección: `clamp(1.75rem, 3.5vw, 2.5rem)`
  - Body: 1rem / 1.65 de interlineado
  - Eyebrow/labels: 0.8125rem, uppercase, tracking 0.08em, color `muted`
- Los eyebrows solo si etiquetan algo real ("Especialidades", "Destacados"), nunca decorativos.

## Espaciado y forma

- Secciones: `py-24 md:py-32`. Contenido: `max-w-6xl mx-auto px-6`.
- Radius: `rounded-2xl` cards, `rounded-full` botones y pills de especialidad, `rounded-xl` inputs.
- Sombras: solo dos niveles. Reposo: `0 1px 3px rgb(11 18 32 / 0.06)`. Hover/elevado: `0 12px 32px -8px rgb(11 18 32 / 0.14)`. Nunca sombras duras ni con color.
- Bordes: 1px `--color-line`; el borde hace el trabajo, la sombra acompaña.

## Motion

- Duraciones: micro 150ms · hover 250ms · reveals 500ms. Easing: `cubic-bezier(0.22, 1, 0.36, 1)` (ease-out-quint).
- **Turbo 8 View Transitions** activadas: `<meta name="view-transition" content="same-origin">` en el layout.
- **Scroll reveal:** un solo Stimulus controller (`reveal_controller.js`, IntersectionObserver). Patrón: fade + translateY(16px) → 0. Stagger de 60ms entre cards hermanas. Cada elemento se revela **una sola vez**.
- Hover en cards: lift de 2px + sombra elevada + la foto escala 1.03 dentro de overflow-hidden.
- Navbar: sticky, fondo `white/80` + `backdrop-blur-md` + borde inferior `line` que aparece al hacer scroll.
- **`prefers-reduced-motion: reduce` respetado siempre**: sin translates ni scales, solo fades de 150ms.
- Prohibido: carruseles automáticos, elementos que se mueven sin interacción, más de un tipo de reveal por página.

## Signature

**La búsqueda-héroe.** El hero es casi solo tipografía + una barra de búsqueda grande (radius full, sombra elevada, icono en `primary`) con placeholder que rota entre especialidades reales ("Cardiología en San Pedro Sula…", "Pediatría…") con un fade suave. Debajo, en tabular nums y color `muted`: "973 doctores · 107 especialidades", con count-up al primer reveal. Ese es el único momento "wow" del home; el resto respira.

## Componentes clave

- **Card de doctor:** foto arriba (aspect 4/5, overflow-hidden), nombre en display 600, especialidad en `slate`, pill "Destacado" en `success-soft`, CTA "Ver perfil" como link con flecha que se desplaza 4px al hover. Todo el card es clickeable.
- **Botones:** primario = fondo `primary-hover`, texto blanco bold, rounded-full, `px-6 py-3`; al hover oscurece a `primary-deep` y lift 1px. Secundario = borde `line`, texto `ink`.
- **Inputs:** fondo blanco, borde `line`, foco con ring 3px `primary-ring`.
- Los textos de UI dicen lo que hacen: "Buscar doctor", "Enviar mensaje", "Ver perfil" — nunca "Submit" ni "Click aquí".

## Piso de calidad (no negociable)

- Responsive hasta 360px.
- Foco de teclado visible en todo elemento interactivo.
- `reduced-motion` respetado.
- Imágenes con `alt` real (nombre del doctor, no "foto").
- Componentes reutilizables vía partials o ViewComponent — nada de estilos copy-pasteados entre vistas.

---

## Cómo implementar (orden recomendado)

1. **Tokens en Tailwind:** exponer estos colores en el theme (`app/assets/tailwind/application.css` con `@theme`) para usarlos como `bg-primary`, `text-ink`, etc. La escala `primary-*` (sky) ya existe; agregar `deep`/`soft`/`ink`/`slate`/`muted`/`line`/`surface` + las fuentes.
2. **Fuentes:** cargar `Bricolage Grotesque` + `Inter` (Fontsource vía importmap o `<link>` de Google Fonts en el layout).
3. **Hero primero** (mayor impacto, sirve de referencia visual para el resto).
4. **Card de doctor** con hover + scroll reveal (`reveal_controller.js`).
5. **Navbar sticky** con blur + View Transitions.
6. **Micro-interacciones** al final (botones, búsqueda).

**Tip para trabajar con Claude:** pedir primero *"leé DESIGN.md y `app/views/home`, proponeme el rediseño del hero (estructura + clases) sin escribir código todavía"*, revisar la propuesta, y recién después implementar. Iterar en la propuesta antes del código ahorra vueltas.
