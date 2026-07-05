class SearchSynonym < ApplicationRecord
  # Maps a lay term a patient types (e.g. "caries", "apendicitis") to a list of
  # clinical keywords that match service/specialty names in the doctor search.
  # `term` is stored lowercased but WITH accents (so it reads correctly in the
  # admin panel); matching is accent-insensitive via #transliterate at query
  # time. `keywords` keep their accents so they match services.name.

  before_validation :normalize_term

  validates :term, presence: true, uniqueness: true
  validates :keywords, presence: true

  # Parsed, cleaned list of keywords.
  def keyword_list
    keywords.to_s.split(",").map(&:strip).reject(&:blank?)
  end

  # Storage form: lowercased + trimmed, accents preserved (human-readable).
  def self.normalize(str)
    str.to_s.downcase.strip
  end

  # Matching form: also strips accents so "azucar" matches stored "azúcar".
  def self.transliterate(str)
    I18n.transliterate(str.to_s).downcase.strip
  end

  # Given a raw search query, return LIKE patterns (lowercased, wildcarded) for
  # every matching synonym's keywords. E.g. "caries" -> ["%endodoncia%", ...].
  # Returns [] when nothing matches. Accent-insensitive on both sides.
  def self.expand(query)
    query_key = transliterate(query)
    return [] if query_key.blank?

    patterns = []
    all.each do |synonym|
      next unless query_key.include?(transliterate(synonym.term))

      synonym.keyword_list.each { |kw| patterns << "%#{kw.downcase}%" }
    end
    patterns.uniq
  end

  private

  def normalize_term
    self.term = self.class.normalize(term)
  end
end
