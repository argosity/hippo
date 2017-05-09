require_relative "spec_helper"

describe Hippo::Mailer do

    class TestEmail < Hippo::Templates::Mail
        extension_id :hippo
        def root_path
            Pathname.new(__FILE__).dirname.join('../fixtures')
        end
        def to
            'bob@test.com'
        end
        def subject
            'Hello test'
        end
    end

    it 'can send an email' do
        mail = Hippo::Mailer.create
        mail.to 'test@test.com'
        mail.from 'you@you.com'
        mail.subject 'testing'
        mail.body 'hello'
        expect { mail.deliver }.to change { Mail::TestMailer.deliveries.length }.by(1)
    end

    it 'can send using a template' do
        mail = Hippo::Mailer.from_template(TestEmail.new)
        expect { mail.deliver }.to change { Mail::TestMailer.deliveries.length }.by(1)
        mail = Mail::TestMailer.deliveries.last
        expect(mail.to).to eq(['bob@test.com'])
        expect(mail.subject).to eq('Hello test')
        expect(mail.body.raw_source).to eq("Hello, I am mail\n")
    end
end
