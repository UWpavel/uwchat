require "test/unit"
require "rubygems"
require "mocha"

require "uwchat"

class TestUwchatServer < Test::Unit::TestCase
  
  def setup
    port = 12345
    @users = %w( user100 user101 user102 )
    clients = {}
    @test_msg = "test message"
    
    # mocking io, will overwrite in tests as needed 
    @io = stub( 'io_mock',
      :gets     => "send",
      :puts     => "receive",
      :close    => "closed",
      :closed?  => false,
      :peeraddr => [1, 2, 'localhost'] )
    
    @users.each { |u| clients[u] = @io }
    
    # mock cmd class instance
    cmd = stub( 'cmd_mock',
      :name   => "cmd",
      :desc   => "moked cmd",
      :action => Proc.new { puts "mocked cmd action called" } )
    
    @server = Uwchat::Server.new( port )
    # giving our server few clients to our server with no security in mind
    @server.instance_variable_set( :@clients, clients )
    # overwrite real commands with mocked one, we will save them first for later use 
    # I might add real commands later in tests or test commands separetly
    @real_commands = @server.instance_variable_get( :@my_commands )
    @server.instance_variable_set( :@my_commands, { :cmd => cmd })
  end
  
  def test_uwchat_items
    assert_respond_to( @server, :logger )
    assert_respond_to( @server, :chksum )
    
    assert_not_nil(Uwchat::Server::PORT)
    assert_not_nil(Uwchat::Server::HOST)
    assert_not_nil(Uwchat::Server::MAXCONS)
    
    str = "some_string"
    
    expected  = Digest::MD5.hexdigest( str )
    actual    = @server.chksum( str )
    
    assert_equal expected, actual
  end
  
  def test_chksum_handles_multistr
    str1, str2, str3 = "one", "two", "three"
    
    expected  = Digest::MD5.hexdigest( str1 + str2 + str3 )
    actual    = @server.chksum( str1, str2, str3 )
    
    assert_equal expected, actual
  end
   
  def test_new_user
    user = "user0"
    
    aserver = mock('auth-server')
    aserver.expects( :user ).returns( user )
    aserver.expects( :auth_sequence ).with( @io ).returns( true )
    Uwchat::AuthServer.expects( :new ).returns( aserver )
    # create 'user0'
    @server.new_client( @io )
    
    expected = false
    actual = @server.clients[user].closed?
    
    assert_equal expected, actual
  end
  
  def test_client_removal
    user = @users.first
    
    before = @server.clients.size
    @server.client_left( user )
    after = @server.clients.size
    
    assert before > after
  end
  
  def test_process_msg
    users = @server.clients.size
    @io.expects( :puts ).times( users - 1 )    
    
    assert @server.process_msg( @users.last, @test_msg )
  end
  
  def test_process_msg_removes_client_with_closed_con
    before = @server.clients.size
    @io.expects( :closed? ).returns( true )
    @server.process_msg( @users.last, @test_msg )
    after = @server.clients.size
    
    assert_not_equal before, after
  end
  
  def test_testing_user
    user = @users.last
    assert  @server.clients[user]
    
    actual = @server.test_user?( user, @io )
    assert_equal false, actual
  end
  
  def test_testing_user_allow
    user = "not_conected"    
    assert_nil  @server.clients[user]
    
    assert @server.test_user?( user, @io ) 
  end    
  
  def test_testing_user_closes_connection
    user = @users.last
    
    assert @io.expects( :close ).once    
    @server.test_user?( user, @io )
  end
  
  def test_user_welcome_adds_user
    user = "user00"
    assert_nil  @server.clients[user]
    
    before = @server.clients.size
    @server.user_welcome( user, @io )
    after = @server.clients.size
    
    assert before < after
  end
  
  def test_check_connections    
    before = @server.clients.size

    @io.expects( :closed? ).returns( true )
    @server.check_connections
    after = @server.clients.size
    
    assert before > after
  end
  
  def test_process_unknown_command
    user, command = @users.last, "fake_cmd"
    
    assert @server.expects( :unknown_command ).with( user ).once
    @server.process_command( user, command )
  end
  
  def test_process_command
    user, command = @users.last, "cmd"
    @server.process_command( user, command )   
  end
  
  def test_cmd_name_check
    expected = :cmd
    actual = @server.cmd_name_check( "/  cmd \n")
    assert_equal expected, actual
  end
  
  def test_cmd_check_empty_command
    cmd = "/\n"
    actual = @server.cmd_name_check( cmd )
    assert_equal false, actual
  end
  
  def test_cmd_check_unregisterd_command
    cmd = "/fake\n"  
    actual = @server.cmd_name_check( cmd )
    assert_nil actual
  end
  
  # Testing default commands, more testing is in test_uwchat_server_command. 
  def test_client_quit_command
    # Replacing mocked command with the real commands
    @server.instance_variable_set( :@my_commands, @real_commands )
    
    user = @users.last
    # insure we have the user
    assert  @server.clients[user]
    
    before = @server.clients.size
    @server.process_command( user, "/quit" )
    after = @server.clients.size
    
    assert_not_equal before, after
    assert_nil @server.clients[user]
  end
  
end
