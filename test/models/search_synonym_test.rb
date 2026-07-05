require "test_helper"

class SearchSynonymTest < ActiveSupport::TestCase
  test "lowercases the term but keeps accents (human-readable) on save" do
    s = SearchSynonym.create!(term: "Apéndice", keywords: "Apendicectomía")
    assert_equal "apéndice", s.term
  end

  test "keyword_list parses comma-separated keywords" do
    s = SearchSynonym.new(keywords: "Endodoncia, Limpieza Dental ,, Odontología")
    assert_equal [ "Endodoncia", "Limpieza Dental", "Odontología" ], s.keyword_list
  end

  test "expand returns lowercased wildcard patterns for a matching term" do
    SearchSynonym.create!(term: "caries", keywords: "Endodoncia, Limpieza Dental")
    assert_equal [ "%endodoncia%", "%limpieza dental%" ], SearchSynonym.expand("caries")
  end

  test "expand is accent-insensitive and matches within a phrase" do
    SearchSynonym.create!(term: "apéndice", keywords: "Apendicectomía")
    assert_equal SearchSynonym.expand("apéndice"), SearchSynonym.expand("apendice")
    assert_equal [ "%apendicectomía%" ], SearchSynonym.expand("me duele el apendice")
  end

  test "expand returns empty for an unknown term" do
    assert_equal [], SearchSynonym.expand("terminoinexistente")
  end

  test "term must be unique" do
    SearchSynonym.create!(term: "caries", keywords: "a")
    dup = SearchSynonym.new(term: "Caries", keywords: "b")
    assert_not dup.valid?
  end
end
