# frozen_string_literal: true

module Redix
  class Store
    def initialize
      @store = {}
    end

    def set(key, value)
      @store[key] = value
    end

    def get(key)
      @store[key]
    end
  end
end
