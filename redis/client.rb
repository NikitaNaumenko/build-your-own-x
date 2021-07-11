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

  def ping
    write("+PONG\r\n")
  end

  def echo(args)
    write("+#{args.first}\r\n")
  end

  def set(args, store)
    key, value = args
    if store[key]
      old_value = store[key]
      store[key] = value
      write("$#{old_value.length}\r\n#{old_value}\r\n")
    else
      store[key] = value
      write("+OK\r\n")
    end
  end

  def get(args, store)
    key = args.first
    value = store[key]
    if value
      write("$#{value.length}\r\n#{value}\r\n")
    else
      write("$-1\r\n")
    end
  end
end
