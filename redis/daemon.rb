path = File.expand_path("./vendor/bundle")
$LOAD_PATH.unshift(path)
puts path
puts $LOAD_PATH

require 'daemons'

Daemons.run('main.rb')
