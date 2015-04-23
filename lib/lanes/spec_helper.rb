require 'minitest/autorun'
require 'rack/test'
require 'lanes'
require 'lanes/api'
require 'hashie/mash'
require 'active_record'
require 'active_record/fixtures'
require 'minitest/around/unit'
require 'minitest/around/spec'
require 'minitest/spec'
require 'minitest/autorun'
require 'mocha/mini_test'

LANES_ENV = "test"
I18n.enforce_available_locales = true
Lanes::DB.establish_connection('test')
Lanes.logger=Logger.new( File.open('log/test.log', File::WRONLY | File::APPEND | File::CREAT ))
ActiveRecord::Base.logger = Lanes.logger
ActiveSupport::Dependencies.mechanism = :require
ActiveSupport.test_order = :random
module Lanes

    class DummyUser
        def can_read?(*args)
            true
        end
        def can_write?(*args)
            true
        end
        def can_delete?(*args)
            true
        end
    end

    class TestCase < ActiveSupport::TestCase
        include Lanes

        include ActiveRecord::TestFixtures
         self.fixture_path = Lanes::Extensions.controlling.root_path.join('spec','fixtures')

        self.use_transactional_fixtures = true
        fixtures :all

        def admin
            lanes_users(:admin)
        end

        extend MiniTest::Spec::DSL
        register_spec_type self do |desc|
            desc < Lanes::Model if desc.is_a? Class
        end

    end

    class ApiTestCase < TestCase
        include Rack::Test::Methods

        teardown do
            @current_user = nil
        end

        def app
            Lanes::API::Root.new
        end

        def json_body
            Hashie::Mash.new Oj.load( last_response.body )
        end

        def json_data
            json_body['data']
        end

        [ :get, :put, :post, :delete, :patch].each do |name|
            define_method(name) do |uri, params = {}, env = {}, &block|
                session = env['rack.session'] ||= {}
                env[Rack::Csrf.rackified_header] = Rack::Csrf.token(env)
                session[:user_id] = @current_user.id if @current_user
                params = Oj.dump(params, mode: :compat) if params.is_a?(Hash)
                super(uri,params,env,&block)
            end
        end

        def login!(user=admin)
            @current_user = user
        end

        def assert_ok
            assert last_response.ok?, "Request failed with #{last_response.status}"
        end
        def refute_ok
            refute last_response.ok?, "Request succeeded with status #{last_response.status}, expected non-2XX"
        end
    end
end

module MiniTest
    module Assertions

        def assert_logs_matching( regex, failure_message=nil, &block )
            old_logger = Lanes.logger
            begin
                output = ""
                Lanes.logger=Logger.new( StringIO.new(output) )
                yield
                assert_match( regex, output, failure_message )
            ensure
                Lanes.logger=old_logger
            end
        end


        def assert_saves( model )
            assert model.save, "#{model.class} failed to save: #{model.errors.full_messages.join(',')}"
        end

        def refute_saves( model, *errors )
            refute model.save, "#{model.class} saved successfully when it should not have"
            errors.each do |error|
                if model.errors[error.to_sym].empty?
                    raise MiniTest::Assertion, "expected #{model.class} to have an error on #{error}"
                end
            end

        end

        def assert_event_fires( klass, event, &block )
            @event_results = []
            klass.observe(event) do | *args |
                @event_results = args
            end
            yield
            raise MiniTest::Assertion, "Event #{event} was not fired" if @event_results.empty?
        end

        def last_event_results
            @event_results
        end
    end
end


require_relative 'access/test_fixture_extensions'
