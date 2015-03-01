require 'bundler'
Bundler.require
require_relative 'lib/appy-app'
require 'lanes/api'
run Lanes::API::Root
