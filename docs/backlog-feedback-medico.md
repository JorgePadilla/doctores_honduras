# Backlog — Sesión de feedback con el médico/socio

> Tickets y historias de usuario derivados de la sesión de revisión de la app (transcripción de reunión). Participantes: **Jorge Padilla** (desarrollo) y el **médico/socio** (dominio clínico + cliente).
> El hilo conductor de la sesión: *"básicamente eso es lo que busca la gente"* — la búsqueda por procedimiento y el contacto rápido son el corazón del producto; la agenda ligada al directorio es el diferenciador frente a la competencia (*"esto ya es venderle… su secretaria ya no necesita papel"*).

## Leyenda

- **Prioridad:** P0 (crítico / core del producto) · P1 (alto) · P2 (medio) · P3 (nice-to-have)
- **Esfuerzo:** S (≤1 día) · M (2-3 días) · L (~1 semana) · XL (>1 semana / requiere diseño)
- **Estado:** 🔲 pendiente · 🟡 parcial · ✅ hecho

---

## EPIC A — Búsqueda y descubrimiento

El médico insiste en que la gente **no busca por nombre de médico, busca por lo que le duele / el procedimiento**: "cesárea", "apéndice", "caries", "obturaciones". Hoy el buscador no cubre esto.

### A1 · Búsqueda libre por servicio / procedimiento  `P0` · `M` · ✅
**Historia:** Como paciente, quiero escribir un procedimiento (p. ej. *"cesárea"*, *"apendicitis"*, *"caries"*) en el buscador y ver todos los médicos que ofrecen ese servicio, para encontrar al especialista adecuado sin saber su especialidad.

**Contexto (transcripción):** *"por procedimiento específico… que vos pudieras escribir cesárea y aparezcan los ginecólogos"*, *"escriba caries y aparezcan todos los odontólogos"*. Jorge: *"si son los que no está indexado porque eso lo hice después de haber hecho el buscador"*.

**Criterios de aceptación:**
- Al escribir un término en el buscador de `/doctors`, se hace match también contra los **servicios** del médico, no solo nombre/especialidad/ciudad.
- Buscar "cesárea" devuelve médicos cuyos servicios contengan ese término.
- El match es case-insensitive y por término parcial (como el resto de la búsqueda).

**Notas técnicas:** En `app/controllers/doctors_controller.rb` la búsqueda libre (líneas ~44-67) hace `OR` sobre `doctor_profiles.name`, `specialties.name`, `subspecialties.name`, `cities.name`, `departments.name` y `establishments.name`, **pero NO sobre `services.name`**. Ya existe la relación `DoctorProfile has_many :services` (se usa en el filtro exacto `params[:service]`, línea 29). Agregar un `LEFT JOIN services` + condición `LOWER(services.name) LIKE ?` al bloque de condiciones libres. Ojo con `DISTINCT` (un médico con varios servicios puede duplicarse).

---

### A2 · Etiquetas / sinónimos de procedimientos por especialidad  `P1` · `L` · ✅
**Historia:** Como médico, quiero asociar **palabras clave/etiquetas** a mi perfil (p. ej. odontólogo → "obturaciones", "caries", "limpieza dental") para que los pacientes me encuentren con el vocabulario que ellos usan, no con el término clínico.

**Contexto:** *"que haya listado como de las etiquetas… la gente que escriba caries y tú aparezcan todos los odontólogos"*.

**Criterios de aceptación:**
- El médico puede añadir etiquetas/keywords a su perfil (o elegir de un catálogo por especialidad).
- La búsqueda libre (A1) también matchea contra estas etiquetas.
- Existe un catálogo semilla de sinónimos comunes por especialidad (caries→odontología, cesárea→ginecología, etc.).

