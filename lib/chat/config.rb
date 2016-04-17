# frozen_string_literal: true
module Chat
  # application configuration
  class Config
    DEFAULT_FILENAME = 'chat.log'
    DEFAULT_MAXLINES = 50

    attr_reader :store, :maxlines, :page

    def initialize
      parse_env
      set_maxlines
      set_store
      set_page_template
    end

    private

    def parse_env
      @use_memstore = env_set?('MEM')
      @chat_log_file = env('CHAT_LOG', DEFAULT_FILENAME)
    end

    def set_maxlines
      @maxlines = Integer(env('MAXLINES', DEFAULT_MAXLINES))
    end

    def set_store
      @store = store_class.new(@chat_log_file, @maxlines)
    end

    def store_class
      @use_memstore ? MemStore : Store
    end

    def set_page_template
      @page = Template.new
    end

    def env_set?(key)
      ENV.key?(key)
    end

    def env(key, default)
      ENV.fetch(key, default)
    end

    def env!(key)
      ENV.fetch(key)
    end
  end
end
