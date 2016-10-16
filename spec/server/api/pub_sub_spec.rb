require "lanes/spec_helper"

class PubSubTest < Lanes::TestCase

    def test_pub_sub
        server = Lanes::API::PubSub.new
    end

end
