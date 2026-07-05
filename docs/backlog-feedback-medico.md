# Backlog — Sesiones de feedback con el médico/socio

> Tickets y historias de usuario derivados de las reuniones de revisión de la app. Participantes: **Jorge Padilla** (desarrollo) y el **médico/socio** (dominio clínico + cliente).
> **1ª sesión** — el hilo: *"básicamente eso es lo que busca la gente"* — la búsqueda por procedimiento y el contacto rápido son el corazón del producto; la agenda ligada al directorio es el diferenciador (*"esto ya es venderle… su secretaria ya no necesita papel"*). → **Épicas A, B, C: ✅ entregadas.**
> **2ª sesión** — el expediente clínico digital (no perder el historial, seguridad ante alergias). → **F1, G1, G2, G3 + documentación por consulta (H1, H2, H3) + portal del paciente (I1): ✅ entregados**; solo **H4 (adjuntos de lab): pendiente** (ver "2º audio" abajo). El expediente es una función **Elite** con techo de registros (5k/25k/100k).

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

### B1 · Contacto rápido: teléfono + Llamar + WhatsApp  `P1` · `M` · ✅
**Historia:** Como paciente, quiero ver el teléfono y contactar por **llamada o WhatsApp con un toque**, para agilizar el contacto sin copiar números.

**Contexto:** *"debe de haber información básica de contacto… número de teléfono para hacer más rápido"*, *"posibilidades de WhatsApp y todo eso"*, *"para que sea práctico"*.

**Criterios de aceptación:**
- El teléfono es visible en el perfil y en (idealmente) la tarjeta del listado.
- Botón **Llamar** (`tel:`) y botón **WhatsApp** (`https://wa.me/<numero>`), ambos con icono.
- Si el médico no tiene WhatsApp, el botón no se muestra.
- Se registra el clic de contacto (ya existe tracking de "Contact Click" en `doctors/show`).

**Notas técnicas:** El botón "Llamar" (`tel:`) y `map_link` ya existen en `doctors/show`. Falta campo/uso de **WhatsApp** (número o flag) y su botón. Reutilizar el patrón de tracking `data-controller="analytics"` ya presente. Considerar normalizar el número a formato internacional para `wa.me`.

---

### B2 · Renombrar "Sucursales" → "Ubicaciones"  `P1` · `M` · ✅
**Historia:** Como médico/paciente, quiero que la app hable de **"Ubicaciones"/"Consultorio"** en vez de **"Sucursales"**, porque en salud el paciente pregunta *dónde está ubicado*, no por "sucursales" (término más de farmacias/negocios).

**Contexto:** *"sucursales no lo manejamos así, sino como ubicación… en consultorios hablamos de ubicaciones en vez de sucursales… sucursal es más cuando es una clínica con negocio, una farmacia"*.

**Criterios de aceptación:**
- Todas las etiquetas visibles "Sucursal/Sucursales" cambian a "Ubicación/Ubicaciones" (o "Consultorio" donde aplique).
- Sin regresiones en agenda, reservas, correos ni formularios de perfil.

**Notas técnicas:** "Sucursal" aparece en ~10 vistas: `profiles/_form_branches`, `doctors/show`, `agenda/appointments/*` (index, new, show, _form), `bookings/new`, `paciente/appointments/show`, `appointment_mailer/*`. **Recomendación:** cambiar solo las **etiquetas de UI**, manteniendo el nombre interno del modelo/tabla `doctor_branches` (`DoctorBranch`) para evitar una migración riesgosa. Barrido de texto controlado + revisión visual.

---

### B3 · Enlace "Abrir en Google Maps" (deep link, sin API embebida)  `P2` · `S` · ✅
**Historia:** Como paciente, quiero un botón que **abra la ubicación directamente en Google Maps**, para llegar sin batallar copiando la dirección.

**Contexto:** *"darle acá y abrir el mapa y que me lleve realmente a donde dice"*. Jorge: *"ese mapa normalmente tenemos que pagar por un API"* → preferir **deep link** en vez de mapa embebido para evitar costo de API.

