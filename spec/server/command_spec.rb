require_relative "spec_helper"
require_relative "./assertions"
require "hippo/cli"
require "diffy"
require "find"

describe Hippo::Command do
    let(:app_name)  { "appy-app" }
    let(:hippo)     { Pathname.new(__FILE__).dirname.join('..','..','bin','hippo') }
    let(:generated_path) { Pathname.pwd }
    let(:reference_path) { Pathname(__FILE__).dirname.join("..","..", "command-reference-files") }

    around(:each) do | t |
        Dir.mktmpdir do |dir|
            @dir = dir
            Dir.chdir(dir) do
                RSpec::Mocks.with_temporary_scope do
                    allow_any_instance_of(Knitter::Yarn).to receive(:init).and_return(true)
                    allow_any_instance_of(Knitter::Yarn).to receive(:add).and_return(true)
                    expect("#{hippo} new #{app_name} --no-packages").to execute_successfully
                    Dir.chdir(app_name) do
                        t.call
                    end
                end
            end
        end
    end

    def compare_generated(reference)
        reference.find.each do | path |
            relative = path.relative_path_from(reference)
            generated = generated_path.join(relative)
            expect(generated).to exist, "File was not created: #{relative}"

            next unless path.file?
            diff = Diffy::Diff.new(path.to_s, generated.to_s, source: 'files', context: 1)
            # if !diff.to_s.empty? # update
            #     path.write(generated.read)
            # end
            expect(diff.to_s).to be_empty, "DIFF:\n#{diff.to_s}"
        end
    end

    it "generates an application" do
        reference = reference_path.join('initial')
        gemfile = reference.join("Gemfile")
        gemfile.write gemfile.read.gsub(/gem \"hippo\", \'\d+\.\d+\.\d+\'/, "gem \"hippo\", '#{Hippo::VERSION}'")

        compare_generated(reference)
        generated_path.find.each do | path |
            relative = path.relative_path_from(generated_path)
            reference_copy = reference.join(relative)
            expect(reference_copy).to exist, "Created file that should not exist: #{relative}"
        end
    end

    it "generates a screen" do
        expect("#{hippo} gen screen ready-set-go").to execute_successfully
        compare_generated(reference_path.join('screen'))
    end

    it "generates a model" do
        ENV['MIGRATION_TIMESTAMP']='20150218032025'
        expect("#{hippo} gen model test-test name:string email:string").to execute_successfully
        compare_generated(reference_path.join('model'))
    end

end
