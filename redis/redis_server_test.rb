require 'redis'
require "minitest/autorun"

class TestRedisServer < Minitest::Test
  def setup
    @server_port = 6380
  end

  def test_responds_to_ping
    r = Redis.new(port: @server_port)
    assert_equal "PONG", r.ping
  end

  def test_multiple_commands_from_same_client
    r = Redis.new(port: @server_port)

    r.without_reconnect do
      assert_equal "PONG", r.ping
      assert_equal "PONG", r.ping
    end
  end

  def test_multiple_clients
    r1 = Redis.new(port: @server_port)
    r2 = Redis.new(port: @server_port)

    assert_equal "PONG", r1.ping
    assert_equal "PONG", r2.ping
  end

  def test_echo
    r = Redis.new(port: @server_port)

    assert_equal "hey", r.echo("hey")
    assert_equal "hello", r.echo("hello")
  end
end
