# frozen_string_literal: true
require_relative 'template/page'
require_relative 'template/log_line'

module Chat
  # templates!
  class Template
    def render(loglines: [], nickname: nil)
      Page.data % template_args(loglines, nickname)
    end

    private

    def template_args(lines, name)
      { loglines: prerender_loglines(lines), nickname: name }
    end

    def prerender_loglines(lines)
      lines.map do |(ts, nick, msg)|
        LogLine.data % { ts: ts, nick: nick, msg: msg }
      end.join("\n")
    end
  end
end
