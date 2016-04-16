# frozen_string_literal: true

# Ruby StdLib
require 'cgi'
require 'time'
require 'yaml/store'

# chat.rb
require_relative 'chat/config'
require_relative 'chat/server'
require_relative 'chat/store'
require_relative 'chat/mem_store'
require_relative 'chat/request'
require_relative 'chat/template'

# stupid simple chat
module Chat
  module_function

  def server
    Server.new
  end
end
