#! /usr/bin/env ruby

require 'benchmark'
require 'shellwords'

password = 'swordfish'
dictionary_path = File.join(File.dirname(__FILE__), '..', 'lib/db/dictionary.txt')

def shell_grep(password, dictionary)
  password = Shellwords.escape(password)
	"/usr/bin/grep '^#{password}$' #{dictionary}"
  $?.exitstatus == 0
end

Benchmark.bm do |benchmark|
  benchmark.report("Ruby") do
    25.times { File.open(dictionary_path).grep(/^#{password}$/) }
  end

  benchmark.report("Shell") do
    25.times { shell_grep(password, dictionary_path) }
  end
end