# frozen_string_literal: true

class Command
  attr_reader :action, :args

  def initialize(action, args)
    @action = action
    @args = args
  end

  def dispatch
    map = {
      'ping' => ->(client:, **_) { client.ping },
      'echo' => ->(client:, **_) { client.echo(args) },
      'set' => ->(client:, **options) { client.set(args, options[:store]) },
      'get' => ->(client:, **options) { client.get(args, options[:store]) }
    }
    map[action]
  end
end
