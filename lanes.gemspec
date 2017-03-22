# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lanes/version'

Gem::Specification.new do |spec|

    spec.name          = "lanes"
    spec.version       = Lanes::VERSION
    spec.authors       = ["Nathan Stitt"]
    spec.email         = ["nathan@argosity.com"]

    spec.summary       = %q{Lanes is a framework for easily writing single page web applications}
    spec.description   = %q{Lanes is a framework for writing single page web applications.  It's a full stack framework that contains  both server and client.}

    spec.homepage      = "http://lanesframework.org/"

    spec.license       = "MIT"

    spec.files         = `git ls-files`.split($/)
    spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
    spec.test_files    = spec.files.grep(%r{^test/})
    spec.require_paths = ["lib"]

    spec.required_ruby_version = ">= 2.0"

    spec.add_dependency "activejob",              "~> 5.0"
    spec.add_dependency "activerecord",           "~> 5.0"
    spec.add_dependency "actioncable",            "~> 5.0"
    spec.add_dependency "mail",                   "~> 2.6"

    spec.add_dependency "sinatra",                "~> 2.0.0.rc2"
    spec.add_dependency "rack-protection",        "~> 2.0.0.rc2"
    spec.add_dependency "rack",                   "~> 2.0"

    spec.add_dependency "rack-cors",              "~> 0.4"
    spec.add_dependency "rack-test",              "~> 0.6"

    spec.add_dependency "bcrypt",                 "~> 3.1"
    spec.add_dependency "shrine",                 "~> 2.4"
    spec.add_dependency "image_processing",       "~> 0.4"

    spec.add_dependency "execjs",                 "~> 2.6"
    spec.add_dependency "fastimage",              "~> 2.0"
    spec.add_dependency "guard",                  "~> 2.13"

    spec.add_dependency "rspec-rails",            "~> 3.5"

    spec.add_dependency "guard-jest",             "~> 0.1"
    spec.add_dependency "guard-rspec",            "~> 4.7"
    spec.add_dependency "hashie",                 "~> 3.3"

    spec.add_dependency "jobba",                  "~> 1.4"
    spec.add_dependency "jwt",                    "~> 1.5"
    spec.add_dependency "mini_magick",            "~> 4.3"

    spec.add_dependency "oj",                     "~> 2.1"
    spec.add_dependency "pg",                     "~> 0.8"
    spec.add_dependency "rake",                   "~> 12.0"
    spec.add_dependency "require_all",            "~> 1.3"
    spec.add_dependency "resque",                 "~> 1.27"
    spec.add_dependency "sanitize",               "~> 3.0"
    spec.add_dependency "webpack_driver",         "~> 0.2"
    spec.add_dependency "knitter",                "~> 0.2.2"

    spec.add_dependency "thor",                   "~> 0.19"

    spec.add_development_dependency "bundler",    "~> 1.5"
    spec.add_development_dependency "diffy",      "~> 3.0"
    spec.add_development_dependency "growl",      "~> 1.0"
    spec.add_development_dependency "shrine-memory", "~> 0.2"
end
