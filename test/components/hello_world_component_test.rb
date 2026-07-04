# frozen_string_literal: true

require "test_helper"

class HelloWorldComponentTest < ViewComponent::TestCase
  def test_component_renders_its_template
    render_inline(HelloWorldComponent.new)
    assert_text "Add HelloWorld template here"
  end
end
