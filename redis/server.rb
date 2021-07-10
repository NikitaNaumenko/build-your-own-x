# frozen_string_literal: true

require 'socket'
require_relative 'client'
require_relative 'command'

class Server
  attr_reader :server

  def initialize(port)
    @server = TCPServer.new(port)
    @clients_by_socket = {}
  end

  def listen
    loop do
      fds_to_watch = [@server, *@clients_by_socket.keys]

      ready_to_read, = IO.select(fds_to_watch)
      ready_to_read.each do |ready|
        if ready == @server
          client_socket = @server.accept
          @clients_by_socket[client_socket] = Client.new(client_socket)
        else
          client = @clients_by_socket[ready]
          handle_client(client)
        end
      end
    end
  end

  def handle_client(client)
    client.read_available
    loop do
      command = client.consume_command!
      break unless command

      handle_command(client, command)
    end
  rescue Errno::ECONNRESET, EOFError
    # If the client has disconnected, let's
    # remove from our list of active clients
    @clients_by_socket.delete(client.socket)
  end

  def handle_command(client, command)
    if command.action.casecmp('ping').zero?
      client.write("+PONG\r\n")
    elsif command.action.casecmp('echo').zero?
      client.write("+#{command.args.first}\r\n")
    else
      raise RuntimeError("Unhandled command: #{command.action}")
    end
  end
end
