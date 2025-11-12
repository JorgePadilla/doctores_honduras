# Doctores Honduras

Una plataforma web para conectar pacientes con doctores especializados en Honduras. Permite a los doctores crear perfiles profesionales, mostrar sus especialidades y subespecialidades, y facilitar la búsqueda de profesionales médicos por ubicación y especialidad.

## 🚀 Características

- **Perfiles de Doctores**: Creación y gestión de perfiles profesionales
- **Especialidades y Subespecialidades**: Sistema completo de categorización médica
- **Búsqueda Avanzada**: Filtrado por ubicación (departamento/ciudad) y especialidad
- **Sistema de Autenticación**: Registro y login seguro para usuarios
- **Onboarding Guiado**: Proceso paso a paso para configurar perfiles
- **Subscripciones**: Sistema de planes con integración Stripe
- **Almacenamiento de Imágenes**: Subida de fotos de perfil con Active Storage
- **Responsive Design**: Interfaz adaptada para móviles y escritorio

## 🛠️ Tecnologías

- **Backend**: Ruby on Rails 8.0.2
- **Base de Datos**: PostgreSQL
- **Frontend**: Hotwire (Turbo + Stimulus)
- **Estilos**: Tailwind CSS 4.2
- **Autenticación**: Bcrypt
- **Pagos**: Stripe
- **Cache**: Solid Cache
- **Colas**: Solid Queue
- **WebSocket**: Solid Cable

## 📋 Requisitos Previos

- Ruby 3.3.9
- PostgreSQL 9.3+
- Node.js (para assets)
- Bundler

## ⚙️ Configuración del Desarrollo

### 1. Clonar el Repositorio

```bash
git clone <repository-url>
cd doctores_honduras
```

### 2. Instalar Dependencias

```bash
bundle install
```

### 3. Configurar Base de Datos

```bash
# Crear la base de datos
bin/rails db:create

# Ejecutar migraciones
bin/rails db:migrate

# Poblar con datos iniciales
bin/rails db:seed
```

### 4. Configurar Variables de Entorno

Crear un archivo `.env` en la raíz del proyecto con:

```bash
# Base de datos
DATABASE_URL=postgresql://localhost/doctores_honduras_development

# Stripe (opcional para desarrollo)
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...

# Active Storage - Desarrollo (local)
# Para producción usar AWS S3 (ver sección de despliegue)
RAILS_STORAGE_PATH=/data/storage

# AWS S3 (opcional para desarrollo, requerido para producción)
# AWS_ACCESS_KEY_ID=your_access_key
# AWS_SECRET_ACCESS_KEY=your_secret_key
# AWS_BUCKET=your_bucket_name
# AWS_REGION=us-east-1
```

### 5. Iniciar el Servidor

```bash
bin/rails server
```

La aplicación estará disponible en `http://localhost:3000`

## 🗄️ Base de Datos

### Estructura Principal

- **Users**: Usuarios del sistema
- **DoctorProfiles**: Perfiles profesionales de doctores
- **Specialties**: Especialidades médicas
- **Subspecialties**: Subespecialidades
- **Departments**: Departamentos de Honduras
- **Cities**: Ciudades por departamento
- **SubscriptionPlans**: Planes de suscripción
- **Subscriptions**: Suscripciones de usuarios

### Migraciones

Para aplicar migraciones pendientes:

```bash
bin/rails db:migrate
```

Para ver el estado de migraciones:

```bash
bin/rails db:migrate:status
```

## 🧪 Testing

### Ejecutar Tests

```bash
# Todos los tests
bin/rails test

# Tests específicos
bin/rails test test/models/doctor_profile_test.rb
bin/rails test test/controllers/profiles_controller_test.rb
```

### Linting

```bash
# Verificar estilo de código
bundle exec rubocop

# Autocorregir problemas
bundle exec rubocop -a
```

## 🚀 Despliegue

### Railway con AWS S3

La aplicación está configurada para desplegarse en Railway con AWS S3 para almacenamiento persistente:

1. **Conectar el repositorio a Railway**
2. **Configurar AWS S3** (ver sección de configuración S3 abajo)
3. **Configurar variables de entorno en Railway**:
   - `DATABASE_URL`
   - `RAILS_MASTER_KEY`
   - `STRIPE_PUBLISHABLE_KEY`
   - `STRIPE_SECRET_KEY`
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_BUCKET`
   - `AWS_REGION` (opcional, por defecto 'us-east-1')

### Configuración de AWS S3

1. **Crear bucket S3 en AWS Console**:
   - Ir a AWS S3 Console
   - Crear nuevo bucket con nombre único
   - Configurar región (ej: us-east-1)
   - Deshabilitar "Block all public access" si necesitas acceso público

2. **Crear usuario IAM**:
   - Ir a AWS IAM Console
   - Crear nuevo usuario con acceso programático
   - Adjuntar política `AmazonS3FullAccess` o crear política personalizada

3. **Configurar CORS (opcional)**:
   ```json
   [
     {
       "AllowedHeaders": ["*"],
       "AllowedMethods": ["GET", "PUT", "POST"],
       "AllowedOrigins": ["https://tu-dominio.railway.app"],
       "ExposeHeaders": []
     }
   ]
   ```

### Variables de Entorno para Producción

```bash
RAILS_ENV=production
DATABASE_URL=postgresql://...
RAILS_MASTER_KEY=...
STRIPE_PUBLISHABLE_KEY=pk_live_...
STRIPE_SECRET_KEY=sk_live_...

# AWS S3 Configuration
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
AWS_BUCKET=doctores-honduras-production
AWS_REGION=us-east-1
```

## 📁 Estructura del Proyecto

```
app/
├── controllers/          # Controladores
├── models/              # Modelos
├── views/               # Vistas
├── javascript/          # JavaScript con Stimulus
└── assets/              # Estilos y assets

config/
├── environments/        # Configuración por entorno
├── storage.yml          # Configuración de almacenamiento
└── routes.rb           # Rutas de la aplicación

db/
├── migrate/            # Migraciones de base de datos
├── seeds/              # Datos iniciales
└── schema.rb           # Esquema actual
```

## 🔧 Comandos Útiles

### Desarrollo

```bash
# Consola de Rails
bin/rails console

# Ver rutas
bin/rails routes

# Ver estado de migraciones
bin/rails db:migrate:status

# Ejecutar seeds específicos
bin/rails runner "require './db/seeds_specialties.rb'"
```

### Active Storage

```bash
# Verificar configuración de almacenamiento
bin/rails storage:check

# Diagnóstico de almacenamiento
bin/rails storage:diagnose

# Probar subida de archivos
bin/rails storage:test_upload
```

## 🤝 Contribución

1. Fork el proyecto
2. Crear una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir un Pull Request

## 📝 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 📞 Soporte

Si encuentras algún problema o tienes preguntas:

1. Revisa los logs de la aplicación
2. Verifica que todas las migraciones estén aplicadas
3. Asegúrate de que las variables de entorno estén configuradas correctamente
4. Abre un issue en el repositorio

---

**Doctores Honduras** - Conectando pacientes con los mejores doctores de Honduras 🇭🇳