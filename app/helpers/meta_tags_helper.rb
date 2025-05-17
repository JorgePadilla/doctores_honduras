module MetaTagsHelper
  def meta_title(title)
    content_for(:title) { title }
  end

  def meta_description(desc)
    content_for(:meta_description) { desc }
  end

  def meta_keywords(keywords)
    content_for(:meta_keywords) { keywords }
  end

  def meta_image(image)
    content_for(:og_image) { image }
  end

  def canonical_url(url)
    content_for(:canonical_url) { url }
  end

  # Helper to set all meta tags at once
  def set_meta_tags(options = {})
    meta_title(options[:title]) if options[:title].present?
    meta_description(options[:description]) if options[:description].present?
    meta_keywords(options[:keywords]) if options[:keywords].present?
    meta_image(options[:image]) if options[:image].present?
    canonical_url(options[:canonical]) if options[:canonical].present?
  end
end
