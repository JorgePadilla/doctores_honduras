# UI/UX Style Guide

Reference guide for consistent visual design across Doctores Honduras. Based on the `/doctors` directory page as the canonical example.

## Color Palette

### Primary (Sky Blue) - Brand color, CTAs, links, active states
| Token | Hex | Usage |
|-------|-----|-------|
| sky-50 | `#f0f9ff` | Hover backgrounds, light highlights |
| sky-100 | `#e0f2fe` | Selected/active backgrounds |
| sky-300 | `#7dd3fc` | Dark mode text accent |
| sky-400 | `#38bdf8` | Dark mode primary text, dark mode hover |
| sky-500 | `#0ea5e9` | Primary buttons, focus rings, selected states |
| sky-600 | `#0284c7` | Links (light mode), button hover |
| sky-700 | `#0369a1` | Headings (light mode) |
| sky-900 | `#0c4a6e` | Dark mode backgrounds (30% opacity) |

### Secondary (Teal) - Accent on cards, badges, secondary highlights
| Token | Hex | Usage |
|-------|-----|-------|
| teal-500 | `#14b8a6` | Secondary accent |
| teal-600 | `#0d9488` | Card left borders |

### Accent (Orange) - Warnings, attention, premium highlights
| Token | Hex | Usage |
|-------|-----|-------|
| amber-500 | `#f59e0b` | Accent buttons |
| orange-500 | `#f97316` | Featured badges |

### Neutral (Gray / Slate)
| Token | Light mode | Dark mode |
|-------|-----------|-----------|
| Background (page) | `bg-gray-50` | `bg-slate-900` |
| Background (card) | `bg-white` | `bg-slate-800` |
| Background (input) | `bg-white` | `bg-slate-700` |
| Text primary | `text-gray-900` | `text-white` |
| Text secondary | `text-gray-600` | `text-slate-300` |
| Text muted | `text-gray-500` | `text-slate-400` |
| Border default | `border-gray-200` | `border-slate-700` |
| Border input | `border-gray-300` | `border-slate-600` |

### Status Colors
| Status | Dot | Background | Text |
|--------|-----|-----------|------|
| Pendiente | `bg-yellow-500` | `bg-yellow-100 dark:bg-yellow-900/30` | `text-yellow-800 dark:text-yellow-300` |
| Confirmada | `bg-blue-500` | `bg-blue-100 dark:bg-blue-900/30` | `text-blue-800 dark:text-blue-300` |
| Completada | `bg-green-500` | `bg-green-100 dark:bg-green-900/30` | `text-green-800 dark:text-green-300` |
| Cancelada | `bg-red-500` | `bg-red-100 dark:bg-red-900/30` | `text-red-800 dark:text-red-300` |

---

## Buttons

### Primary (main actions)
```html
<button class="bg-sky-500 hover:bg-sky-600 text-white px-5 py-2.5 rounded-full font-medium transition-all shadow-md hover:shadow-lg">
  Accion Principal
</button>
```

### Primary (in-card, rectangular)
```html
<button class="bg-sky-500 hover:bg-sky-600 text-white px-4 py-2 rounded-lg font-medium transition">
  Guardar
</button>
```

### Secondary (outlined)
```html
<button class="border border-sky-500 text-sky-600 dark:text-sky-400 bg-transparent hover:bg-sky-50 dark:hover:bg-sky-900/20 px-5 py-2.5 rounded-full font-medium transition">
  Accion Secundaria
</button>
```

### Danger
```html
<button class="bg-red-500 hover:bg-red-600 text-white px-4 py-2 rounded-lg font-medium transition">
  Eliminar
</button>
```

### Ghost (text-only link style)
```html
<a class="text-sky-600 dark:text-sky-400 hover:underline text-sm font-medium">
  Ver mas
</a>
```

### Button sizing
| Context | Padding | Border radius |
|---------|---------|---------------|
| Page CTA (landing, hero) | `px-5 py-2.5` | `rounded-full` |
| Card/form action | `px-4 py-2` | `rounded-lg` |
| Small inline | `px-3 py-1` | `rounded-lg` |
| Full width submit | `w-full py-3` | `rounded-lg` |

