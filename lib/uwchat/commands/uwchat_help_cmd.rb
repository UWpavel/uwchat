class HelpCommand < Uwchat::ServerCommand
  command :help
  description "This message."
  
  when_run do |server, io|
    
    help_msg = <<"HELP"
    Anything that is preceded by a slash will be considered a command.
    Anything else will be treated as a message.
    
    Currently on the server registered following commands:
HELP
    
    io.puts help_msg
    
    server.my_commands.each do |name, cmd|
      io.puts "\t#{name}: \t#{cmd.desc}"
    end
    
  end
  
end