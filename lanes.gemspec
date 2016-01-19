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

    spec.add_dependency "activerecord",           "~> 4.2"
    spec.add_dependency "pg",                     "~> 0.17"
    spec.add_dependency "sinatra",                "~> 1.4"
    spec.add_dependency "bcrypt",                 "~> 3.1"
    spec.add_dependency "oj",                     "~> 2.1"
    spec.add_dependency "message_bus",            "~> 1.0"
    spec.add_dependency "rack_csrf",              "~> 2.5"
    spec.add_dependency "sprockets",              "~> 3.0"
    spec.add_dependency "coffee-script",          "~> 2.3"
    spec.add_dependency "coffee-react",           "~> 3.0"
    spec.add_dependency "execjs",                 "~> 2.2"
    spec.add_dependency "thor",                   "~> 0.19"
    spec.add_dependency "sass",                   "~> 3.4"
    spec.add_dependency "sprockets-helpers",      "~> 1.2"
    spec.add_dependency "compass-import-once",    "~> 1.0"
    spec.add_dependency "guard",                  "~> 2.0"
    spec.add_dependency "hashie",                 "~> 3.3"
    spec.add_dependency "rack-test",              "~> 0.6"
    spec.add_dependency "minitest-around",        "~> 0.2"
    spec.add_dependency "mocha",                  "~> 1.1"
    spec.add_dependency "guard-minitest",         "~> 2.3"
    spec.add_dependency "yui-compressor",         "~> 0.12"
    spec.add_dependency "closure-compiler",       "~> 1.1"
    spec.add_dependency "guard-jasmine",          "~> 2.0"
    spec.add_dependency "rake",                   "~> 10.0"
    spec.add_dependency "jasmine-core",           "~> 2.0"
    spec.add_dependency "require_all",            "~> 1.3"
    spec.add_dependency "sanitize",               "~> 3.0"
    spec.add_dependency "carrierwave",            "~> 0.10.0"
    spec.add_dependency "fog",                    "~> 1.37.0"
    spec.add_dependency "mini_magick",            "~> 4.3.6"
    spec.add_dependency "fastimage",              "~> 1.8.1"
    spec.add_development_dependency "bundler",    "~> 1.5"
    spec.add_development_dependency "growl",      "~> 1.0"
    spec.add_development_dependency "diffy",      "~> 3.0"

end
