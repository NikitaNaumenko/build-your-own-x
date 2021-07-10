# frozen_string_literal: true

require 'stringio'

class IncompleteRESP < StandardError; end

class RESPDecoder
  class << self
    def decode(resp_str)
      resp_io = StringIO.new(resp_str)
      process_decoding(resp_io)
    end

    def process_decoding(resp_io)
      first_char = resp_io.read(1)
      raise IncompleteRESP if first_char.nil?

      if first_char == '+'
        decode_simple_string(resp_io)
      elsif first_char == '$'
        decode_bulk_string(resp_io)
      elsif first_char == "*"
        decode_array(resp_io)
      else
        raise RuntimeError.new("Unhandled first char: #{first_char}")
      end
    rescue EOFError
      raise IncompleteRESP
    end

    def decode_array(str_io)
      byte_count_with_clrf = str_io.readline(sep = "\r\n")
      if byte_count_with_clrf[-2..] != "\r\n"
        raise IncompleteRESP
      end

      element_count = byte_count_with_clrf.to_i
      element_count.times.map { process_decoding(str_io) }
    end

    def decode_bulk_string(str_io)
      byte_count_with_clrf = str_io.readline(sep = "\r\n")
      if byte_count_with_clrf[-2..] != "\r\n"
        raise IncompleteRESP
      end

      byte_count = byte_count_with_clrf.to_i
      str = str_io.read(byte_count)

      # Exactly the advertised number of bytes must be present
      raise IncompleteRESP unless str&.length == byte_count

      # Consume the ending CLRF
      raise IncompleteRESP unless str_io.read(2) == "\r\n"

      str
    end

    def decode_simple_string(str_io)
      read = str_io.readline(sep = "\r\n")
      if read[-2..] != "\r\n"
        raise IncompleteRESP
      end

      read[0..-3]
    end
  end
end
