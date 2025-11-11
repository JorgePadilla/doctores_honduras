namespace :storage do
  desc "Migrar archivos de Active Storage al servicio railway"
  task migrate_to_railway: :environment do
    puts "=== Migración de Active Storage a Railway ==="

    # Verificar configuración actual
    current_service = Rails.configuration.active_storage.service
    puts "Servicio actual: #{current_service}"

    if current_service != :railway
      puts "⚠️  ADVERTENCIA: El servicio actual no es 'railway'. Actualmente es: #{current_service}"
      puts "   Ejecuta: RAILS_ENV=production bin/rails storage:migrate_to_railway"
      next
    end

    # Contar archivos existentes
    total_blobs = ActiveStorage::Blob.count
    puts "Total de archivos en la base de datos: #{total_blobs}"

    # Verificar archivos que necesitan migración
    migrated_count = 0
    error_count = 0

    ActiveStorage::Blob.find_each do |blob|
      begin
        # Verificar si el archivo existe en el servicio actual
        if blob.service.exist?(blob.key)
          puts "✅ Archivo #{blob.key} ya existe en el servicio railway"
          migrated_count += 1
        else
          puts "⚠️  Archivo #{blob.key} NO existe en el servicio railway"
          error_count += 1
        end
      rescue => e
        puts "❌ Error verificando archivo #{blob.key}: #{e.message}"
        error_count += 1
      end
    end

    puts "\n=== Resumen de Migración ==="
    puts "Total archivos: #{total_blobs}"
    puts "Archivos migrados: #{migrated_count}"
    puts "Archivos con error: #{error_count}"

    if error_count > 0
      puts "\n⚠️  Algunos archivos necesitan ser re-subidos manualmente"
    else
      puts "\n✅ Todos los archivos están en el servicio railway"
    end
  end

  desc "Verificar estado del almacenamiento"
  task check: :environment do
    puts "=== Verificación de Almacenamiento ==="

    service = ActiveStorage::Blob.service
    puts "Servicio: #{Rails.configuration.active_storage.service}"
    puts "Clase del servicio: #{service.class}"

    # Verificar si podemos escribir
    test_key = "test-#{Time.now.to_i}.txt"
    begin
      service.upload(test_key, StringIO.new("test"))
      service.exist?(test_key)
      service.delete(test_key)
      puts "✅ Servicio funcionando correctamente"
    rescue => e
      puts "❌ Error en el servicio: #{e.message}"
    end

    # Verificar archivos existentes
    total_blobs = ActiveStorage::Blob.count
    puts "Total de archivos en DB: #{total_blobs}"

    # Verificar algunos archivos aleatorios
    sample_blobs = ActiveStorage::Blob.limit(5)
    puts "\nMuestra de archivos:"
    sample_blobs.each do |blob|
      exists = service.exist?(blob.key) rescue false
      status = exists ? "✅" : "❌"
      puts "  #{status} #{blob.key} (#{blob.filename})"
    end
  end
end