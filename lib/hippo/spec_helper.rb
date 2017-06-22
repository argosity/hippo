require 'hippo/webpack'
Hippo::Webpack.stub = true

require 'rack/test'
require 'hippo'
require 'hippo/api'
require 'hashie/mash'
require 'active_record'
require 'active_record/fixtures'
require 'mail'
require 'factory_girl'
require 'faker'
require 'database_cleaner'
require "shrine/storage/memory"
require 'vcr'
require 'hippo/tenant'


TEST_TENANT = Hippo::Tenant.find_by_slug('test') || Hippo::Tenant.create!(slug: 'test', name: 'testing tenant', email: 'test@test.com')

VCR.configure do |config|
    config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
    config.hook_into :webmock
    config.configure_rspec_metadata!
end

Hippo::Concerns::AssetUploader.storages = {
    cache: Shrine::Storage::Memory.new,
    store: Shrine::Storage::Memory.new,
}

VCR_OPTS = {
    record: ENV["VCR_RECORD"].try(:to_sym) || :none, # This should default to :none before pushing
    allow_unused_http_interactions: false
}


module RackSpecMixin
    include Rack::Test::Methods
    def app
        Hippo::API::Root
    end
    def last_response_json
        Oj.load(last_response.body)
    end
end

HIPPO_ENV = "test"
module Fixtures
    def fixtures_path
        Hippo::Extensions.controlling.root_path.join('spec', 'fixtures')
    end
end

FactoryGirl.definition_file_paths = Hippo::Extensions.map do |ext|
    ext.root_path.join('spec/factories')
end

module ApiHelper
    def ApiHelper.included(mod)
        mod.around(:each) do |example|
            begin
                example.run
            end
        end
    end
end

RSpec.configure do |config|
    config.include FactoryGirl::Syntax::Methods
    config.include ApiHelper, api: true
    config.include Fixtures

    config.include RackSpecMixin, :api => true

    # Use color in STDOUT
    config.color = true

    config.before(:suite) do
        FactoryGirl.find_definitions
        DatabaseCleaner.strategy = :transaction
    end

    config.around(:each) do |example|
        Hippo.logger.level = ::Logger::WARN
        TEST_TENANT.perform do
            DatabaseCleaner.cleaning do
                example.run
            end
        end
    end

    # rspec-expectations config goes here. You can use an alternate
    # assertion/expectation library such as wrong or the stdlib/minitest
    # assertions if you prefer.
    config.expect_with :rspec do |expectations|
        # This option will default to `true` in RSpec 4. It makes the `description`
        # and `failure_message` of custom matchers include text for helper methods
        # defined using `chain`, e.g.:
        #     be_bigger_than(2).and_smaller_than(4).description
        #     # => "be bigger than 2 and smaller than 4"
        # ...rather than:
        #     # => "be bigger than 2"
        expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    end

    # rspec-mocks config goes here. You can use an alternate test double
    # library (such as bogus or mocha) by changing the `mock_with` option here.
    config.mock_with :rspec do |mocks|
        # Prevents you from mocking or stubbing a method that does not exist on
        # a real object. This is generally recommended, and will default to
        # `true` in RSpec 4.
        mocks.verify_partial_doubles = true
    end

    # The settings below are suggested to provide a good initial experience
    # with RSpec, but feel free to customize to your heart's content.
=begin
  # These two settings work together to allow you to limit a spec run
  # to individual examples or groups you care about by tagging them with
  # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  # get run.
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  # Limits the available syntax to the non-monkey patched syntax that is
  # recommended. For more details, see:
  #   - http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax
  #   - http://teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://myronmars.to/n/dev-blog/2014/05/notable-changes-in-rspec-3#new__config_option_to_disable_rspeccore_monkey_patching
  config.disable_monkey_patching!

  # This setting enables warnings. It's recommended, but in some cases may
  # be too noisy due to issues in dependencies.
  config.warnings = true

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = 'doc'
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
=end
end