---

## Cards

### Standard card
```html
<div class="bg-white dark:bg-slate-800 rounded-xl shadow-md dark:shadow-slate-900/50 overflow-hidden hover:shadow-lg transition-all">
  <div class="p-6">
    <!-- content -->
  </div>
</div>
```

### Card with left accent border
```html
<div class="bg-white dark:bg-slate-800 rounded-xl shadow-md border-l-4 border-sky-300 dark:border-sky-500 p-6">
  <!-- content -->
</div>
```

### Info/stat card (dashboard)
```html
<div class="bg-white dark:bg-slate-800 rounded-lg shadow p-6">
  <div class="flex items-center justify-between">
    <div>
      <p class="text-sm text-gray-500 dark:text-gray-400">Label</p>
      <p class="text-2xl font-bold text-gray-900 dark:text-white">42</p>
    </div>
    <div class="p-3 bg-sky-100 dark:bg-sky-900/30 rounded-full">
      <!-- icon SVG -->
    </div>
  </div>
</div>
```

---

## Form Inputs

### Text input
```html
<label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Campo *</label>
<input class="w-full rounded-lg border-gray-300 dark:border-slate-600 dark:bg-slate-700 dark:text-white focus:ring-sky-500 focus:border-sky-500">
```

### Select
```html
<select class="w-full rounded-lg border-gray-300 dark:border-slate-600 dark:bg-slate-700 dark:text-white focus:ring-sky-500 focus:border-sky-500">
```

### Textarea
```html
<textarea rows="3" class="w-full rounded-lg border-gray-300 dark:border-slate-600 dark:bg-slate-700 dark:text-white focus:ring-sky-500 focus:border-sky-500"></textarea>
```

### Date picker (Flatpickr)
```html
<input type="text" data-controller="datepicker"
       class="w-full rounded-lg border-gray-300 dark:border-slate-600 dark:bg-slate-700 dark:text-white focus:ring-sky-500 focus:border-sky-500"
       placeholder="Selecciona una fecha" autocomplete="off">
```

### Error display
```html
<div class="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg p-4">
  <ul class="list-disc list-inside text-sm text-red-700 dark:text-red-400">
    <li>Error message here</li>
  </ul>
</div>
```

---

## Typography

| Element | Classes |
|---------|---------|
| Page title (h1) | `text-2xl font-bold text-gray-900 dark:text-white` |
| Section heading (h2) | `text-lg font-semibold text-gray-900 dark:text-white` |
| Card title (h3) | `text-lg font-semibold text-sky-700 dark:text-sky-400` |
| Body text | `text-gray-700 dark:text-slate-300` |
| Secondary text | `text-gray-600 dark:text-gray-400` |
| Muted/helper | `text-sm text-gray-500 dark:text-gray-400` |
| Small label | `text-xs text-gray-500 dark:text-gray-400` |

---

## Badges & Tags

### Tag (specialty, service)
```html
<span class="inline-block px-3 py-1 text-sm rounded-full bg-sky-50 dark:bg-sky-900/30 text-sky-700 dark:text-sky-400">
  Cardiologia
</span>
```

### Status badge
```html
<span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 dark:bg-green-900/30 text-green-800 dark:text-green-300">
  Activo
</span>
```

---

## Layout Patterns

### Page container
```html
<div class="container mx-auto px-4 py-8 max-w-6xl">
```

### Two-column grid
```html
<div class="grid grid-cols-1 md:grid-cols-2 gap-6">
```

### Three-column grid (cards)
```html
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
```

### Section separator
```html
<div class="border-t border-gray-200 dark:border-slate-700 pt-6 mt-6">
```

---

## Spacing Reference

| Size | Value | Usage |
|------|-------|-------|
| xs | `p-2` / `gap-2` | Tight spacing, tag gaps |
| sm | `p-4` / `gap-4` | Card internal padding, form gaps |
| md | `p-6` / `gap-6` | Card main padding, section gaps |
| lg | `p-8` / `gap-8` | Page padding, major section spacing |
| Section margin | `mb-6` | Between major page sections |

