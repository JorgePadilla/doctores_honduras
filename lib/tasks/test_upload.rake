namespace :storage do
  desc "Probar subida de archivos en el servicio actual"
  task test_upload: :environment do
    puts "=== PRUEBA DE SUBIDA DE ARCHIVOS ==="
    puts "Entorno: #{Rails.env}"
    puts "Servicio: #{Rails.configuration.active_storage.service}"

    service = ActiveStorage::Blob.service
    puts "Servicio actual: #{service.class}"
    puts "Ruta: #{service.root if service.respond_to?(:root)}"

    # Probar subida de un archivo pequeño
    test_content = "Este es un archivo de prueba generado el #{Time.now}"
    test_key = "test_upload_#{Time.now.to_i}.txt"

    begin
      puts "\n📤 Intentando subir archivo de prueba..."
      service.upload(test_key, StringIO.new(test_content))
      puts "✅ Archivo subido exitosamente"

      # Verificar que existe
      puts "🔍 Verificando que el archivo existe..."
      if service.exist?(test_key)
        puts "✅ Archivo encontrado en el servicio"
      else
        puts "❌ Archivo NO encontrado en el servicio"
      end

      # Leer el contenido
      puts "📖 Leyendo contenido del archivo..."
      downloaded = service.download(test_key)
      puts "✅ Contenido leído: #{downloaded.bytesize} bytes"

      # Eliminar el archivo de prueba
      puts "🗑️  Eliminando archivo de prueba..."
      service.delete(test_key)
      puts "✅ Archivo eliminado"

      puts "\n🎉 ¡Prueba de subida EXITOSA!"

    rescue => e
      puts "\n❌ ERROR durante la prueba:"
      puts "   Tipo: #{e.class}"
      puts "   Mensaje: #{e.message}"
      puts "   Backtrace:"
      e.backtrace.first(5).each { |line| puts "     #{line}" }
      puts "\n💡 Posibles causas:"
      puts "   - Permisos insuficientes en el directorio"
      puts "   - El volumen está montado como solo lectura"
      puts "   - Espacio insuficiente en disco"
    end

    # Verificar configuración de Active Storage
    puts "\n⚙️  Configuración de Active Storage:"
    puts "   Service: #{Rails.configuration.active_storage.service}"
    puts "   Service configurations: #{Rails.configuration.active_storage.service_configurations.inspect}"

    # Verificar variables de entorno
    puts "\n🌍 Variables de entorno:"
    puts "   RAILS_STORAGE_PATH: #{ENV['RAILS_STORAGE_PATH']}"
    puts "   RAILS_ENV: #{ENV['RAILS_ENV']}"
  end

  desc "Verificar estado del almacenamiento actual"
  task check_current: :environment do
    puts "=== ESTADO ACTUAL DEL ALMACENAMIENTO ==="

    service = ActiveStorage::Blob.service
    puts "Servicio: #{service.class}"
    puts "Ruta: #{service.root if service.respond_to?(:root)}"

    # Verificar si podemos escribir
    test_key = "health_check_#{Time.now.to_i}.txt"
    begin
      service.upload(test_key, StringIO.new("health check"))
      exists = service.exist?(test_key)
      service.delete(test_key)

      if exists
        puts "✅ Estado: FUNCIONANDO - Puede leer y escribir"
      else
        puts "⚠️  Estado: PROBLEMÁTICO - Puede escribir pero no leer"
      end
    rescue => e
      puts "❌ Estado: FALLIDO - #{e.message}"
    end

    # Verificar archivos existentes
    total_blobs = ActiveStorage::Blob.count
    puts "Archivos en base de datos: #{total_blobs}"

    if total_blobs > 0
      puts "\n🔍 Verificando archivos existentes:"
      ActiveStorage::Blob.limit(3).each do |blob|
        exists = service.exist?(blob.key) rescue false
        status = exists ? "✅" : "❌"
        puts "   #{status} #{blob.filename} (#{blob.key})"
      end
    end
  end
end