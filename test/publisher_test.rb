require 'test_helper'

class PublisherTest < ActiveSupport::TestCase
  context "shoulda test" do
    should "work" do
      assert_contains(['a', '1'], 'a')
    end
  end
end
