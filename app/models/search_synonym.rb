class SearchSynonym < ApplicationRecord
  # Maps a lay term a patient types (e.g. "caries", "apendicitis") to a list of
  # clinical keywords that match service/specialty names in the doctor search.
  # `term` is normalized (lowercased, accent-stripped) for accent-insensitive
  # lookup; `keywords` keep their real accents so they match services.name.

  before_validation :normalize_term

  validates :term, presence: true, uniqueness: true
  validates :keywords, presence: true

  # Parsed, cleaned list of keywords.
  def keyword_list
    keywords.to_s.split(",").map(&:strip).reject(&:blank?)
  end

  # Lowercased, accent-stripped form of a string, for matching.
  def self.normalize(str)
    I18n.transliterate(str.to_s).downcase.strip
  end

  # Given a raw search query, return LIKE patterns (lowercased, wildcarded) for
  # every matching synonym's keywords. E.g. "caries" -> ["%endodoncia%", ...].
  # Returns [] when nothing matches.
  def self.expand(query)
    normalized_query = normalize(query)
    return [] if normalized_query.blank?

    patterns = []
    all.each do |synonym|
      next unless normalized_query.include?(synonym.term)

      synonym.keyword_list.each { |kw| patterns << "%#{kw.downcase}%" }
    end
    patterns.uniq
  end

  private

  def normalize_term
    self.term = self.class.normalize(term)
  end
end