**Notas técnicas:** Se puede modelar como un catálogo `Tag`/`Keyword` con join a `DoctorProfile`, o reutilizar/extender el modelo `Service`. Depende de A1 (mismo motor de búsqueda). Sembrar diccionario inicial de procedimientos frecuentes. Considerar sinónimos (apéndice/apendicitis/apendicectomía).

---

### A3 · Reorganizar el panel de filtros  `P1` · `M` · ✅
**Historia:** Como paciente, quiero un panel de filtros claro con **Especialidad · Ciudad · Hospital/Ubicación** como ejes principales, para acotar la búsqueda sin perderme.

**Contexto:** *"tengo que arreglar un poco, organizar… ahí a la izquierda está un poco perdidas las cosas"*. Las tres cosas que motivan la búsqueda: especialidad, ciudad y hospital.

**Criterios de aceptación:**
- Filtros visibles y ordenados: Especialidad, Ciudad, Hospital/Ubicación (+ Servicio/Procedimiento de A1).
- Jerarquía visual clara (labels, agrupación) alineada al design system (sky, `rounded-xl`, iconos outline del helper `icon()`).
- Responsive y consistente entre desktop y móvil.

**Notas técnicas:** `app/views/shared/_doctor_filters.html.erb`. Aprovechar el helper `icon()` y los tokens de UI. Coordinar con A1 para exponer el filtro de servicio/procedimiento.

---

## EPIC B — Perfil del médico

El perfil debe comunicar rápido **quién es, qué hace, dónde está y cómo contactarlo**. Orden mental del médico: *"formación, ubicación, servicios… y contacto — son las tres cosas más importantes"*.

### B1 · Contacto rápido: teléfono + Llamar + WhatsApp  `P1` · `M` · 🟡
**Historia:** Como paciente, quiero ver el teléfono y contactar por **llamada o WhatsApp con un toque**, para agilizar el contacto sin copiar números.

**Contexto:** *"debe de haber información básica de contacto… número de teléfono para hacer más rápido"*, *"posibilidades de WhatsApp y todo eso"*, *"para que sea práctico"*.

**Criterios de aceptación:**
- El teléfono es visible en el perfil y en (idealmente) la tarjeta del listado.
- Botón **Llamar** (`tel:`) y botón **WhatsApp** (`https://wa.me/<numero>`), ambos con icono.
- Si el médico no tiene WhatsApp, el botón no se muestra.
- Se registra el clic de contacto (ya existe tracking de "Contact Click" en `doctors/show`).

**Notas técnicas:** El botón "Llamar" (`tel:`) y `map_link` ya existen en `doctors/show`. Falta campo/uso de **WhatsApp** (número o flag) y su botón. Reutilizar el patrón de tracking `data-controller="analytics"` ya presente. Considerar normalizar el número a formato internacional para `wa.me`.

---

### B2 · Renombrar "Sucursales" → "Ubicaciones"  `P1` · `M` · 🔲
**Historia:** Como médico/paciente, quiero que la app hable de **"Ubicaciones"/"Consultorio"** en vez de **"Sucursales"**, porque en salud el paciente pregunta *dónde está ubicado*, no por "sucursales" (término más de farmacias/negocios).

**Contexto:** *"sucursales no lo manejamos así, sino como ubicación… en consultorios hablamos de ubicaciones en vez de sucursales… sucursal es más cuando es una clínica con negocio, una farmacia"*.

**Criterios de aceptación:**
- Todas las etiquetas visibles "Sucursal/Sucursales" cambian a "Ubicación/Ubicaciones" (o "Consultorio" donde aplique).
- Sin regresiones en agenda, reservas, correos ni formularios de perfil.

**Notas técnicas:** "Sucursal" aparece en ~10 vistas: `profiles/_form_branches`, `doctors/show`, `agenda/appointments/*` (index, new, show, _form), `bookings/new`, `paciente/appointments/show`, `appointment_mailer/*`. **Recomendación:** cambiar solo las **etiquetas de UI**, manteniendo el nombre interno del modelo/tabla `doctor_branches` (`DoctorBranch`) para evitar una migración riesgosa. Barrido de texto controlado + revisión visual.

