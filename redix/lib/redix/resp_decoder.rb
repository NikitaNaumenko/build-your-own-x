# frozen_string_literal: true

require 'stringio'

module Redix
  class RESPDecoder
    SEPARATOR = "\r\n"

    class << self
      def decode(resp_str)
        resp_io = StringIO.new(resp_str)
        process_decoding(resp_io)
      end

      def dispatch(operation)
        map = {
          '$' => ->(input) { decode_bulk_string(input) },
          '+' => ->(input) { decode_simple_string(input) },
          '*' => ->(input) { decode_array(input) }
        }

        func = map[operation]

        raise "Unhandled operation: #{operation}" unless func

        func
      end

      def process_decoding(resp_io)
        operation = resp_io.read(1)

        raise IncompleteRESP if operation.nil?

        func = dispatch(operation)
        func.call(resp_io)
      rescue EOFError
        raise IncompleteRESP
      end

      def decode_array(str_io)
        byte_count_with_clrf = str_io.readline(SEPARATOR)

        raise IncompleteRESP unless correct_byte_count?(byte_count_with_clrf)

        element_count = byte_count_with_clrf.to_i
        Array.new(element_count) { process_decoding(str_io) }
      end

      def decode_bulk_string(str_io)
        byte_count_with_clrf = str_io.readline(SEPARATOR)

        raise IncompleteRESP unless correct_byte_count?(byte_count_with_clrf)

        byte_count = byte_count_with_clrf.to_i
        str = str_io.read(byte_count)

        # Exactly the advertised number of bytes must be present
        raise IncompleteRESP unless str&.length == byte_count

        # # Consume the ending CLRF
        raise IncompleteRESP unless correct_termination?(str_io.read(2))

        str
      end

      def decode_simple_string(str_io)
        read = str_io.readline(SEPARATOR)

        raise IncompleteRESP unless correct_byte_count?(read)

        read[0..-3]
      end

      def correct_byte_count?(input)
        input[-2..] == "\r\n"
      end

      def correct_termination?(termination_code)
        termination_code == "\r\n"
      end
    end
  end
end
