# frozen_string_literal: true
module Chat
  # templates!
  class Template
    module Page
      module_function

      def data
        DATA
      end

      DATA = <<-PAGE_TEMPLATE
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
end
