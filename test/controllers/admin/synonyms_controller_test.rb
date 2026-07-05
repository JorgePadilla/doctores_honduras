require "test_helper"

class Admin::SynonymsControllerTest < ActionDispatch::IntegrationTest
  test "non-admin is redirected away" do
    sign_in_as users(:one)
    get admin_synonyms_url
    assert_redirected_to root_path
  end

  test "admin can view the synonyms page" do
    sign_in_as users(:admin)
    get admin_synonyms_url
    assert_response :success
  end

  test "admin can create a synonym" do
    sign_in_as users(:admin)
    assert_difference -> { SearchSynonym.count }, 1 do
      post admin_synonyms_url, params: { search_synonym: { term: "Caries", keywords: "Endodoncia, Limpieza Dental" } }
    end
    assert_equal "caries", SearchSynonym.last.term
  end

  test "admin can update a synonym" do
    synonym = SearchSynonym.create!(term: "caries", keywords: "Endodoncia")
    sign_in_as users(:admin)
    patch admin_synonym_url(synonym), params: { search_synonym: { term: "caries", keywords: "Endodoncia, Odontología" } }
    assert_equal "Endodoncia, Odontología", synonym.reload.keywords
  end

  test "admin can delete a synonym" do
    synonym = SearchSynonym.create!(term: "caries", keywords: "Endodoncia")
    sign_in_as users(:admin)
    assert_difference -> { SearchSynonym.count }, -1 do
      delete admin_synonym_url(synonym)
    end
  end
end
