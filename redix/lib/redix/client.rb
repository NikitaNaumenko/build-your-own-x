# frozen_string_literal: true

require_relative 'resp_decoder'
require_relative 'value'

module Redix
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
      (key, value), *options = args.each_slice(2).to_a
      parsed_options = parse_options(options)
      if store.get(key)
        old_value = store.get(key)
        store.set(key, build_value(value, parsed_options))
        write("$#{old_value.byte_size}\r\n#{old_value.value}\r\n")
      else
        store.set(key, build_value(value, parsed_options))
        write("+OK\r\n")
      end
    end

    def get(args, store)
      key = args.first
      value = store.get(key)
      if value && !value.expired?
        write("$#{value.byte_size}\r\n#{value.value}\r\n")
      else
        write("$-1\r\n")
      end
    end

    private

    def parse_options(options)
      map = { 'EX' => :ex }
      options.each_with_object({}) do |(key, value), acc|
        mapped_key = map[key]
        acc[mapped_key] = value
      end
    end

    def build_value(value, options = {})
      Value.new(value, value.length, options)
    end
  end
end
