# encoding: utf-8

require 'rubygems'
require 'bundler'
Bundler.setup(:default, :development)

require 'rake'
require 'jeweler'
require './lib/linebyline'

Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "linebyline"
  gem.version = LineByLine::VERSION
  gem.homepage = "http://github.com/julik/linebyline"
  gem.license = "MIT"
  gem.summary = %Q{ Comparse two passed IO objects line by line (useful for tests) }
  gem.description = %Q{ Can be used for comparing long outputs to references }
  gem.email = "me@julik.nl"
  gem.authors = ["Julik Tarkhanov"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test