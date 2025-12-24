namespace :storage do
  desc "Diagnóstico completo del almacenamiento en producción"
  task diagnose: :environment do
    puts "=== DIAGNÓSTICO DE ALMACENAMIENTO ==="
    puts "Entorno: #{Rails.env}"
    puts "Servicio configurado: #{Rails.configuration.active_storage.service}"

    # Verificar configuración de servicios
    puts "\n📋 Configuración de servicios:"
    services_config = Rails.configuration.active_storage.service_configurations
    services_config.each do |name, config|
      puts "   #{name}: #{config.inspect}"
    end

    # Verificar servicio actual
    current_service = ActiveStorage::Blob.service
    puts "\n🔧 Servicio actual: #{current_service.class}"
    puts "   Ruta: #{current_service.root if current_service.respond_to?(:root)}"

    # Verificar archivos existentes
    puts "\n📊 Estadísticas de archivos:"
    total_blobs = ActiveStorage::Blob.count
    puts "   Total archivos en DB: #{total_blobs}"

    # Verificar si los archivos existen en el servicio actual
    if total_blobs > 0
      puts "\n🔍 Verificando archivos en el servicio actual:"
      sample_blobs = ActiveStorage::Blob.limit(5)
      sample_blobs.each do |blob|
        exists = current_service.exist?(blob.key) rescue false
        status = exists ? "✅" : "❌"
        puts "   #{status} #{blob.key} (#{blob.filename})"
      end
    end

    # Verificar variables de entorno
    puts "\n🌍 Variables de entorno relevantes:"
    env_vars = ['RAILS_STORAGE_PATH', 'RAILS_ENV']
    env_vars.each do |var|
      value = ENV[var]
      puts "   #{var}: #{value || 'NO DEFINIDA'}"
    end

    # Verificar directorios
    puts "\n📁 Estado de directorios:"
    paths_to_check = [
      Rails.root.join('storage'),
      '/storage',
      ENV['RAILS_STORAGE_PATH']
    ].compact.uniq

    paths_to_check.each do |path|
      if File.directory?(path)
        puts "   ✅ #{path} - EXISTE"
        # Verificar permisos
        test_file = File.join(path, "test_diagnose_#{Time.now.to_i}.txt")
        begin
          File.write(test_file, "test")
          File.delete(test_file)
          puts "      ✅ Permisos de escritura: OK"
        rescue => e
          puts "      ❌ Permisos de escritura: #{e.message}"
        end
      else
        puts "   ❌ #{path} - NO EXISTE"
      end
    end

    puts "\n=== DIAGNÓSTICO COMPLETADO ==="
  end
end