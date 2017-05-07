require 'rspec/expectations'

RSpec::Matchers.define :execute_successfully do
    match do |cmd|
        @cmd_last_output = `#{cmd} 2>&1`
         $?.exitstatus == 0
    end
    description do
        "Command exited with #{$?.exitstatus}.  Output was: #{@cmd_last_output}"
    end
end
