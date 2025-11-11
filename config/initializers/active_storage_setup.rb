# Configuración de Active Storage para Railway
# Este script asegura que los directorios necesarios existan

Rails.application.config.after_initialize do
  if Rails.env.production? && Rails.configuration.active_storage.service == :railway
    storage_path = "/storage/active_storage"

    # Crear directorio si no existe
    unless File.directory?(storage_path)
      begin
        FileUtils.mkdir_p(storage_path)
        puts "✅ Directorio de almacenamiento creado: #{storage_path}"
      rescue => e
        puts "⚠️  No se pudo crear el directorio #{storage_path}: #{e.message}"
        puts "   Verifica los permisos del volumen en Railway"
      end
    else
      puts "✅ Directorio de almacenamiento ya existe: #{storage_path}"
    end

    # Verificar permisos de escritura
    test_file = File.join(storage_path, "test_permissions_#{Time.now.to_i}.txt")
    begin
      File.write(test_file, "test")
      File.delete(test_file)
      puts "✅ Permisos de escritura verificados en: #{storage_path}"
    rescue => e
      puts "❌ Error de permisos en #{storage_path}: #{e.message}"
      puts "   El volumen puede estar montado como solo lectura"
    end
  end
end