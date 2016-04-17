# frozen_string_literal: true
module Chat
  # storage (yaml pstore)
  class Store
    def initialize(filename, maxlines)
      @store = YAML::Store.new(filename)
      @maxlines = maxlines
      init_log
    end

    def add_line(line)
      write_transaction { log.push(line) }
    end

    def last_lines
      read_transaction { log.last(@maxlines) }
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
