# frozen_string_literal: true

require_relative 'server'

def main
  Server.new(6380).listen
end

main
