# frozen_string_literal: true

require 'bundler'
require 'bundler/gem_tasks'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  warn e.message
  warn 'Run `bundle install` to install missing gems'
  exit e.status_code
end

require 'rake'
require 'rspec/core/rake_task'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)
task default: :spec
