require "test/unit"
require "rubygems"
require "mocha"

require "uwchat"

class TestUwchatServerCommand < Test::Unit::TestCase

  # lets setup our own command
  class TestCommand < Uwchat::ServerCommand
    command :test
    description "/test command description"
    when_run do |server, io|
      puts "/test command has been executed with #{server}, #{io}"
    end
  end
  
  def setup    
    @server = Uwchat::Server.new  
  end
  
  def test_that_all_commands_registered
    # including command defined in setup we should have all commands in commands dir + 1
    n_cmds = Dir[ File.dirname(__FILE__) + '/../lib/uwchat/commands/*.rb' ].size
    expected = 1 + n_cmds
    actual = @server.my_commands.size
    
    assert_equal expected, actual
  end
  
  def test_desctiption_of_test_cmd
    expected = "/test command description"
    actual = @server.my_commands[:test].desc
    
    assert_equal expected, actual
  end
  
  def test_name_of_test_command
    expected = :test
    actual = @server.my_commands[:test].name
    
    assert_equal expected, actual
  end
  
  def test_action_of_test_command
    assert_kind_of Proc, @server.my_commands[:test].action
    assert_nil @server.my_commands[:test].action.call( "server", "io" )
  end
  
end
