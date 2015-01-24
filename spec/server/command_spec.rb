require_relative "spec_helper"
require "lanes/cli"
require "find"


describe Lanes::Command do
    let(:lanes) { Pathname.new(__FILE__).dirname.join('..','..','bin','lanes') }

    around do |test|
        Dir.mktmpdir do |dir|
            @dir = dir
            Dir.chdir(dir) do
                `#{lanes} new test`
                Dir.chdir("test") do
                    test.call
                end
            end
        end
    end

    FILES = [".", ".gitignore", "Gemfile", "Guardfile", "Rakefile", "client", "client/test", "client/test/Extension.coffee", "client/test/Router.coffee", "client/test/components", "client/test/components/.gitkeep", "client/test/controllers", "client/test/controllers/.gitkeep", "client/test/index.js", "client/test/models", "client/test/models/.gitkeep", "client/test/models/Base.coffee", "client/test/screens", "client/test/screens/.gitkeep", "client/test/screens/Base.coffee", "client/test/styles.scss", "client/test/views", "client/test/views/.gitkeep", "client/test/views/Base.coffee", "config", "config.ru", "config/database.yml", "config/lanes.rb", "config/routes.rb", "config/screens.rb", "db", "db/.gitkeep", "lib", "lib/test", "lib/test.rb", "lib/test/extension.rb", "lib/test/model.rb", "lib/test/version.rb", "log", "log/.gitkeep", "spec", "spec/server", "spec/server/spec_helpers.rb", "spec/test", "spec/test/helpers", "spec/test/helpers/TestHelpers.coffee", "spec/test/screens", "spec/test/screens/Base.coffee", "tmp", "tmp/.gitkeep"]

    it "generates an application" do
        files = Find.find(".").to_a.map{|f| f.gsub(/^\.\//,'') }.sort
        files.sort.must_equal FILES.sort
    end

    it "creates a view" do
       assert_executes "#{lanes} generate view Test"
       assert_match( /client\/test\/views\/Test.coffee/, last_cmd_execution_output )
       assert_executes "#{lanes} generate view Testing --screen Base"
       assert_match( /client\/test\/screens\/Base\/Testing.coffee/, last_cmd_execution_output )
    end

    it "creates a model" do
       assert_executes "#{lanes} generate model Test"
       assert_match( /client\/test\/models\/Test.coffee/, last_cmd_execution_output )
    end
end
