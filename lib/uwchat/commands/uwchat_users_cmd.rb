class UsersCommand < Uwchat::ServerCommand
  command :users
  description "List connected users."
  
  when_run do | server, io |
    user_list = server.clients.keys
    users_total = server.clients.size
    io.puts "#{users_total} user(s) on the server: #{user_list.inspect}"
  end
  
end