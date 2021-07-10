require 'socket'
require_relative 'resp_decoder'

class Command
  attr_reader :action, :args

  def initialize(action, args)
    @action = action
    @args = args
  end
end

class Client
  attr_reader :socket

  def initialize(socket)
    @socket = socket
    @buffer = ""
  end

  def consume_command!
    array = RESPDecoder.decode(@buffer)
    @buffer = ""
    Command.new(array.first, array[1..-1])
  rescue IncompleteRESP
    return nil
  end

  def read_available
    @buffer += @socket.readpartial(1024)
  end

  def write(msg)
    @socket.write(msg)
  end
end

class RedisServer
  def initialize(port)
    @server = TCPServer.new(port)
    @clients_by_socket = {}
  end

  def listen
    loop do
      fds_to_watch = [@server, *@clients_by_socket.keys]

      ready_to_read, _, _ = IO.select(fds_to_watch)
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
    if command.action.downcase == "ping"
      client.write("+PONG\r\n")
    elsif command.action.downcase == 'echo'
      client.write("+#{command.args.first}\r\n")
    else
      raise RuntimeError("Unhandled command: #{command.action}")
    end
  end
end

RedisServer.new(6380).listen
