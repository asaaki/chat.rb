run Proc.new { |env|
  req = Rack::Request.new(env)

  if req.post?
    nickname = req.params["nickname"]
    text = req.params["text"]
    `echo "#{nickname}: #{text}" >> chat.log`
  end

  content = `tail -n 20 chat.log`.gsub("\n", '<br>')

  form = "<form  method=\"post\"><input type=\"text\" name=\"nickname\" value=\"#{nickname}\"><input type=\"text\" name=\"text\" autofocus><input type=\"submit\" value=\"Submit\">"

  ['200', { 'Content-Type' => 'text/html' }, ["<body>#{content}#{form}"]]
}
