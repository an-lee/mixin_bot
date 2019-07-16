# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'mixin_bot/version'

Gem::Specification.new do |s|
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

  s.add_dependency 'bcrypt'
  s.add_dependency 'http'
  s.add_dependency 'jose'
  s.add_dependency 'jwt'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rubocop-rspec'
end
