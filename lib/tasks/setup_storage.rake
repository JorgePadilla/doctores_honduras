namespace :storage do
  desc "Crear directorio de almacenamiento en Railway"
  task setup: :environment do
    puts "=== CONFIGURACIÓN DE ALMACENAMIENTO ==="
    puts "Entorno: #{Rails.env}"

    storage_path = Rails.env.production? ? '/app/storage' : Rails.root.join('storage')
    puts "Ruta de almacenamiento: #{storage_path}"

    if File.directory?(storage_path)
      puts "✅ Directorio ya existe: #{storage_path}"
    else
      begin
        FileUtils.mkdir_p(storage_path)
        puts "✅ Directorio creado: #{storage_path}"
      rescue => e
        puts "❌ Error creando directorio: #{e.message}"
      end
    end

    # Verificar permisos
    if File.writable?(storage_path)
      puts "✅ Permisos de escritura: OK"
    else
      puts "❌ Permisos de escritura: FALLIDO"
    end

    puts "=== CONFIGURACIÓN COMPLETADA ==="
  end
end