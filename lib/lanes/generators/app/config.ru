require 'bundler'
Bundler.require
require 'lanes/api'
require_relative 'lib/<%= namespace %>'
run Lanes::API::Root
