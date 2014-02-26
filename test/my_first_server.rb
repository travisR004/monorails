require 'webrick'

root = File.expand_path '~/public_html'
server = WEBrick::HTTPServer.new :Port  => 8080, :DocumentRoot => root

server.mount_proc '/' do |request, response|
  response.content_type = "text/text"
  response.body = request.path
end

trap 'INT' do server.shutdown end

server.start