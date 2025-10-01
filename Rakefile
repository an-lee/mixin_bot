# frozen_string_literal: true

require 'bundler'
require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rdoc/task'

require_relative 'lib/mixin_bot/version'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files =
    FileList[
      'test/**/utils/test_*.rb',
      'test/mixin_bot/api/**/test_*.rb',
    ]
  t.warning = false
end

require 'rubocop/rake_task'

RuboCop::RakeTask.new

task default: %i[test rubocop]

desc 'Generate RDoc documentation'
RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.main = 'README.md'
  rdoc.title = 'MixinBot Ruby SDK'
  rdoc.rdoc_files.include('README.md', 'MIT-LICENSE', 'lib/**/*.rb')
  rdoc.options << '--markup' << 'markdown'
end

GEM_NAME = 'mixin_bot'
GEM_VERSION = MixinBot::VERSION

desc 'Build gem'
task :build do
  system "gem build #{GEM_NAME}.gemspec"
end

desc 'Build & install gem'
task install: :build do
  system "gem install #{GEM_NAME}-#{GEM_VERSION}.gem"
end

desc 'Uninstall gem'
task :uninstall do
  system "gem uninstall #{GEM_NAME}"
end

desc 'Build & publish gem'
task publish: :build do
  system "gem push #{GEM_NAME}-#{GEM_VERSION}.gem"
end

desc 'clean built gems'
task :clean do
  system 'rm *.gem'
end
