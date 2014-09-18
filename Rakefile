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
 
desc "Build and deploy website"
task :full => [:build, :deploy] do
end