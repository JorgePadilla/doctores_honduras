require "aws-sdk-s3"

# Service to handle uploading files to AWS S3
#
# Requires a S3 Bucket Policy for public reads instead of per-object ACLs.
# Example bucket policy:
#   {
#     "Version": "2012-10-17",
#     "Statement": [{
#       "Sid": "PublicReadGetObject",
#       "Effect": "Allow",
#       "Principal": "*",
#       "Action": "s3:GetObject",
#       "Resource": "arn:aws:s3:::YOUR_BUCKET_NAME/*"
#     }]
#   }
class S3UploadService
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

  # Upload a file to S3 and return the public URL
  def upload_file(file, filename = nil)
    filename ||= generate_filename(file)

    Rails.logger.info "S3 Upload: uploading #{filename} to bucket=#{@bucket_name} region=#{@region}"

    @s3_client.put_object(
      bucket: @bucket_name,
      key: filename,
      body: file.read,
      content_type: file.content_type
    )

    url = "https://#{@bucket_name}.s3.#{@region}.amazonaws.com/#{filename}"
    Rails.logger.info "S3 Upload: success -> #{url}"
    url
  rescue => e
    Rails.logger.error "S3 Upload Error: #{e.class} - #{e.message} (bucket=#{@bucket_name}, region=#{@region})"
    @last_error = e
    nil
  end

  private

  def generate_filename(file)
    timestamp = Time.current.strftime("%Y%m%d_%H%M%S")
    extension = File.extname(file.original_filename)
    "doctor_profiles/#{timestamp}_#{SecureRandom.hex(8)}#{extension}"
  end
end
