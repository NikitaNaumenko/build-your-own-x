# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative 'lib/redix/version'

Gem::Specification.new do |spec|
  spec.name          = 'redix'
  spec.version       = Redix::VERSION
  spec.authors       = ['Nikita Naumenko']
  spec.email         = ['naumenkoniki@gmail.com']

  spec.summary       = 'Mini Redis server ruby implementation'
  spec.description   = 'Redis server is implemented by myself'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
