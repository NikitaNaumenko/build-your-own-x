# frozen_string_literal: true

require_relative 'test_helper'

class TestServer < Minitest::Test
  def setup
    @redis = Redis.new(port: 6380)
  end

  def test_responds_to_ping
    assert_equal 'PONG', @redis.ping
  end

  def test_multiple_commands_from_same_client
    @redis.without_reconnect do
      assert_equal 'PONG', @redis.ping
      assert_equal 'PONG', @redis.ping
    end
  end

  def test_multiple_clients
    r2 = Redis.new(port: 6380)

    assert_equal 'PONG', @redis.ping
    assert_equal 'PONG', r2.ping
  end

  def test_echo
    assert_equal 'hey', @redis.echo('hey')
    assert_equal 'hello', @redis.echo('hello')
  end

  def test_set
    assert_equal 'OK', @redis.set('mykey', 'myvalue')
    assert_equal 'myvalue', @redis.set('mykey', 'jopa')
  end

  def test_get
    assert_nil @redis.get('key')

    @redis.set('key', 'value')
    assert_equal 'value', @redis.get('key')
  end

  def test_set_with_ex
    assert_nil @redis.get('key1')

    @redis.set('key1', 'value', { ex: 1 })
    assert_equal 'value', @redis.get('key1')

    sleep 1

    assert_nil @redis.get('key1')
  end
end
