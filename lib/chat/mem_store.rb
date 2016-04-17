# frozen_string_literal: true
module Chat
  # storage (in-memory)
  class MemStore
    def initialize(_filename, maxlines)
      @store = []
      @maxlines = maxlines
    end

    def add_line(line)
      @store.push(line)
    end

    def last_lines
      @store.last(@maxlines)
    end
  end
end