---

### B3 · Enlace "Abrir en Google Maps" (deep link, sin API embebida)  `P2` · `S` · 🟡
**Historia:** Como paciente, quiero un botón que **abra la ubicación directamente en Google Maps**, para llegar sin batallar copiando la dirección.

**Contexto:** *"darle acá y abrir el mapa y que me lleve realmente a donde dice"*. Jorge: *"ese mapa normalmente tenemos que pagar por un API"* → preferir **deep link** en vez de mapa embebido para evitar costo de API.

**Criterios de aceptación:**
- Botón "Abrir en Google Maps" / "Cómo llegar" que abre la app/web de Maps con la ubicación.
- No embebe mapa (sin costo de API); usa el `map_link` existente o construye `https://www.google.com/maps/search/?api=1&query=<dirección o lat,lng>`.
- Se muestra por ubicación del médico.

**Notas técnicas:** Ya existe `map_link` en establecimientos y en `profiles/_form_branch_fields`. Estandarizar el render como enlace externo (`target="_blank" rel="noopener"`) con icono `map_pin`. Si solo hay dirección de texto, generar el query de búsqueda.

---

### B4 · Reordenar el perfil (jerarquía de información)  `P2` · `M` · 🔲
**Historia:** Como paciente, quiero el perfil ordenado como **Especialidad → Formación → Ubicaciones → Servicios → Contacto**, para leer lo importante primero.

**Contexto:** *"lo podemos reorganizar… la formación, tu ubicación, los servicios, los medios de contacto"*.

**Criterios de aceptación:**
- Secciones del perfil en el orden acordado, con títulos claros.
- Consistente con el design system (tarjetas `rounded-xl`, iconos outline).

**Notas técnicas:** `app/views/doctors/show.html.erb`. Coordinar con B1 (contacto), B2 (ubicaciones) y B3 (mapa). Cambio principalmente de maquetación.

---

### B5 · Mostrar solo la especialidad (ocultar "Medicina General")  `P2` · `S` · 🟡
**Historia:** Como paciente, quiero ver **solo la especialidad** del médico y no "Medicina General", para no confundirme (casi todos son médicos generales antes de especializarse).

**Contexto:** *"antes le ponían medicina general… la gente se confunde… debería mostrarse solo la especialidad"*. Nota: el médico dice *"ya lo cambiaron"* → **verificar si ya está resuelto**.

**Criterios de aceptación:**
- Si el médico tiene una especialidad, no se muestra "Medicina General" como etiqueta principal.
- Si solo es general, se maneja con una etiqueta apropiada.

**Notas técnicas:** Verificar `specialization`/`specialty` en `DoctorProfile` y su render en `doctors/show` y `doctors/index`. Posiblemente ya resuelto — validar antes de estimar.

---

## EPIC C — Agenda y citas

La agenda es el **diferenciador** del producto. La conversación identificó dos necesidades clínicas reales que hoy no cubre el modelo de slots fijos.

### C1 · Duración de cita configurable (por cita, no fija)  `P1` · `L` · 🔲
**Historia:** Como médico/secretaria, quiero **elegir la duración al agendar** (arrastrando o seleccionando), porque no todas las citas duran lo mismo (una revisión rápida vs. un procedimiento de 2 horas).

**Contexto:** *"que duren tanto tiempo, tendría que ser configurable… media hora, una hora"*, *"vos escoges cuánto tiempo… yo solo lo jalo y lo agarro del tiempo"*, *"más que estar amarrado a un tiempo específico"*.

**Criterios de aceptación:**
- Al crear/editar una cita se puede definir su duración (o arrastrar el bloque en el time-grid).
- El bloque en la agenda refleja la duración real.
- Se respeta un rango mínimo por diseño (ver nota técnica).

