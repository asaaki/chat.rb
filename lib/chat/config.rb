# frozen_string_literal: true
module Chat
  # application configuration
  class Config
    attr_reader :store, :page

    def initialize
      parse_env
      set_store
      set_page_template
    end

    private

    def parse_env
      @memstore = env_set?('MEM')
      @chat_log_file = env('CHAT_LOG')
    end

    def env_set?(key)
      ENV.key?(key)
    end

    def env(key)
      ENV[key]
    end

    def env!(key)
      ENV.fetch(key)
    end

    def set_store
      @store = store_class.new(@chat_log_file)
    end

    def store_class
      @memstore ? MemStore : Store
    end

    def set_page_template
      @page = Template.new
    end
  end
end
