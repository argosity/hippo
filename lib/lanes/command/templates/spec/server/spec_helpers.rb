require_relative '../../lib/<%= namespace %>'
require 'lanes/spec_helper'

module <%= namespace %>

    # Add more helper methods to be used by all tests here...

    class TestCase < Lanes::TestCase
        include <%= namespace %>
    end

    class ApiTestCase < Lanes::ApiTestCase
        include <%= namespace %>
    end

end
