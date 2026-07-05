# Pendientes (ops / seguimiento)

> Estado de código: el **2º audio (expediente clínico) está completo** — F1, G1, G2, G3, H1–H4, I1 entregados, testeados y en `main`. El **1º audio (A/B/C)** también. Lo que sigue abajo es **operativo/seguridad**, no desarrollo, salvo el hardening opcional.

Última actualización: 2026-07-05.

---

## 🔴 Crítico / bloquea funcionalidad en producción

### 1. Rotar las llaves AWS filtradas
Las credenciales AWS estuvieron expuestas (ver `memory/aws-keys-leaked-rotate.md`). Ahora es **más urgente** porque el expediente guarda **datos médicos** en S3 (H4). Rotar `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` y actualizarlas en Railway **antes** de habilitar los adjuntos.

### 2. Crear el bucket S3 privado para adjuntos (H4)
Los adjuntos de laboratorio son datos médicos privados y **no** pueden ir al bucket público de imágenes.
- [ ] Crear un bucket S3 **privado** (sin política de lectura pública, sin ACL público).
- [ ] Setear `AWS_PRIVATE_BUCKET` en Railway (y confirmar `AWS_REGION`, credenciales).
- Producción ya está configurada: `config.active_storage.service = :amazon_private` (servicio `amazon_private` en `config/storage.yml`, URLs firmadas).
- Hasta que exista el bucket, **subir un adjunto en prod falla** (no filtra datos: falla de forma segura). Las imágenes de perfil no se ven afectadas (usan `ImageUploadService` con su propio cliente S3 y el bucket público).

### 3. Correr `db:seed` en Railway (planes Elite)
`db:prepare` (deploy) corre migraciones pero **no** seeds. Los 3 niveles Elite ($35/$69/$129, techos 5k/25k/100k registros) y los precios actualizados **no aparecen** hasta correr las seeds:
```bash
railway ssh
bin/rails db:seed        # idempotente; la data demo está limitada a development
```
Verificar luego en `/settings/subscription` (con un usuario doctor) que aparezcan los 3 Elite con sus badges de capacidad.

---

## 🟡 Hardening recomendado (no bloquea)

### 4. Autorizar descargas de adjuntos por usuario (H4)
Hoy los enlaces a adjuntos usan URLs firmadas de ActiveStorage (`rails_blob_path`): no adivinables y expirantes, y las páginas que las listan están autenticadas (el médico ve solo sus citas; el paciente solo las suyas). Mejora futura: servir las descargas a través de un controlador que verifique que el usuario puede acceder a **esa** cita, en vez de depender solo de la firma del blob.

### 5. Límites de subida de archivos
Hoy: PDF/imágenes hasta 10 MB, validado en `Agenda::AttachmentsController`. Revisar si conviene ajustar tipos/tamaño o agregar análisis de virus según crezca el uso.

---

## 🟢 Backlog de producto (priorizar con el socio)

- Ninguna épica pendiente del 1º ni 2º audio. Ver `docs/backlog-feedback-medico.md` para el detalle e ideas futuras (p. ej. expediente **compartido/longitudinal** entre médicos, hoy es **por-médico**).
