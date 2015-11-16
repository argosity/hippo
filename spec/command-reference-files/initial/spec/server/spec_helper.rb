require_relative '../../lib/AppyApp'
require 'lanes/spec_helper'

module AppyApp

    # Add more helper methods to be used by all tests here...

    class TestCase < Lanes::TestCase
        include AppyApp
    end

    class ApiTestCase < Lanes::ApiTestCase
        include AppyApp
    end

end