**Criterios de aceptación:**
- Botón "Abrir en Google Maps" / "Cómo llegar" que abre la app/web de Maps con la ubicación.
- No embebe mapa (sin costo de API); usa el `map_link` existente o construye `https://www.google.com/maps/search/?api=1&query=<dirección o lat,lng>`.
- Se muestra por ubicación del médico.

**Notas técnicas:** Ya existe `map_link` en establecimientos y en `profiles/_form_branch_fields`. Estandarizar el render como enlace externo (`target="_blank" rel="noopener"`) con icono `map_pin`. Si solo hay dirección de texto, generar el query de búsqueda.

---

### B4 · Reordenar el perfil (jerarquía de información)  `P2` · `M` · ✅
**Historia:** Como paciente, quiero el perfil ordenado como **Especialidad → Formación → Ubicaciones → Servicios → Contacto**, para leer lo importante primero.

**Contexto:** *"lo podemos reorganizar… la formación, tu ubicación, los servicios, los medios de contacto"*.

**Criterios de aceptación:**
- Secciones del perfil en el orden acordado, con títulos claros.
- Consistente con el design system (tarjetas `rounded-xl`, iconos outline).

**Notas técnicas:** `app/views/doctors/show.html.erb`. Coordinar con B1 (contacto), B2 (ubicaciones) y B3 (mapa). Cambio principalmente de maquetación.

---

### B5 · Mostrar solo la especialidad (ocultar "Medicina General")  `P2` · `S` · ✅
**Historia:** Como paciente, quiero ver **solo la especialidad** del médico y no "Medicina General", para no confundirme (casi todos son médicos generales antes de especializarse).

**Contexto:** *"antes le ponían medicina general… la gente se confunde… debería mostrarse solo la especialidad"*. Nota: el médico dice *"ya lo cambiaron"* → **verificar si ya está resuelto**.

**Criterios de aceptación:**
- Si el médico tiene una especialidad, no se muestra "Medicina General" como etiqueta principal.
- Si solo es general, se maneja con una etiqueta apropiada.

**Notas técnicas:** Verificar `specialization`/`specialty` en `DoctorProfile` y su render en `doctors/show` y `doctors/index`. Posiblemente ya resuelto — validar antes de estimar.

---

## EPIC C — Agenda y citas

La agenda es el **diferenciador** del producto. La conversación identificó dos necesidades clínicas reales que hoy no cubre el modelo de slots fijos.

### C1 · Duración de cita configurable (por cita, no fija)  `P1` · `L` · ✅
**Historia:** Como médico/secretaria, quiero **elegir la duración al agendar** (arrastrando o seleccionando), porque no todas las citas duran lo mismo (una revisión rápida vs. un procedimiento de 2 horas).

**Contexto:** *"que duren tanto tiempo, tendría que ser configurable… media hora, una hora"*, *"vos escoges cuánto tiempo… yo solo lo jalo y lo agarro del tiempo"*, *"más que estar amarrado a un tiempo específico"*.

**Criterios de aceptación:**
- Al crear/editar una cita se puede definir su duración (o arrastrar el bloque en el time-grid).
- El bloque en la agenda refleja la duración real.
- Se respeta un rango mínimo por diseño (ver nota técnica).

**Notas técnicas:** Hoy `DoctorAgendaSetting.appointment_duration` es **un valor global por médico (default 30 min)**; `SlotGenerator` genera slots uniformes. Se necesita: duración **por cita** (campo en `appointments` o derivada de `start_time`/`end_time`), y ajustar el render del time-grid (`AgendaHelper`, `HOUR_PX`) para bloques de altura variable. Restricción de diseño reconocida por Jorge: *"la pantalla tiene cierto tamaño… tenemos que manejar rangos mínimos"* → definir slot mínimo (p. ej. 15 min).

---

### C2 · Sobrecupo: múltiples citas en el mismo horario (límite configurable)  `P1` · `XL` · ✅
**Definido:** el límite es **por consultorio** (`DoctorBranch.max_concurrent`, campo "Pacientes simultáneos" en cada Ubicación), no por médico. Ej.: un consultorio con 3 espacios pone 3; uno solo deja 1. Las citas simultáneas se muestran en carriles lado a lado.

