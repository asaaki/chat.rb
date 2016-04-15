# frozen_string_literal: true

require 'cgi'
require 'time'
require 'yaml/store'

# stupid simple chat
module Chat
  module_function

  def server
    Server.new
  end

  # application for Rack
  class Server
    def initialize
      puts 'Chat::Server init ...'
      @config = {
        store: Store.new,
        page: Template.new
      }
    end

    def call(env)
      Request.call(env, @config)
    end
  end

  # storage
  class Store
    DEFAULT_FILENAME = 'chat.log'
    DEFAULT_COUNT = 50

    def initialize(filename = DEFAULT_FILENAME)
      @store = YAML::Store.new(filename)
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

  # request cycle
  class Request
    HEADERS = { 'Content-Type' => 'text/html' }.freeze
    REQUEST_PARAMS = %w(nickname message).freeze

    FORBIDDEN_ELEMENTS = %w(
      ! % xml

      a abbr acronym address applet area article aside audio b base basefont bdi
      bdo bgsound big blink blockquote body br button canvas caption center cite
      code col colgroup command comment data datalist dd del details dfn dialog
      dir div dl dt em embed fieldset figcaption figure font footer form frame
      frameset h1 h2 h3 h4 h5 h6 head header hgroup hr html i iframe img input
      ins isindex kbd keygen label legend li link listing main map mark math
      marquee menu menuitem meta meter multicol nav nobr noembed noframes
      noscript object ol optgroup option output p param plaintext pre progress q
      rp ruby rt rtc s samp script section select small sound source spacer span
      strike strong style sub summar sup svg table tbody td textarea tfoot th
      thead time title tr track tt u ul var video wbr xmp

      content element shadow template
    ).freeze

    def self.call(env, config)
      new(env, config).call
    end

    def initialize(env, config)
      @request = Rack::Request.new(env)
      @store = config[:store]
      @page = config[:page]
      @body = ['(unset body data)']
    end

    def call
      process_post_data
      write_log
      respond
    end

    private

    def process_post_data
      # @nickname = @request.params['nickname']
      # @message = @request.params['message']
      @nickname, @message = @request.params.values_at(*REQUEST_PARAMS)
    end

    def write_log
      return unless post_request?
      @store.add_line(log_line)
    end

    def post_request?
      @request.post?
    end

    def log_line
      [timestamp, escape(@nickname), escape(@message)]
    end

    def timestamp
      Time.now.utc.iso8601
    end

    def escape(data)
      CGI.escape_element(data, FORBIDDEN_ELEMENTS)
    end

    def respond
      [200, HEADERS, [page]]
    end

    def page
      @page.render(loglines: recent_log_lines, nickname: @nickname)
    end

    def recent_log_lines
      @store.get_lines
    end
  end

  # templates!
  class Template
    def render(loglines: [], nickname: nil)
      PAGE_TEMPLATE % template_args(loglines, nickname)
    end

    private

    def template_args(lines, name)
      { loglines: prerender_loglines(lines), nickname: name }
    end

    def prerender_loglines(lines)
      lines.map do |(ts, nick, msg)|
        LOG_LINE % { ts: ts, nick: nick, msg: msg }
      end.join("\n")
    end

    LOG_LINE = <<-LOG_LINE
          <p class='line'>
            <time class='ts' datetime='%{ts}'>[%{ts}]</time>
            <span class='nick'>%{nick}</span>
            <span class='msg'>%{msg}</span>
          </p>
    LOG_LINE

    PAGE_TEMPLATE = <<-PAGE_TEMPLATE
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>chat.rb</title>
    <style type="text/css">
      html, * { box-sizing: border-box; }
      html, body, .wrap { margin: 0; border: 0; padding: 0; height: 100%%; }
      body {
        color: #333; background-color: #eee;
        font: 12px/1.25em monospace;
      }

      hr { margin: 0 0 .5em 0; border: 0; padding: 0; height: 1px; background-color: #ccc; }

      .wrap {
        display: flex;
        flex-direction: column;
        flex-wrap: nowrap;
        justify-content: flex-start;
        align-items: stretch;
        align-content: stretch;
      }
      .chat-header { flex: 0 1 auto; align-self: auto; }
      .chat-log { flex: 1 1 auto; align-self: auto; position: relative; overflow: hidden; }
      .chat-log-messages { position: absolute; bottom: 0; padding: 0 .5em; }
      .chat-input { flex: 0 1 auto; align-self: auto; padding: 0.75em .5em; }

      .ts { color: #676; font-size: .8em; }
      .nick { color: #234; font-weight: bold; }
      .msg {}
    </style>
  </head>
  <body>
    <div class="wrap">
      <h1>chat.rb</h1>

      <div class="chat-log">
        <div class="chat-log-messages">
          <!-- <p class="line">
              <time class="ts" datetime="2016-04-14T20:57:15Z">
                [2016-04-14T20:57:15Z]</time>
              <span class="nick">chris</span>
              <span class="msg">test</span>
            </p> -->
          %{loglines}
        </div>
      </div>

      <div class="chat-input">
        <hr>
        <form method="post">
          <input type="text" name="nickname" value="%{nickname}" placeholder="Your nickname ..." size="16" autocomplete="off">
          <input type="text" name="message" placeholder="Your message ..." size="50" autocomplete="off" autofocus>
          <input type="submit" value="Send...">
        </form>
      </div>
    </div>
  </body>
</html>
    PAGE_TEMPLATE
  end
end
