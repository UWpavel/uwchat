require 'gserver'

class Uwchat::Server < GServer
  
  def self.register_cmd( klass )
    @@commands ||= []
    @@commands << klass
  end
  
  include Uwchat::Common
  attr_reader :clients, :my_commands
  
  def initialize( port = PORT, host = HOST, *args )
    super( port, host, *args )
    @clients = {}
    @my_commands = {}
    @@commands.each {|c| @my_commands[c.name] = c }
  end

  def serve( io )
    begin
      nick = new_client( io )     
      while msg = io.gets
        self.logger ">>> Incoming from #{nick}: #{msg.chomp}"
        if msg =~ /^\//
          self.process_command( nick, msg )
        else
          self.process_msg( nick, msg ) unless msg.chomp.strip.empty?
        end
      end
    rescue Exception => e
      puts e.message
      raise
    end
  end 

  # Broadcasting message to all clients
  def process_msg( sender, msg )
    self.check_connections
    @clients.each do |user, io|
      io.puts( "<#{sender}> #{msg}") unless sender == user
    end
  end  

  # Take care of incoming clients
  def new_client( io )
    auth = Uwchat::AuthServer.new
    return io.close unless auth.auth_sequence( io )
    new_user = auth.user
    self.user_welcome( new_user, io ) if self.test_user?(new_user, io)
    return new_user
  end

  # Testing if incoming user already connected
  def test_user?( user, io )
    self.check_connections
    if @clients.has_key?( user )
      io.puts "Connection denied: \"#{user}\" is in use, connected from: #{@clients[user].peeraddr[2]}."
      self.logger "Denied login for \"#{user}\" from #{io.peeraddr[2]}, username is in use."
      io.close
      return false
    end
    return true
  end

  # User welcome or not
  def user_welcome( user, io )
    @clients[ user ] = io
    io.puts "Welcome #{user}. For help enter: /help."
    self.process_msg "ChatServer", "\"#{user}\" joined the chat."
    self.logger "\"#{user}\" joined the chat."
  end
  
  def check_connections
    @clients.each do |user, io|
      self.client_left( user) if io.closed?
    end
  end

  # Remove a client (at this point connection is closed)
  def client_left( user )
    @clients.delete( user )
    msg = "\"#{user}\" no longer connected."
    self.logger( msg )
    self.process_msg( "ChatServer", msg )
  end
  
  def command_registered?( name )
    return @my_commands.keys.include?( name )
  end
  
  # Handle incomming commands
  def process_command( sender, cmd_name )
    if name = self.cmd_name_check( cmd_name )
      self.logger "\"#{sender}\" executed /#{name}"
      @my_commands[ name ].action.call( self, @clients[sender] )
    else
      self.unknown_command( sender )
    end
  end
  
  def cmd_name_check( cmd_name )
    name = cmd_name.chomp.gsub(/\//,'').strip
    return false if name.empty?
    return name.to_sym if self.command_registered?( name.to_sym )
  end
  
  def unknown_command( sender )
    @clients[sender].puts "Unknown command."
    self.logger "#{sender} submitted unknown command"
  end

end