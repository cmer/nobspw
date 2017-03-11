guard :rspec, cmd: "bundle exec rspec" do
  require "guard/rspec/dsl"
  dsl = Guard::RSpec::Dsl.new(self)

  # Feel free to open issues for suggestions and improvements

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  # Ruby files
  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)
end

if `uname` =~ /Darwin/
  if !!system("lsof -i:23053", out: '/dev/null')
    puts "Growl notifications enabled"
    notification :gntp, app_name: "", activate: 'com.googlecode.iTerm2'
  else
    puts "Native macOS notifications enabled"
    notification :terminal_notifier, app_name: "", activate: 'com.googlecode.iTerm2' if `uname` =~ /Darwin/
  end
end
