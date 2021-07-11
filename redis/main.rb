# frozen_string_literal: true
puts $LOAD_PATH

require_relative 'server'

def main
  Server.new(6380).listen
end

main
