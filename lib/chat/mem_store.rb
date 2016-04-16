# frozen_string_literal: true
module Chat
  # storage (in-memory)
  class MemStore
    DEFAULT_COUNT = 50

    def initialize(_filename = nil)
      @store = []
    end

    def add_line(line)
      @store.push(line)
    end

    def get_lines(line_count = DEFAULT_COUNT)
      @store.last(line_count)
    end
  end
end
