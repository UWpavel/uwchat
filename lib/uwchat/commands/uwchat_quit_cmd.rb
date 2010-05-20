class QuitCommand < Uwchat::ServerCommand
  command :quit
  description "Disconnect from the server."
  
  when_run do | server, io |
    sender = server.clients.invert[io]
    io.puts "Bye."
    io.close
    server.client_left( sender )
  end
  
end