# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lanes/version'

Gem::Specification.new do |spec|

    spec.name          = "lanes"
    spec.version       = Lanes::VERSION
    spec.authors       = ["Nathan Stitt"]
    spec.email         = ["nathan@argosity.com"]

    spec.summary       = %q{Stockor Core contains the models for the Stockor ERP system}
    spec.description   = %q{Stockor Core contains the ActiveRecord models and business logic for the Stockor ERP system}

    spec.homepage      = "http://stockor.org/"
    spec.license       = "MIT"

    spec.files         = `git ls-files`.split($/)
    spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
    spec.test_files    = spec.files.grep(%r{^test/})
    spec.require_paths = ["lib"]

    spec.required_ruby_version = '>= 2.0'
    spec.add_dependency 'activerecord', '~> 4.1'
    spec.add_dependency 'pg', '~> 0.17'
    spec.add_dependency "sinatra", '~> 1.4.0'
    spec.add_dependency "bcrypt-ruby", "~>3.1.5"
    spec.add_dependency "oj", "~>2.1.3"
    spec.add_dependency "message_bus", "~>1.0.5"
    spec.add_dependency "rack_csrf", "~>2.5"
    spec.add_dependency "sprockets", "~>2.0"
    spec.add_dependency "coffee-script", "~>2.3"
    spec.add_dependency "execjs", "~>2.2"
    spec.add_dependency "thor", "~>0.19.1"
    #spec.add_dependency "execjs", "~>2.2"
    spec.add_dependency "sass", "3.4.5"
    spec.add_dependency "sass-css-importer"
    spec.add_dependency "sprockets-helpers"

    spec.add_development_dependency "bundler", "~> 1.5"
    spec.add_development_dependency "rake"
    spec.add_development_dependency "jasmine-core", "~> 2.0"
    spec.add_development_dependency "guard"
    spec.add_development_dependency "hashie"
    spec.add_development_dependency "growl"
    #spec.add_development_dependency "active_record_mocks"
    spec.add_development_dependency "mocha"
    spec.add_development_dependency "pry-byebug"
    spec.add_development_dependency "guard-minitest"
    spec.add_development_dependency "minitest-around"

    spec.add_development_dependency "rack-test"

end
