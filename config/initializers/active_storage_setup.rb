# Configuración de Active Storage para Railway
# Usa la variable RAILS_STORAGE_PATH proporcionada por Railway

Rails.application.config.after_initialize do
  if Rails.env.production? && Rails.configuration.active_storage.service == :railway

    puts "🔍 Configurando almacenamiento Railway..."

    # Obtener la ruta del volumen desde la variable de entorno de Railway
    storage_path = ENV['RAILS_STORAGE_PATH']
    puts "   Variable RAILS_STORAGE_PATH: #{storage_path}"

    if storage_path && File.directory?(storage_path)
      puts "   📁 Directorio del volumen encontrado: #{storage_path}"

      # Verificar permisos de escritura
      test_file = File.join(storage_path, "test_permissions_#{Time.now.to_i}.txt")
      begin
        File.write(test_file, "test")
        File.delete(test_file)
        puts "   ✅ Permisos de escritura verificados"
        puts "✅ Almacenamiento Railway configurado correctamente en: #{storage_path}"
      rescue => e
        puts "   ❌ Error de permisos: #{e.message}"
        puts "   💡 El volumen puede estar montado como solo lectura"
        puts "   🔄 Cambiando a almacenamiento local..."
        Rails.configuration.active_storage.service = :local
      end
    else
      puts "   ❌ No se encontró el directorio del volumen: #{storage_path}"
      puts "   🔄 Cambiando a almacenamiento local..."
      Rails.configuration.active_storage.service = :local
    end
  end
end