require "bundler/gem_tasks"


require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.rspec_opts = '--backtrace'
end

require 'solr_wrapper/rake_task'
require 'fcrepo_wrapper'
require 'active_fedora/rake_support'

desc 'Start Fedora and Solr and run specs'
task :ci do
  with_test_server do
    Rake::Task['spec'].invoke
  end
end
task default: :ci