---

## Dark Mode

Implementation: Tailwind `dark:` variant. Toggled via `dark-mode` Stimulus controller on `<html>` element.

**Rules:**
1. Always pair light class with `dark:` equivalent
2. Backgrounds: `bg-white` -> `dark:bg-slate-800`, `bg-gray-50` -> `dark:bg-slate-900`
3. Text: `text-gray-900` -> `dark:text-white`, `text-gray-600` -> `dark:text-slate-300`
4. Borders: `border-gray-200` -> `dark:border-slate-700`
5. Highlights: `bg-sky-50` -> `dark:bg-sky-900/30` (use `/30` opacity)
6. Shadows: `shadow-md` -> `dark:shadow-slate-900/50`

---

## Icons

SVGs inline with `w-5 h-5` or `w-6 h-6`, colored via `text-gray-400` / `text-sky-500`. Use `fill="none" stroke="currentColor"` for outline icons.

---

## Animations & Transitions

| Pattern | Classes |
|---------|---------|
| Button hover | `transition-all hover:shadow-lg` |
| Card hover | `hover:shadow-lg transition-all` |
| Color change | `transition-colors duration-200` |
| Flash messages | Custom CSS keyframes in `custom.css` |

---

## Component Checklist

When building new views, ensure:
- [ ] Background: `bg-white dark:bg-slate-800` on cards
- [ ] All text has dark mode variant
- [ ] Borders have dark mode variant
- [ ] Buttons use sky-500/sky-600 pattern
- [ ] Focus states use `focus:ring-sky-500 focus:border-sky-500`
- [ ] Links use `text-sky-600 dark:text-sky-400 hover:underline`
- [ ] Cards have `rounded-xl shadow-md` (or `rounded-lg shadow`)
- [ ] Forms follow the label + input pattern above
- [ ] Status colors use the STATUS_CLASSES hash (not dynamic interpolation)

## Patient Dashboard Components

Patient views (`/paciente/*`) follow the same design system with teal accents for patient-specific elements.

### Patient Appointment Card
Used in `/paciente/appointments` for both upcoming and past appointments:
- `bg-white dark:bg-slate-800 rounded-xl shadow-md p-5` base
- Left border color from `appointment.status_classes[:border]`
- Doctor name in `font-semibold text-gray-900 dark:text-white`
- Status badge: `text-xs px-3 py-1 rounded-full font-medium` with status-specific bg/text colors
- Past appointments: `opacity-75 hover:opacity-100`

### Patient Booking Banner
Shown in `/bookings/new` when logged in as paciente:
- `bg-teal-50 dark:bg-teal-900/20 border border-teal-200 dark:border-teal-800 rounded-xl p-3`
- Teal checkmark icon + "Reservando como **[name]**" text

### Patient Onboarding Card
On profile type selection page:
- Teal color scheme (`border-teal-500`, `bg-teal-100`, heart icon)
- Same card structure as doctor/hospital/vendor cards

### Patient Profile Type Colors
| Context | Light | Dark |
|---------|-------|------|
| Onboarding card border | `border-teal-500` | `border-teal-500` |
| Icon background | `bg-teal-100` | `bg-teal-900/30` |
| Icon color | `text-teal-600` | `text-teal-400` |
| Dashboard card border-left | `border-l-teal-300` | `border-l-teal-500` |
| Admin badge | `bg-teal-100 text-teal-800` | `bg-teal-900/30 text-teal-300` |

## Files Reference

| File | Purpose |
|------|---------|
| `app/assets/stylesheets/colors.css` | Custom color utility classes (primary/secondary/accent) |
| `app/assets/stylesheets/custom.css` | Button, card, form, flash, Flatpickr styles |
| `app/views/doctors/index.html.erb` | Canonical reference page for cards and search UI |
| `app/views/doctors/show.html.erb` | Reference for detail/profile pages |
| `app/views/paciente/appointments/index.html.erb` | Patient appointment list (upcoming + history) |
| `app/views/paciente/profiles/show.html.erb` | Patient profile display |