**Notas técnicas:** Hoy `DoctorAgendaSetting.appointment_duration` es **un valor global por médico (default 30 min)**; `SlotGenerator` genera slots uniformes. Se necesita: duración **por cita** (campo en `appointments` o derivada de `start_time`/`end_time`), y ajustar el render del time-grid (`AgendaHelper`, `HOUR_PX`) para bloques de altura variable. Restricción de diseño reconocida por Jorge: *"la pantalla tiene cierto tamaño… tenemos que manejar rangos mínimos"* → definir slot mínimo (p. ej. 15 min).

---

### C2 · Sobrecupo: múltiples citas en el mismo horario (límite configurable)  `P1` · `XL` · 🔲
**Historia:** Como médico con varios consultorios/asistentes, quiero **agendar varias citas en el mismo horario** (con un límite, p. ej. 3-4), porque veo pacientes en paralelo mientras el equipo hace el pre-chequeo.

**Contexto:** *"cito a las 10, otro a las 10:15… tienen dos, tres, cuatro consultores en un solo lugar"*, *"un dermatólogo que tiene cuatro consultorios… cita 3 pacientes a la misma hora"*, *"poner un límite entre tres"*. Ejemplo real en el time-grid de la esposa del médico: dos citas a la misma hora que hoy se enciman visualmente.

**Criterios de aceptación:**
- El médico configura una **capacidad por franja** (citas concurrentes permitidas, p. ej. 1-4).
- La agenda permite N citas en el mismo horario hasta el límite y las muestra lado a lado (carriles), sin encimarse.
- Al alcanzar el límite, no se permiten más citas concurrentes.

**Notas técnicas:** Cambio de fondo en el modelo de slots. Añadir `max_concurrent`/capacidad (en `DoctorAgendaSetting` o por ubicación `DoctorBranch`). `SlotGenerator` debe contar ocupación por franja en vez de asumir 1. El time-grid (`AgendaHelper`) necesita **layout por carriles/lanes** para citas solapadas (geometría ya insinuada en el helper). Alto esfuerzo por lógica + diseño visual. Puede fasearse: primero permitir solape con límite (backend), luego pulir el render en carriles.

---

### C3 · Estado "sobrecupo" condicional  `P2` · `L` · 🔲
**Historia:** Como secretaria, quiero marcar una cita como **"sobrecupo"** (condicional), que entra solo si se libera un espacio o el paciente llega a tiempo, para manejar demanda extra y ausencias.

**Contexto:** *"lo pongo a agendar pero es sobreocupo… si hay un espacio entra, si no tiene que esperar a que se libere"*, *"pacientes que agendan, confirman y no llegan… lo agendo solo sobreocupo porque ya desperdició un espacio"*.

**Criterios de aceptación:**
- Una cita puede marcarse como "sobrecupo" (estado/flag distinto a la cita normal).
- Se distingue visualmente en la agenda.
- Regla de negocio: entra al flujo normal si se libera un espacio o según llegada; documentar el comportamiento exacto con el médico.

**Notas técnicas:** Añadir estado/flag a `Appointment` (hoy `STATUSES = pendiente/confirmada/cancelada/completada`). Relacionado con C2 (capacidad). Requiere definir con el cliente la regla de promoción de sobrecupo → cita firme. Empezar simple: etiqueta + no cuenta contra la capacidad.

---

### C4 · Horarios por ubicación (visibilidad y edición)  `P2` · `M` · 🔲
**Historia:** Como médico, quiero configurar y **ver claramente mis horarios por ubicación**, para que la agenda y la reserva pública respeten dónde atiendo cada día.

**Contexto:** *"cuando te vas a la sucursal, ¿cómo están los horarios?… le dieron un montón de escojas, lo que pasa es que no se mira"* (existe pero poco visible).

**Criterios de aceptación:**
- Los horarios por ubicación son fáciles de configurar y de ver en el perfil/agenda.
- La generación de slots respeta el horario de cada ubicación.

