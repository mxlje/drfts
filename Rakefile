SSH_USER = 'max'
SSH_HOST = 'drfts.com'
SSH_DIR  = '/var/www'

desc "Build the website from source"
task :build do
  puts "## Building website"
  status = system("middleman build --clean")
  puts status ? "done." : "somethin went wrong."
end

desc "Clean up an old build"
task :clean do
  puts "## Cleaning build directory"
  system("rm -rf ./build")
  puts "done."
end
 
desc "Deploy website via rsync"
task :deploy do
  puts "## Deploying website via rsync to #{SSH_HOST}"
  status = system("rsync -avze 'ssh' --delete build/ #{SSH_USER}@#{SSH_HOST}:#{SSH_DIR}")
  puts status ? "OK" : "FAILED"
end
 
desc "Build, test and deploy website"
task :full => [:build, :test, :deploy] do
end



# Test task
$TEST_PATH = './spec'
$LOAD_PATH << $TEST_PATH

require 'rake/testtask'

# task :default => [:test]

desc "Run all tests"
Rake::TestTask.new :test do |t|
  t.libs.pop # remove "lib" path from default load path (a rake/testtask thing)
  t.test_files = FileList["#{$TEST_PATH}/**/*_spec.rb"]
  t.verbose = false
  t.warning = false
end