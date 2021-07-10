# frozen_string_literal: true

require_relative 'resp_decoder'

class Client
  attr_reader :socket

  def initialize(socket)
    @socket = socket
    @buffer = ''
  end

  def consume_command!
    array = RESPDecoder.decode(@buffer)
    @buffer = ''
    Command.new(array.first, array[1..])
  rescue IncompleteRESP
    nil
  end

  def read_available
    @buffer += @socket.readpartial(1024)
  end

  def write(msg)
    @socket.write(msg)
  end
end
