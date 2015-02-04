require 'bundler'
Bundler.require
require_relative 'lib/<%= identifier %>'
require 'lanes/api'
run Lanes::API::Root