**Notas técnicas:** Ya existe `BranchSchedule` (horarios por `DoctorBranch`). Es principalmente un tema de **UX/visibilidad**: mejorar el formulario (`profiles/_form_branches`) y mostrar los horarios de forma legible. Coordinar con B2 (Ubicaciones).

---

### C5 · Exponer/reubicar la asignación de secretaria  `P2` · `S` · 🟡
**Historia:** Como médico, quiero encontrar fácilmente la opción de **asignar a mi secretaria** para que gestione mi agenda, sin que esté escondida.

**Contexto:** *"lo de asignar la secretaria para que agende… está un poco escondido… ocupa una reingeniería para reubicarlo"*.

**Criterios de aceptación:**
- Acceso claro a "Secretarias" desde la navegación de la agenda.
- Flujo de asignación probado end-to-end (Jorge: *"no lo he probado"*).

**Notas técnicas:** Ya existe `Agenda::SecretariesController` + `SecretaryAssignment`. Es reubicación en la navegación de agenda + pruebas. **Nota:** con el nuevo centro de notificaciones (ya entregado), la secretaria invitada ahora recibe una notificación in-app ("invitacion_secretaria") — validar ese flujo aquí.

---

## EPIC E — Ya entregado (contexto de la sesión)

### E1 · Centro de notificaciones (campana) — ✅ hecho
En la sesión se elogia el panel de la campana: *"el panel arriba donde está la campanita que conecta todas las alertas… esto ha sido una ventaja exagerada comparado con estos manes… no están ligados, eso solo es la página amarilla"*.
Ya implementado en esta iteración: `Notification` unificado + campana con dropdown en el navbar + eventos (citas al paciente, lead a proveedor, pago, invitación de secretaria). Ver el modelo `Notification` y `app/views/shared/_navbar.html.erb`.

**Posicionamiento / valor (no es ticket):** el argumento de venta es **directorio + agenda integrados**: la secretaria deja el papel y gestiona todo en la plataforma. Mantener esta narrativa al priorizar (la agenda —EPIC C— sostiene el diferenciador).

---

## Backlog priorizado (resumen)

| ID | Título | Epic | Prioridad | Esfuerzo | Estado |
|----|--------|------|-----------|----------|--------|
| A1 | Búsqueda libre por servicio/procedimiento | Búsqueda | **P0** | M | ✅ |
| A3 | Reorganizar panel de filtros (+ Ciudad y Hospital) | Búsqueda | P1 | M | ✅ |
| B1 | Contacto rápido (teléfono + Llamar + WhatsApp) | Perfil | P1 | M | 🟡 |
| B2 | Renombrar Sucursales → Ubicaciones | Perfil | P1 | M | 🔲 |
| C1 | Duración de cita configurable | Agenda | P1 | L | 🔲 |
| C2 | Sobrecupo / citas concurrentes (límite) | Agenda | P1 | XL | 🔲 |
| A2 | Diccionario de sinónimos (admin CRUD) | Búsqueda | P1 | L | ✅ |
| B3 | Abrir en Google Maps (deep link) | Perfil | P2 | S | 🟡 |
| B4 | Reordenar jerarquía del perfil | Perfil | P2 | M | 🔲 |
| B5 | Ocultar "Medicina General" | Perfil | P2 | S | 🟡 |
| C3 | Estado "sobrecupo" condicional | Agenda | P2 | L | 🔲 |
| C4 | Horarios por ubicación visibles | Agenda | P2 | M | 🔲 |
| C5 | Exponer asignación de secretaria | Agenda | P2 | S | 🟡 |

**Sugerencia de primer sprint (mayor impacto / esfuerzo contenido):** A1 → B1 → B2 → A3. Son el "core" que el médico repite (encontrar por procedimiento + contactar rápido) y desbloquean valor inmediato sin tocar la parte compleja de la agenda.
