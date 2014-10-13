ENV['RACK_ENV'] = 'test'

BUILD_DIR = "./build"
TEST_PORT = 5000
TEST_URI  = "http://0.0.0.0:#{TEST_PORT}"

require 'minitest/autorun'  # main minitest lib
require 'minitest/pride'    # nice color output
require 'rack/test'         # actually browse around in the app
require 'nokogiri'          # to analyze responses
require 'anemone'           # to crawl the actual page

PAGES = []

# This creates a rack app that serves the BUILD_DIR
# so it can be tested through Rack::Test
App = Proc.new { |env|
  # Extract the requested path from the request
  path = Rack::Utils.unescape(env['PATH_INFO'])
  index_file = BUILD_DIR + "#{path}/index.html"

  if File.exists?(index_file)
    # Return the index
    [200, {'Content-Type' => 'text/html'}, [File.read(index_file)]]
  else
    # Pass the request to the directory app
    Rack::Directory.new(BUILD_DIR).call(env)
  end
}

def app
  App
end



# helper to check if dev server is ready
def server_ready?
  begin
    url = URI.parse(TEST_URI)
    req = Net::HTTP.new(url.host, url.port)
    res = req.request_head("/")
    res.code == "200"
  rescue Errno::ECONNREFUSED
    false
  end
end

# serve the build
pid = fork do
  # this code is run in the child process
  # you can do anything here, like changing current directory or reopening STDOUT
  STDOUT.reopen "/dev/null"
  STDERR.reopen "/dev/null"
  puts "Serving #{BUILD_DIR} on :#{TEST_PORT}"
  exec "ruby -run -e httpd #{BUILD_DIR} -p 5000"
end

# wait until the server is ready
until server_ready? do
  sleep 1
end

# crawl the page with anemone and save the responses
# so we can query them in a test
anemone_options = {
  skip_query_strings: false,
  discard_page_bodies: false,
  # depth_limit: 4,
}

Anemone.crawl(TEST_URI, anemone_options) do |anemone|
  # anemone.storage = Anemone::Storage.Redis
  # anemone.skip_links_like(/\.jpg/i)

  anemone.on_every_page { |page| PAGES << page }
end



# kill the dev server process
Minitest.after_run do
  puts "Tests done, shutting down server."

  Process.kill "KILL", pid
  Process.wait pid

  puts "DONE."
end
