# Declarative image upload for a model "slot". For each declared slot it provides:
#   * a virtual attribute  <name>_file        (the uploaded file)
#   * validation of content-type and size
#   * a before_save that converts to two WebP variants on S3 (via ImageUploadService)
#     and writes  <name>_url  and  <name>_thumb_url
#
# Usage:
#   include HasUploadableImage
#   has_uploadable_image :image, folder: "doctor_profiles"            # photo (cover-cropped thumb)
#   has_uploadable_image :logo,  folder: "suppliers", crop: false     # logo  (contained thumb)
module HasUploadableImage
  extend ActiveSupport::Concern

  ALLOWED_CONTENT_TYPES = %w[image/jpeg image/png image/jpg image/gif image/webp image/avif].freeze
  MAX_SIZE = 5.megabytes

  class_methods do
    def has_uploadable_image(name, folder:, crop: true)
      file_attr  = "#{name}_file"
      url_attr   = "#{name}_url"
      thumb_attr = "#{name}_thumb_url"

      attr_accessor file_attr

      validate do
        file = public_send(file_attr)
        next if file.blank?

        unless file.respond_to?(:content_type) && file.content_type.in?(ALLOWED_CONTENT_TYPES)
          errors.add(file_attr, "debe ser JPEG, PNG, GIF, WebP o AVIF")
        end
        if file.respond_to?(:size) && file.size > MAX_SIZE
          errors.add(file_attr, "es demasiado grande (máximo 5MB)")
        end
      end

      before_save do
        file = public_send(file_attr)
        next if file.blank?

        service = ImageUploadService.new
        result = service.process_and_upload(file, folder: folder, crop: crop)

        if result
          public_send("#{url_attr}=", result[:url])
          public_send("#{thumb_attr}=", result[:thumb_url])
        else
          errors.add(file_attr, "no se pudo subir a S3: #{service.last_error&.message || 'error desconocido'}")
          throw :abort
        end
      end
    end
  end
end
