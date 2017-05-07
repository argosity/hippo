require_relative "spec_helper"

describe Hippo::Mailer do

    before do
        # needed because otherwise the rollback will leave configs without a db record
        Hippo::SystemSettings.instance_variable_set(:@config, nil)
        settings = Hippo::SystemSettings.for_ext('hippo')
        settings.smtp = {
            'server' => 'foo.test.com'
        }
        settings.persist!
    end

    def test_it_configures_itself
        # calling new forces a config
        Hippo::Mailer.new
        assert_equal 'foo.test.com',
                     Mail::Configuration.instance.delivery_method.settings[:address]

    end

    def test_sending_an_email
        Hippo::Mailer.deliver do
            to 'test@test.com'
            from 'you@you.com'
            subject 'testing'
            body 'hello'
        end
        assert_equal(1, Mail::TestMailer.deliveries.length)
    end

end