**Historia:** Como médico con varios consultorios/asistentes, quiero **agendar varias citas en el mismo horario** (con un límite, p. ej. 3-4), porque veo pacientes en paralelo mientras el equipo hace el pre-chequeo.

**Contexto:** *"cito a las 10, otro a las 10:15… tienen dos, tres, cuatro consultores en un solo lugar"*, *"un dermatólogo que tiene cuatro consultorios… cita 3 pacientes a la misma hora"*, *"poner un límite entre tres"*. Ejemplo real en el time-grid de la esposa del médico: dos citas a la misma hora que hoy se enciman visualmente.

**Criterios de aceptación:**
- El médico configura una **capacidad por franja** (citas concurrentes permitidas, p. ej. 1-4).
- La agenda permite N citas en el mismo horario hasta el límite y las muestra lado a lado (carriles), sin encimarse.
- Al alcanzar el límite, no se permiten más citas concurrentes.

**Notas técnicas:** Cambio de fondo en el modelo de slots. Añadir `max_concurrent`/capacidad (en `DoctorAgendaSetting` o por ubicación `DoctorBranch`). `SlotGenerator` debe contar ocupación por franja en vez de asumir 1. El time-grid (`AgendaHelper`) necesita **layout por carriles/lanes** para citas solapadas (geometría ya insinuada en el helper). Alto esfuerzo por lógica + diseño visual. Puede fasearse: primero permitir solape con límite (backend), luego pulir el render en carriles.

---

### C3 · Estado "sobrecupo" condicional  `P2` · `L` · ✅
**Historia:** Como secretaria, quiero marcar una cita como **"sobrecupo"** (condicional), que entra solo si se libera un espacio o el paciente llega a tiempo, para manejar demanda extra y ausencias.

**Contexto:** *"lo pongo a agendar pero es sobreocupo… si hay un espacio entra, si no tiene que esperar a que se libere"*, *"pacientes que agendan, confirman y no llegan… lo agendo solo sobreocupo porque ya desperdició un espacio"*.

**Criterios de aceptación:**
- Una cita puede marcarse como "sobrecupo" (estado/flag distinto a la cita normal).
- Se distingue visualmente en la agenda.
- Regla de negocio: entra al flujo normal si se libera un espacio o según llegada; documentar el comportamiento exacto con el médico.

**Notas técnicas:** Añadir estado/flag a `Appointment` (hoy `STATUSES = pendiente/confirmada/cancelada/completada`). Relacionado con C2 (capacidad). Requiere definir con el cliente la regla de promoción de sobrecupo → cita firme. Empezar simple: etiqueta + no cuenta contra la capacidad.

---

### C4 · Horarios por ubicación (visibilidad y edición)  `P2` · `M` · ✅
**Historia:** Como médico, quiero configurar y **ver claramente mis horarios por ubicación**, para que la agenda y la reserva pública respeten dónde atiendo cada día.

**Contexto:** *"cuando te vas a la sucursal, ¿cómo están los horarios?… le dieron un montón de escojas, lo que pasa es que no se mira"* (existe pero poco visible).

**Criterios de aceptación:**
- Los horarios por ubicación son fáciles de configurar y de ver en el perfil/agenda.
- La generación de slots respeta el horario de cada ubicación.

**Notas técnicas:** Ya existe `BranchSchedule` (horarios por `DoctorBranch`). Es principalmente un tema de **UX/visibilidad**: mejorar el formulario (`profiles/_form_branches`) y mostrar los horarios de forma legible. Coordinar con B2 (Ubicaciones).

---

### C5 · Exponer/reubicar la asignación de secretaria  `P2` · `S` · ✅
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

### E2 · Filtro de ubicación jerárquico (País → Departamento → Ciudad) + geolocalización — ✅ hecho
Reemplaza la lista plana de ~122 ciudades (con nombres duplicados ambiguos) por una cascada **País → Departamento → Ciudad**. Nuevo modelo `Country` (la app queda lista para multi-país). Best-effort: preselecciona la zona del visitante por geolocalización (IP). El select de País siempre visible (Honduras preseleccionado).

