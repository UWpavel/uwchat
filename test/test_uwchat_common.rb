require "test/unit"

require "uwchat"

class TestUwchatCommon < Test::Unit::TestCase
  
  def test_common_constants
    myconst = %w( HOST PORT MAXCONS )
        
    myconst.each do |constant|
      assert Uwchat::Common.const_defined? constant
    end
  end
  
  # a method to generate md5 is tested in uwchat server
  
end
