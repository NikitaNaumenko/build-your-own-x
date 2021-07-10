# frozen_string_literal: true

class Command
  attr_reader :action, :args

  def initialize(action, args)
    @action = action
    @args = args
  end
end
