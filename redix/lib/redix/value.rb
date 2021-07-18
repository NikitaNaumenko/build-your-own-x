# frozen_string_literal: true

module Redix
  class Value
    attr_accessor :value, :byte_size, :ex

    def initialize(value, byte_size, options = {})
      @value = value
      @byte_size = byte_size
      @ex = Time.now + options[:ex].to_i if options[:ex]
    end

    def expired?
      return false unless @ex

      @ex < Time.now
    end
  end
end
