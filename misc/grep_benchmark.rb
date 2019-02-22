#! /usr/bin/env ruby

require 'benchmark'
require 'shellwords'
require 'open3'
require 'subprocess'

ITERATIONS         = 100
DICTIONARY_PATH    = File.join(File.dirname(__FILE__), '..', 'lib/db/dictionary.txt')
STDIN_GREP_COMMAND = ['/usr/bin/grep', '-m 1', '-f', '/dev/stdin', DICTIONARY_PATH]

password = 'swordfish'

def shell_grep(password)
  password = Shellwords.escape(password)
  `/usr/bin/grep -m 1 '^#{password}$' #{DICTIONARY_PATH}`
  $?.exitstatus == 0
end

def shell_grep_open3(password)
  password = Shellwords.escape(password)

  output = Open3.popen3(STDIN_GREP_COMMAND.join(" "), out: '/dev/null') { |stdin, stdout, stderr, wait_thr|
    stdin.puts "^#{password}$"
    stdin.close
    wait_thr.value
  }
  output.success?
end

def shell_grep_subprocess(password)
  password = Shellwords.escape(password)

  Subprocess.check_call(STDIN_GREP_COMMAND, stdin: Subprocess::PIPE, stdout: '/dev/null') do |p|
    p.communicate("^#{password}$")
  end
  true
rescue Subprocess::NonZeroExit
  false
end

def ruby_grep(password)
  File.open(DICTIONARY_PATH).grep(/^#{password}$/)
end

def ruby_loop(password)
  File.open(DICTIONARY_PATH).read_line do |l|
    return true if l.match?(/^#{password}$/)
  end
  false
end

Benchmark.bm(17) do |benchmark|
  benchmark.report("Shell") do
    ITERATIONS.times { shell_grep(password) }
  end

  benchmark.report("Ruby Grep") do
    ITERATIONS.times { ruby_grep(password) }
  end

  benchmark.report("Ruby Loop") do
    ITERATIONS.times { ruby_grep(password) }
  end

  benchmark.report("Open3 stdin") do
    ITERATIONS.times { shell_grep_open3(password) }
  end

  benchmark.report("Subprocess stdin") do
    ITERATIONS.times { shell_grep_subprocess(password) }
  end
end
