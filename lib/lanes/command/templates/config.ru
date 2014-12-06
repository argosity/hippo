require 'bundler'
Bundler.require
require_relative 'lib/<%= namespace %>'
require 'lanes/api'
run Lanes::API::Root
