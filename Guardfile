notification :growl

require "lanes/guard_tasks"


Lanes::GuardTasks.run(self, name: 'lanes') do | tests |

    # tests.client do

    # end

    # tests.server do

    # end

    tests.server do
        watch(%r{^templates/print/*}) { "spec/server/print/form_spec.rb" }
    end
end
