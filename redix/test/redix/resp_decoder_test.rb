# frozen_string_literal: true

require 'test_helper'

class Redix::RESPDecoderTest < Minitest::Test
  def test_simple_string
    assert_equal 'OK', Redix::RESPDecoder.decode("+OK\r\n")
    assert_equal 'HEY', Redix::RESPDecoder.decode("+HEY\r\n")
    assert_raises(Redix::IncompleteRESP) { Redix::RESPDecoder.decode('+') }
    assert_raises(Redix::IncompleteRESP) { Redix::RESPDecoder.decode('+OK') }
    assert_raises(Redix::IncompleteRESP) { Redix::RESPDecoder.decode("+OK\r") }
  end

  def test_bulk_string
    assert_equal 'OK', Redix::RESPDecoder.decode("$2\r\nOK\r\n")
    assert_equal 'HEY', Redix::RESPDecoder.decode("$3\r\nHEY\r\n")
    assert_equal 'HELLO', Redix::RESPDecoder.decode("$5\r\nHELLO\r\n")
    assert_raises(Redix::IncompleteRESP) { Redix::RESPDecoder.decode('$') }
    assert_raises(Redix::IncompleteRESP) { Redix::RESPDecoder.decode('$OK') }
    assert_raises(Redix::IncompleteRESP) { Redix::RESPDecoder.decode('$2') }
    assert_raises(Redix::IncompleteRESP) { Redix::RESPDecoder.decode("$2\r\n") }
    assert_raises(Redix::IncompleteRESP) { Redix::RESPDecoder.decode("$2\r\nOK") }
    assert_raises(Redix::IncompleteRESP) { Redix::RESPDecoder.decode("$2\r\nOK\r") }
  end

  def test_array
    assert_equal ['PONG'], Redix::RESPDecoder.decode("*1\r\n$4\r\nPONG\r\n")
    assert_equal ['PING'], Redix::RESPDecoder.decode("*1\r\n$4\r\nPING\r\n")
    assert_equal %w[ECHO hey], Redix::RESPDecoder.decode("*2\r\n$4\r\nECHO\r\n$3\r\nhey\r\n")
    assert_raises(Redix::IncompleteRESP) { Redix::RESPDecoder.decode('*') }
    assert_raises(Redix::IncompleteRESP) { Redix::RESPDecoder.decode('*1') }
    assert_raises(Redix::IncompleteRESP) { Redix::RESPDecoder.decode("*1\r\n") }
    assert_raises(Redix::IncompleteRESP) { Redix::RESPDecoder.decode("*1\r\n$4") }
    assert_raises(Redix::IncompleteRESP) { Redix::RESPDecoder.decode("*2\r\n$4\r\nECHO\r\n") }
  end

  def test_wrong_operation
    assert_raises(RuntimeError) { Redix::RESPDecoder.decode("?1\r\nCODE\r\n") }
  end
end
