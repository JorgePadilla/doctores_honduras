class Admin::SettingsController < Admin::BaseController
  def index
  end

  def update
    SiteSetting::SECTIONS.each_key do |key|
      enabled = ActiveModel::Type::Boolean.new.cast(params.dig(:sections, key))
      SiteSetting.find_or_initialize_by(key: key).update!(enabled: enabled)
    end
    redirect_to admin_settings_path, notice: "Configuración actualizada."
  end
end
