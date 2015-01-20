require_relative '../../lib/<%= namespace.underscore %>'
require 'lanes/spec_helper'

module <%= namespace.camelize %>

    # Add more helper methods to be used by all tests here...

    class TestCase < Lanes::TestCase
        include <%= namespace.camelize %>
    end

    class ApiTestCase < Lanes::ApiTestCase
        include <%= namespace.camelize %>
    end

end
