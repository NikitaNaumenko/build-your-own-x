$LOAD_PATH.unshift('./vendor/bundle')

puts $LOAD_PATH
require 'daemons'

Daemons.run('main.rb')
