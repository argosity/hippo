require_relative "spec_helper"
require "lanes/cli"
require "diffy"
require "find"

describe Lanes::Command do
    let(:app_name)  { "appy-app" }
    let(:lanes)     { Pathname.new(__FILE__).dirname.join('..','..','bin','lanes') }
    let(:generated_path) { Pathname.pwd }
    let(:reference_path) { Pathname(__FILE__).dirname.join("..","command-reference-files") }

    around do |test|
        Dir.mktmpdir do |dir|
            @dir = dir
            Dir.chdir(dir) do
                assert_executes "#{lanes} new #{app_name}"
                Dir.chdir(app_name) do
                    test.call
                end
            end
        end
    end

    def compare_generated(reference)
        reference.find.each do | path |
            relative = path.relative_path_from(reference)
            generated = generated_path.join(relative)
            assert generated.exist?, "File was not created: #{relative}"
            next unless path.file?
            diff = Diffy::Diff.new(path.to_s, generated.to_s, source: 'files', context: 1)
            assert diff.to_s.empty?, "#{relative}\n #{diff}"
            # if !diff.to_s.empty? # update
            #     path.write(generated.read)
            # end
        end
    end

    it "generates an application" do
        reference = reference_path.join('initial')
        gemfile = reference.join("Gemfile")
        gemfile.write gemfile.read.gsub(/gem \"lanes\", \'\d+\.\d+\.\d+\'/, "gem \"lanes\", '#{Lanes::VERSION}'")


        compare_generated(reference)
        generated_path.find.each do | path |
            relative = path.relative_path_from(generated_path)
            reference_copy = reference.join(relative)
            assert reference_copy.exist?, "Created file that should not exist: #{relative}"
        end
    end

    it "generates a screen" do
        assert_executes "#{lanes} g screen ready-set-go"
        reference = reference_path.join('screen')
        compare_generated(reference)
    end

    it "generates a model" do
        ENV['MIGRATION_TIMESTAMP']='20150218032025'
        assert_executes "#{lanes} g model test-test name:string email:string"
        reference = reference_path.join('model')
        compare_generated(reference)
    end

    it "generates a component" do
        assert_executes "#{lanes} g component big"
        reference = reference_path.join('component')
        compare_generated(reference)
    end

end
