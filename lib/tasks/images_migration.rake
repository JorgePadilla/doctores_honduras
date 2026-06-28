require "open-uri"

namespace :images do
  desc "Migrate existing images to S3 as optimized WebP variants (set DRY_RUN=1 to preview)"
  task migrate_to_s3: :environment do
    dry_run = ENV["DRY_RUN"].present?
    bucket = ENV["AWS_BUCKET"].to_s
    abort "AWS_BUCKET env var is required" if bucket.blank?

    # Each entry maps a model + image "slot" to its S3 folder and crop policy,
    # mirroring the has_uploadable_image declarations on the models.
    slots = [
      { model: "DoctorProfile", name: :image,          folder: "doctor_profiles",         crop: true  },
      { model: "Establishment", name: :logo,           folder: "establishments/logos",    crop: false },
      { model: "Establishment", name: :building_image, folder: "establishments/buildings", crop: true  },
      { model: "Supplier",      name: :logo,           folder: "suppliers",               crop: false },
      { model: "Product",       name: :image,          folder: "products",                crop: true  }
    ]

    # An image is considered migrated only when the full URL is our processed WebP on S3
    # AND a thumbnail exists. Raw S3 uploads (old service) or missing thumbs get reprocessed.
    migrated = ->(url, thumb) do
      url.to_s.include?("#{bucket}.s3") && url.to_s.end_with?("_full.webp") && thumb.present?
    end

    download = ->(url) do
      ext = File.extname(URI.parse(url).path).presence || ".img"
      tmp = Tempfile.new([ "img_src", ext ], binmode: true)
      URI.parse(url).open("rb") { |io| IO.copy_stream(io, tmp) }
      tmp.flush
      tmp.rewind
      tmp
    end

    puts "=== Image migration to S3 (#{dry_run ? 'DRY RUN' : 'LIVE'}) ==="
    puts "Bucket: #{bucket}\n\n"

    totals = Hash.new(0)

    slots.each do |slot|
      model = slot[:model].constantize
      url_attr = "#{slot[:name]}_url"
      thumb_attr = "#{slot[:name]}_thumb_url"

      scope = model.where.not(url_attr => [ nil, "" ])
      puts "-- #{slot[:model]}##{slot[:name]} (#{scope.count} with an image) --"

      scope.find_each do |record|
        source = record.public_send(url_attr)

        if migrated.call(source, record.public_send(thumb_attr))
          totals[:skipped] += 1
          next
        end

        unless source.to_s.start_with?("http")
          puts "  ⚠️  ##{record.id}: non-absolute URL, skipping (#{source})"
          totals[:skipped] += 1
          next
        end

        if dry_run
          puts "  → ##{record.id}: would migrate #{source}"
          totals[:would_migrate] += 1
          next
        end

        tmp = nil
        begin
          tmp = download.call(source)
          result = ImageUploadService.new.process_and_upload(tmp.path, folder: slot[:folder], crop: slot[:crop])

          if result
            record.update_columns(url_attr => result[:url], thumb_attr => result[:thumb_url])
            puts "  ✅ ##{record.id}: #{result[:url]}"
            totals[:migrated] += 1
          else
            puts "  ❌ ##{record.id}: processing failed"
            totals[:errors] += 1
          end
        rescue => e
          puts "  ❌ ##{record.id}: #{e.class} - #{e.message}"
          totals[:errors] += 1
        ensure
          if tmp
            tmp.close
            tmp.unlink
          end
        end
      end
      puts ""
    end

    puts "=== Summary ==="
    if dry_run
      puts "Would migrate: #{totals[:would_migrate]}   Already migrated/skipped: #{totals[:skipped]}"
      puts "\nRun without DRY_RUN to perform the migration."
    else
      puts "Migrated: #{totals[:migrated]}   Skipped: #{totals[:skipped]}   Errors: #{totals[:errors]}"
    end
  end
end
