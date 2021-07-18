# frozen_string_literal: true

require 'redix/version'
require 'redix/resp_decoder'
require 'redix/server'

module Redix
  class IncompleteRESP < StandardError; end

  class Error < StandardError; end

  def self.run_server
    puts '---ServerStarting...---'
    Server.new(6380).listen
  end
end
