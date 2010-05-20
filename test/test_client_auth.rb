require "test/unit"
require "rubygems"
require "mocha"

require "uwchat"

class TestClientAuth < Test::Unit::TestCase
  
  def setup
    @session = stubs( :puts )   

    @client = Uwchat::AuthClient.new( @session )
  end
  
  def test_uwchat_items
    assert_respond_to( @client, :logger )
    assert_respond_to( @client, :chksum )
    
    assert_not_nil(Uwchat::AuthClient::PORT)
    assert_not_nil(Uwchat::AuthClient::HOST)
    assert_not_nil(Uwchat::AuthClient::MAXCONS)
    
    str = "some_string"
    
    expected  = Digest::MD5.hexdigest( str )
    actual    = @client.chksum( str )
    
    assert_equal expected, actual
  end
  
end