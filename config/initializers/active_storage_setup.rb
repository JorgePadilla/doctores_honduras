# Configuración de Active Storage para Railway
# Usa la variable RAILS_STORAGE_PATH proporcionada por Railway

Rails.application.config.after_initialize do
  if Rails.env.production?
    puts "🔍 Inicializando Active Storage en producción..."
    puts "   Servicio configurado: #{Rails.configuration.active_storage.service}"

    if Rails.configuration.active_storage.service == :railway
      puts "   🚂 Intentando usar servicio Railway..."

      # Obtener la ruta del volumen desde la variable de entorno de Railway
      storage_path = ENV['RAILS_STORAGE_PATH']
      puts "   📍 Variable RAILS_STORAGE_PATH: #{storage_path}"

      # Verificar si el directorio existe y es escribible
      if storage_path && File.directory?(storage_path) && File.writable?(storage_path)
        puts "   📁 Directorio del volumen encontrado y escribible: #{storage_path}"
        puts "✅ Almacenamiento Railway configurado correctamente en: #{storage_path}"
      else
        puts "   ❌ Volumen no disponible o no escribible: #{storage_path}"

        # Usar /app/storage como directorio escribible
        app_storage_path = '/app/storage'
        puts "   📁 Usando directorio de aplicación: #{app_storage_path}"

        # Crear directorio si no existe
        unless File.directory?(app_storage_path)
          begin
            FileUtils.mkdir_p(app_storage_path)
            puts "   📁 Directorio creado: #{app_storage_path}"
          rescue => e
            puts "   ❌ No se pudo crear directorio: #{e.message}"
          end
        end

        # Verificar permisos de escritura
        if File.writable?(app_storage_path)
          puts "   ✅ Permisos de escritura verificados en #{app_storage_path}"
          puts "✅ Almacenamiento configurado correctamente en: #{app_storage_path}"
        else
          puts "   ❌ Error de permisos en #{app_storage_path}"
          puts "   🔄 Cambiando a almacenamiento local..."
          Rails.configuration.active_storage.service = :local
        end
      end
    end

    # Mostrar servicio final
    puts "   ✅ Servicio final: #{Rails.configuration.active_storage.service}"
    current_service = ActiveStorage::Blob.service
    puts "   📍 Ruta final: #{current_service.root if current_service.respond_to?(:root)}"
  end
end