require "bundler/gem_tasks"

begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)
  task default: :spec
rescue LoadError
end

task :benchmark do
  sh "BENCHMARK_REPETITIONS=1000 rspec spec/benchmark_spec.rb"
end
