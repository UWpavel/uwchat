require "test/unit"
require "uwchat"

class TestUwchat < Test::Unit::TestCase
  
  def test_me
    assert_equal "Pavel Snagovsky", Uwchat::STUDENT
  end
  
  def test_constants
    myconst = %w( STUDENT VERSION )
    myconst.each do |constant|
      assert Uwchat.const_defined? constant 
    end
  end
  
end