### E3 · Teléfono "Llamar" a nivel doctor — ✅ hecho
Campo `phone` en el perfil del doctor (además de WhatsApp) con botón **Llamar** (`tel:`) en la card y el perfil; los teléfonos de consultorio ahora son links clickables. Complementa B1.

### E4 · Panel admin: mostrar/ocultar secciones — ✅ hecho
Switch en el panel admin para ocultar Hospitales/Clínicas y Proveedores del sitio público (útil para lanzar o trabajar sin exponer partes no listas). Modelo `SiteSetting` + helper `section_visible?`.

**Posicionamiento / valor (no es ticket):** el argumento de venta es **directorio + agenda integrados**: la secretaria deja el papel y gestiona todo en la plataforma. Mantener esta narrativa al priorizar (la agenda —EPIC C— sostiene el diferenciador).

---

## 2º audio — Expediente clínico digital

> Derivado de una **segunda reunión** con el médico/socio. El hilo es la **historia clínica del paciente**: el dolor de **perderla** (papel que se extravía) y el **riesgo de seguridad** que eso genera. Citas: *"pierdo el historial del paciente en la consulta… en el historial yo pude haber puesto algo importante tuyo, este man es alérgico a tal cosa, y no lo tengo… es un riesgo"*; el caso propio de la enfermera a punto de inyectar un **derivado de ibuprofeno** siendo alérgico; la visión: *"un sistema donde te ponen todas las cosas, vuelves a entrar y está todo el historial"*, con valor de **seguridad, menos errores y datos para decisiones** (vs. papel y lápiz).

**Estado actual del código (verificado):** NO existe expediente clínico. Solo hay `reason` + `doctor_notes` (texto libre) por cita en `appointments`, y una "historia del paciente" (`Agenda::PatientsController#show`) que es una **lista de citas agrupada por el string `patient_name`** (sin identidad estable, por-médico, sin normalizar). `PatientProfile` es solo demográfico. → **Todo el expediente clínico es net-new.**

### 💲 Modelo de negocio — Expediente = Elite (decidido)

El Expediente Clínico Digital es una **función exclusiva del plan Elite** (doctor) y es la base de una escala de precios por **capacidad de registros**, con **techo numérico en todos los niveles** (nada ilimitado):

| Nivel | Precio | Techo de registros |
|-------|--------|--------------------|
| Doctor Elite | $35/mes | 5,000 |
| Doctor Elite 25K | $69/mes | 25,000 |
| Doctor Elite 100K | $129/mes | 100,000 |

- **Research de precio (2026):** EMR/EHR LATAM (SaludTotal, MediSystem, Huli, ARMED) ≈ **$14–131 USD/mes**; EMR EE. UU. promedian ~$382/mes. La escala entra bajo la mediana LATAM y el tope queda dentro del rango.
- **Implementado ya (esta sesión):** columna `subscription_plans.patient_limit`, índice `(profile_type, tier)` **no-único** (los 3 Elite comparten `tier: "elite"` para no romper el gating), 3 planes Elite sembrados, badge de capacidad en la vista de planes. Ver `docs/subscription-plans.md`.
- **Pendiente:** aplicar `patient_limit` al crear registros (depende de F1/G1, abajo). El gating de acceso a la función usa `tier == "elite"` (igual que Agenda/reservas).

### ⚠️ Decisiones clave a definir (antes de implementar)
1. **Alcance:** ¿expediente **por médico** (cada médico su propio registro de sus pacientes) o **compartido/longitudinal** entre médicos? *Asunción por defecto: por médico* (más simple, coincide con el audio, evita complejidad legal/privacidad). Compartido = visión futura.
2. **Pacientes sin cuenta (walk-ins):** hoy solo tienen un `patient_name` (string). ¿El expediente debe cubrirlos? Requiere identidad estable.
3. **Dónde vive:** ¿modelo **`Patient` canónico** nuevo (cubre registrados + walk-ins) o extender **`PatientProfile`** (solo registrados)? Recomendación: entidad canónica — las citas hoy se ligan a `User`, no a `PatientProfile`, y los walk-ins no tienen cuenta.

