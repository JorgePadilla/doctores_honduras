require "test_helper"

class SiteSettingTest < ActiveSupport::TestCase
  test "section_enabled? defaults to true for a missing key" do
    assert SiteSetting.section_enabled?("does_not_exist")
  end

  test "section_enabled? reflects the stored flag" do
    SiteSetting.find_or_create_by!(key: "suppliers").update!(enabled: false)
    assert_not SiteSetting.section_enabled?("suppliers")

    SiteSetting.find_by!(key: "suppliers").update!(enabled: true)
    assert SiteSetting.section_enabled?("suppliers")
  end

  test "enabled_map returns a key => enabled hash" do
    assert_equal true, SiteSetting.enabled_map["establishments"]
  end
end
