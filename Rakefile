# frozen_string_literal: true

require 'bundler'
require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/utils/test_*.rb']
  t.warning = false
end

require 'rubocop/rake_task'

RuboCop::RakeTask.new

task default: %i[test rubocop]

GEM_NAME = 'mixin_bot'
GEM_VERSION = MixinBot::VERSION

task :build do
  system "gem build #{GEM_NAME}.gemspec"
end

task install: :build do
  system "gem install #{GEM_NAME}-#{GEM_VERSION}.gem"
end

task :uninstall do
  system "gem uninstall #{GEM_NAME}"
end

task publish: :build do
  system "gem push #{GEM_NAME}-#{GEM_VERSION}.gem"
end

task :clean do
  system 'rm *.gem'
end
