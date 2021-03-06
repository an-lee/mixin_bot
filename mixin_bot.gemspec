# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'mixin_bot/version'

Gem::Specification.new do |s|
  s.required_ruby_version = '>= 2.6.0'

  s.name          = 'mixin_bot'
  s.version       = MixinBot::VERSION
  s.authors       = ['an-lee']
  s.email         = ['an.lee.work@gmail.com']
  s.homepage      = 'https://github.com/an-lee/mixin_bot'
  s.summary       = 'An API wrapper for Mixin Nexwork'
  s.description   = 'An API wrapper for Mixin Nexwork'
  s.license       = 'MIT'
  s.files         = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE']
  s.require_paths = ['lib']
  s.executables   = ['mixinbot']

  s.add_dependency 'awesome_print', '~> 1.8'
  s.add_dependency 'bcrypt', '~> 3.1'
  s.add_dependency 'cli-ui', '~> 1.3'
  s.add_dependency 'faye-websocket', '>= 0.11'
  s.add_dependency 'http', '~> 4.1'
  s.add_dependency 'jose', '~> 1.1'
  s.add_dependency 'msgpack', '~> 1.3'
  s.add_dependency 'rbnacl', '~> 7.1'
  s.add_dependency 'sha3', '~> 1.0'
  s.add_dependency 'thor', '~> 1.0'

  s.add_development_dependency 'pry', '~> 0.13.1'
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'rspec', '~> 3.8'
  s.add_development_dependency 'rubocop', '~> 0.72'
  s.add_development_dependency 'rubocop-rspec', '~> 1.33'
  s.add_development_dependency 'simplecov', '~> 0.18.2'
end
