# frozen_string_literal: true

require_relative 'test_helper'

class TestServer < Minitest::Test
  def setup
    @server_port = 6380
    # @server = Server.new(@server_port)
    # @tcp_server = @server.server
    # Thread.new { @server.listen }
  end

  # def teardown
  #   @tcp_server.close
  #   # `kill -9 $(lsof -i :6380 -t)`
  # end

  def test_responds_to_ping
    r = Redis.new(port: @server_port)
    assert_equal 'PONG', r.ping
  end

  def test_multiple_commands_from_same_client
    r = Redis.new(port: @server_port)

    r.without_reconnect do
      assert_equal 'PONG', r.ping
      assert_equal 'PONG', r.ping
    end
  end

  def test_multiple_clients
    r1 = Redis.new(port: @server_port)
    r2 = Redis.new(port: @server_port)

    assert_equal 'PONG', r1.ping
    assert_equal 'PONG', r2.ping
  end

  def test_echo
    r = Redis.new(port: @server_port)

    assert_equal 'hey', r.echo('hey')
    assert_equal 'hello', r.echo('hello')
  end

  def test_set
    r = Redis.new(port: @server_port)

    assert_equal 'OK', r.set('mykey', 'myvalue')
  end

  def test_get
    r = Redis.new(port: @server_port)

    assert_nil r.get('key')

    r.set('key', 'value')
    assert_equal 'value', r.get('key')
  end
end
