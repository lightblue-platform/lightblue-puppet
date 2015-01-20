require 'puppetlabs_spec_helper/rake_tasks'
require "puppet-lint/tasks/puppet-lint"
require 'puppet-syntax/tasks/puppet-syntax'

task :default => [:spec, :lint]

desc "Generate coverage data"
task :coverage do
  Rake::Task["spec"].invoke
end