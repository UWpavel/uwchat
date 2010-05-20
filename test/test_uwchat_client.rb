require "test/unit"
require "rubygems"
require "mocha"

require "uwchat"

class TestUwchatClient < Test::Unit::TestCase

  HOST, PORT = 'localhost', 12345
  
  def setup
    @session = mock( "setup_session" )
    @auth_client.stubs( :authenticate? ).returns("goaway")
    
    TCPSocket.stubs( :new ).with( HOST, PORT).returns( @session )
    Uwchat::AuthClient.stubs( :new ).with( @session ).returns( @auth_client )
    
    @chat_client = Uwchat::ChatClient.new( HOST, PORT )
  end
  
  def test_no_exception_connecting
    assert_nothing_raised( Exception ) { Uwchat::ChatClient.new( HOST, PORT) }
  end
  
  def test_authentication
    user, passwd = "bob", "pa$$word"
        
    assert @chat_client.expects( :chat ).returns( "chat" ).once 
    assert @chat_client.authenticate( user, passwd)
  end
  
end
