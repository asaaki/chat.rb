# frozen_string_literal: true
module Chat
  # application for Rack
  class Server
    def initialize
      puts 'Chat::Server init ...'
      @config = Config.new
    end

    def call(env)
      Request.call(env, @config)
    end
  end
end
