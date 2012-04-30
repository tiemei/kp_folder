# conding: utf-8

require 'kp_folder'
require 'test/unit'

class ConfigTest < Test::Unit::TestCase
  def test_config
    assert_not_nil KpFolder::Config.consumer_key
    assert_not_nil KpFolder::Config.consumer_secret
  end
end
