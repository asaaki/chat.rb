# frozen_string_literal: true
module Chat
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
      @store = config.store
      @page = config.page
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
end
