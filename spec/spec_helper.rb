require "bundler/setup"
require "nobspw"
require "pry"
require "simplecov"

SimpleCov.start do
  coverage_dir 'spec/reports'
end

RSpec.configure do |config|
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.filter_run_when_matching :focus
  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.after(:each) do
    NOBSPW.configuration = nil
  end
end