## EPIC F — Identidad canónica del paciente (base técnica)

### F1 · Entidad de paciente estable  `P0` · `L` · ✅
**Historia:** como sistema, necesito **una identidad de paciente única y confiable** que una todas sus visitas, en vez del string `patient_name` actual.

**Contexto:** hoy "Juan Pérez", "Juan Perez" y "juan perez" son personas distintas; los walk-ins no tienen identidad estable; la historia es por-médico.

**Criterios de aceptación:**
- Modelo canónico `Patient`; las citas se vinculan a él (registrados y walk-ins).
- Búsqueda/normalización para no duplicar a la misma persona.

**Notas técnicas:** **prerequisito de todo el expediente.** Migrar `appointments.patient_user_id`/`patient_name` hacia un `patient_id`. Reusar la búsqueda `DISTINCT ON (patient_name)` de `Agenda::PatientsController#search` como punto de partida.

---

## EPIC G — Expediente clínico

### G1 · Ficha clínica del paciente  `P0` · `L` · ✅
**Historia:** como médico, quiero una **ficha clínica** por paciente con **alergias, condiciones crónicas, medicamentos actuales, tipo de sangre y antecedentes**, para no depender de mi memoria ni del papel.

**Contexto:** *"yo pude haber puesto algo importante tuyo… alérgico a tal cosa, y no lo tengo. Yo no tengo memoria infinita."*

**Criterios de aceptación:**
- Campos estructurados editables por el médico; persisten con el paciente (no por cita); visibles al abrir el paciente/cita.

**Notas técnicas:** nuevo modelo clínico ligado a la identidad de paciente (F1). Net-new. Reusar patrones de formulario del perfil.

---

### G2 · Alerta de información crítica (alergias) — seguridad  `P0` · `M` · ✅
**Historia:** como médico/secretaria, quiero ver de forma **prominente las alergias e info crítica** del paciente al abrir su cita, para evitar errores (medicar algo a lo que es alérgico).

**Contexto:** el caso del **derivado de ibuprofeno** — *"eso es un riesgo para un paciente, y pasa bastante."*

**Criterios de aceptación:**
- Banner/etiqueta destacada (roja) con alergias y alertas al ver la cita o el expediente; visible para médico y secretaria.

**Notas técnicas:** depende de G1 (dato de alergias). Reusar badges del design system.

---

### G3 · Historial clínico consolidado (no perder nada)  `P1` · `M` · ✅
**Historia:** como médico, quiero **abrir a un paciente y ver todo su historial** (notas de cada consulta, evolución) en un solo lugar, para nunca perder el hilo.

**Contexto:** *"vuelves a entrar y está todo el historial."* / *"pierdo el historial del paciente en la consulta."*

**Criterios de aceptación:**
- Vista de expediente que consolida las notas de todas las consultas del paciente (hoy hay que abrir cita por cita), en orden cronológico.

**Notas técnicas:** extiende `Agenda::PatientsController#show` (hoy solo lista citas con el `reason` truncado). Reusar el `doctor_notes` existente + las notas de H1.

---

## EPIC H — Documentación por consulta (extensión natural)

> H2–H4 no salieron explícitas del audio; son la evolución lógica de un expediente. Marcadas para decidir si entran.

### H1 · Nota de evolución por consulta  `P1` · `M` · ✅
Nota clínica estructurada por cita (más allá del único `doctor_notes`), que alimenta el historial consolidado (G3).

### H2 · Receta / prescripción  `P2` · `M` · ✅
Registrar los medicamentos recetados por consulta.

### H3 · Signos vitales  `P2` · `S` · ✅
Peso, presión, etc. por consulta.

### H4 · Adjuntos / resultados de laboratorio  `P2` · `M` · 🔲
Subir exámenes/resultados al expediente (reusar el patrón S3 / `ImageUploadService`).

---

## EPIC I — Acceso del paciente a su expediente (futuro)

### I1 · El paciente ve su historial clínico  `P3` · `M` · ✅
El paciente ve (parte de) su expediente/alergias desde su cuenta. Hoy solo ve sus citas y datos demográficos. Requiere definir qué es visible al paciente vs privado del médico.

