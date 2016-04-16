# frozen_string_literal: true
module Chat
  # storage
  class Store
    DEFAULT_FILENAME = 'chat.log'
    DEFAULT_COUNT = 50

    def initialize(filename = nil)
      @store = YAML::Store.new(filename || DEFAULT_FILENAME)
      init_log
    end

    def add_line(line)
      write_transaction { log.push(line) }
    end

    def get_lines(line_count = DEFAULT_COUNT)
      read_transaction { log.last(line_count) }
    end

    private

    def log
      @store['log']
    end

    def init_log
      write_transaction { @store['log'] ||= [] }
    end

    def write_transaction(&_block)
      @store.transaction { yield }
    end

    def read_transaction(&_block)
      @store.transaction(true) { yield }
    end
  end
end
