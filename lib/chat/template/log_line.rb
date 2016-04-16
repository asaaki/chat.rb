# frozen_string_literal: true
module Chat
  # templates!
  class Template
    module LogLine
      module_function

      def data
        DATA
      end

      DATA = <<-LOG_LINE
            <p class='line'>
              <time class='ts' datetime='%{ts}'>[%{ts}]</time>
              <span class='nick'>%{nick}</span>
              <span class='msg'>%{msg}</span>
            </p>
      LOG_LINE
    end
  end
end
