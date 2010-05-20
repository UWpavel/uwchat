# Server command class. Stores and describes commands 
class Uwchat::ServerCommand
  class << self
    
    attr_reader :name, :desc, :action
   
    def inherited( klass )
      Uwchat::Server.register_cmd( klass )
    end
    
    def command( name )
      @name = name
    end

    def description( desc = nil )
      @desc = desc
    end

    def when_run( &block )
      @action = block
    end
    
  end
end