**Posicionamiento / valor (no es ticket):** del audio — *"las ventajas de tener todo eso es brutal… no solo papel, es información para tomar decisiones… más seguridad de que no haya errores."* El expediente digital elimina el riesgo de perder el historial y de errores clínicos — algo que un directorio "página amarilla" jamás da.

---

## Backlog priorizado (resumen)

**Épicas A, B y C: completas** (implementadas, testeadas y desplegadas esta sesión). Pendiente: el 2º audio (Expediente clínico, F–I).

| ID | Título | Epic | Prioridad | Esfuerzo | Estado |
|----|--------|------|-----------|----------|--------|
| A1 | Búsqueda libre por servicio/procedimiento | Búsqueda | **P0** | M | ✅ |
| A2 | Diccionario de sinónimos (admin CRUD) | Búsqueda | P1 | L | ✅ |
| A3 | Filtros (Especialidad·País·Depto·Ciudad·Hospital·Servicio) | Búsqueda | P1 | M | ✅ |
| B1 | Contacto rápido (Llamar + WhatsApp) | Perfil | P1 | M | ✅ |
| B2 | Renombrar Sucursales → Ubicaciones | Perfil | P1 | M | ✅ |
| B3 | Abrir en Google Maps (deep link) | Perfil | P2 | S | ✅ |
| B4 | Reordenar jerarquía del perfil | Perfil | P2 | M | ✅ |
| B5 | Ocultar "Medicina General" | Perfil | P2 | S | ✅ |
| C1 | Duración de cita configurable | Agenda | P1 | L | ✅ |
| C2 | Sobrecupo / concurrencia (por consultorio) | Agenda | P1 | XL | ✅ |
| C3 | Estado "sobrecupo" condicional | Agenda | P2 | L | ✅ |
| C4 | Horarios por ubicación visibles | Agenda | P2 | M | ✅ |
| C5 | Exponer asignación de secretaria | Agenda | P2 | S | ✅ |
| — | *2º audio — Expediente clínico (núcleo P0 entregado)* | | | | |
| F1 | Identidad canónica del paciente (base) | Expediente | **P0** | L | ✅ |
| G1 | Ficha clínica (alergias, crónicos, meds) | Expediente | **P0** | L | ✅ |
| G2 | Alerta de info crítica (alergias) | Expediente | **P0** | M | ✅ |
| G3 | Historial clínico consolidado | Expediente | P1 | M | ✅ |
| H1 | Nota de evolución por consulta | Consulta | P1 | M | ✅ |
| H2 | Receta / prescripción (imprimible) | Consulta | P2 | M | ✅ |
| H3 | Signos vitales | Consulta | P2 | S | ✅ |
| H4 | Adjuntos / resultados de lab | Consulta | P2 | M | 🔲 |
| I1 | Paciente ve su historial | Paciente | P3 | M | ✅ |

**Núcleo P0 entregado (esta sesión):** **F1** (modelo `Patient` canónico por-médico + backfill de citas) · **G1** (ficha clínica `ClinicalRecord`: alergias, crónicos, medicamentos, tipo de sangre, antecedentes, notas — CRUD Elite) · **G2** (alerta de alergias en la ficha del paciente y en el detalle de la cita) · **G3** (roster de pacientes + historial consolidado por identidad canónica). Incluye el **enforcement del `patient_limit`** (los 3 niveles Elite: 5k/25k/100k registros). Las **3 decisiones clave** se resolvieron: **por-médico**, cubre **walk-ins**, vive en un modelo `Patient` canónico nuevo.

**Entregado (esta sesión):** **H1** (nota de evolución por consulta) · **H2** (receta con medicamentos repetibles + vista imprimible) · **H3** (signos vitales) · **I1** (el paciente ve sus vitales y recetas, sin la nota interna del médico). Todo Elite, colgando de la cita (`Encounter` + `Prescription` por `appointment`).

**Único pendiente del 2º audio:** **H4** (adjuntos / resultados de laboratorio) — requiere configurar almacenamiento de archivos (ActiveStorage + S3). Priorizar con el socio.
