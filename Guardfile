notification :growl

require "hippo/guard_tasks"


Hippo::GuardTasks.run(self, name: 'hippo') do | tests |

    # tests.client do

    # end

    # tests.server do

    # end

    tests.server do
        watch(%r{^templates/print/*}) { "spec/server/print/form_spec.rb" }
    end
end
