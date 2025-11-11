# Configuración de Active Storage para Railway
# Usar servicio local en producción para evitar problemas con volúmenes

Rails.application.config.after_initialize do
  if Rails.env.production?
    puts "🔍 Configurando Active Storage en producción..."

    # Forzar uso de servicio local en producción
    # Esto evita problemas con volúmenes de solo lectura
    Rails.configuration.active_storage.service = :local

    puts "   ✅ Servicio configurado: local"
    current_service = ActiveStorage::Blob.service
    puts "   📍 Ruta de almacenamiento: #{current_service.root if current_service.respond_to?(:root)}"
  end
end