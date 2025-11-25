# Service to handle uploading files to AWS S3
class S3UploadService
  def initialize(bucket_name = nil)
    @bucket_name = bucket_name || ENV['AWS_BUCKET']
    @s3_client = Aws::S3::Client.new(
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      region: ENV['AWS_REGION'] || 'us-east-1'
    )
  end

  # Upload a file to S3 and return the public URL
  def upload_file(file, filename = nil)
    filename ||= generate_filename(file)

    @s3_client.put_object(
      bucket: @bucket_name,
      key: filename,
      body: file.read,
      acl: 'public-read',
      content_type: file.content_type
    )

    # Return the public URL
    "https://#{@bucket_name}.s3.#{ENV['AWS_REGION'] || 'us-east-1'}.amazonaws.com/#{filename}"
  rescue Aws::S3::Errors::ServiceError => e
    Rails.logger.error "S3 Upload Error: #{e.message}"
    nil
  end

  private

  def generate_filename(file)
    timestamp = Time.current.strftime('%Y%m%d_%H%M%S')
    extension = File.extname(file.original_filename)
    "doctor_profiles/#{timestamp}_#{SecureRandom.hex(8)}#{extension}"
  end
end