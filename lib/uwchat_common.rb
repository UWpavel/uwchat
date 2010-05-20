require 'socket'
require 'digest/md5'

module Uwchat::Common
  
  HOST = 'localhost'
  PORT = 36963
  MAXCONS = 10
  
  def logger( msg )
    puts "[#{Time.now.strftime("%m-%d-%Y %H:%M:%S")}]: #{msg}"
  end
  
  def chksum( *strs )
    return Digest::MD5.hexdigest( strs.join )
  end
  
end