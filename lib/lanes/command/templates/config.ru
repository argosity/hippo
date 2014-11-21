require 'bundler'
Bundler.require
require_relative 'lib/<%= file_name %>'
require 'lanes/api'
run Lanes::API::Root
