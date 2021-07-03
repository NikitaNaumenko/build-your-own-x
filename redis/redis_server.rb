require 'socket'

class RedisServer
  def initialize(port)
    @server = TCPServer.new(port)
    @clients = []
  end

  def listen
    loop do
      fds_to_watch = [@server, *@clients]

      ready_to_read, _, _ = IO.select(fds_to_watch)
      ready_to_read.each do |ready|
        if ready == @server
          @clients << @server.accept
        else
          handle_client(ready)
        end
      end
    end
  end

  def handle_client(client)
    client.readpartial(1024) # TODO: Read actual command
    client.write("+PONG\r\n")
  end
end

RedisServer.new(6380).listen
