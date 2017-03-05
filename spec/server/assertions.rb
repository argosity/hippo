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

# module Minitest::Assertions
#     #
#     #  Fails unless +expected and +actual have the same items.
#     #
#     def assert_executes(cmd)
#         assert execute_cmd(cmd),
#           "Expected #{cmd} exited with status #{$?.exitstatus}"
#     end

#     def last_cmd_execution_output
#         @cmd_last_output
#     end

#     private

#     def execute_cmd(cmd)

#     end

# end
