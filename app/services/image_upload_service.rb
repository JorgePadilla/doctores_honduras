require "aws-sdk-s3"
require "image_processing/vips"

# Processes an image into two optimized WebP variants and uploads them to S3.
#
# Returns { url: <full webp>, thumb_url: <thumb webp> } on success, or nil on failure
# (with the cause available via #last_error).
#
# Variants:
#   * full  -> longest edge <= FULL_MAX px, aspect preserved, quality FULL_QUALITY
#   * thumb -> THUMB_SIZE px square. crop: true  -> cover-crop (photos)
#                                    crop: false -> contained, no crop (logos)
#
# Requires a public-read S3 bucket policy (see README / .env: AWS_BUCKET, AWS_REGION,
# AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY). Uploads go through Rails, so no CORS needed.
class ImageUploadService
  FULL_MAX = 1000
  FULL_QUALITY = 82
  THUMB_SIZE = 400
  THUMB_QUALITY = 80
  CACHE_CONTROL = "public, max-age=31536000, immutable".freeze

  attr_reader :last_error

  def initialize(bucket_name = nil)
    @bucket_name = bucket_name || ENV["AWS_BUCKET"]
    @region = ENV["AWS_REGION"] || "us-east-1"

    raise "AWS_BUCKET env var is required for S3 uploads" if @bucket_name.blank?

    @s3_client = Aws::S3::Client.new(
      access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
      region: @region
    )
  end

  # file: an uploaded file (ActionDispatch::Http::UploadedFile), File, Tempfile, or path string.
  def process_and_upload(file, folder:, crop: true)
    source = source_path(file)
    base_key = "#{folder.chomp('/')}/#{SecureRandom.hex(12)}"

    full = build_full(source)
    thumb = build_thumb(source, crop: crop)

    full_url = upload_webp(full, "#{base_key}_full.webp")
    thumb_url = upload_webp(thumb, "#{base_key}_thumb.webp")

    return nil if full_url.nil? || thumb_url.nil?

    Rails.logger.info "ImageUpload: success folder=#{folder} -> #{full_url}"
    { url: full_url, thumb_url: thumb_url }
  rescue => e
    Rails.logger.error "ImageUpload Error: #{e.class} - #{e.message}"
    @last_error = e
    nil
  ensure
    [ full, thumb ].each { |t| t.close! if t.respond_to?(:close!) && !t.closed? }
  end

  private

  def source_path(file)
    if file.respond_to?(:tempfile)
      file.tempfile.path
    elsif file.respond_to?(:path)
      file.path
    else
      file.to_s
    end
  end

  def build_full(source)
    ImageProcessing::Vips
      .source(source)
      .convert("webp")
      .resize_to_limit(FULL_MAX, FULL_MAX)
      .saver(quality: FULL_QUALITY, strip: true)
      .call
  end

  def build_thumb(source, crop:)
    pipeline = ImageProcessing::Vips.source(source).convert("webp")
    pipeline = if crop
      pipeline.resize_to_fill(THUMB_SIZE, THUMB_SIZE)
    else
      pipeline.resize_to_limit(THUMB_SIZE, THUMB_SIZE)
    end
    pipeline.saver(quality: THUMB_QUALITY, strip: true).call
  end

  def upload_webp(tempfile, key)
    @s3_client.put_object(
      bucket: @bucket_name,
      key: key,
      body: File.binread(tempfile.path),
      content_type: "image/webp",
      cache_control: CACHE_CONTROL
    )
    "https://#{@bucket_name}.s3.#{@region}.amazonaws.com/#{key}"
  rescue => e
    Rails.logger.error "ImageUpload S3 Error (#{key}): #{e.class} - #{e.message}"
    @last_error = e
    nil
  end
end
