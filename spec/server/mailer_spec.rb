require_relative "spec_helper"

describe Lanes::Mailer do

    before do
        # needed because otherwise the rollback will leave configs without a db record
        Lanes::SystemSettings.instance_variable_set(:@config, nil)
        settings = Lanes::SystemSettings.for_ext('lanes')
        settings.smtp = {
            'server' => 'foo.test.com'
        }
        settings.persist!
    end

    def test_it_configures_itself
        # calling new forces a config
        Lanes::Mailer.new
        assert_equal 'foo.test.com',
                     Mail::Configuration.instance.delivery_method.settings[:address]

    end

    def test_sending_an_email
        Lanes::Mailer.deliver do
            to 'test@test.com'
            from 'you@you.com'
            subject 'testing'
            body 'hello'
        end
        assert_equal(1, Mail::TestMailer.deliveries.length)
    end

end
