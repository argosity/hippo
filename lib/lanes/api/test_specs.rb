require 'jasmine-core'

module Lanes
    module API


        class TestSpecs

            cattr_accessor :current

            attr_accessor :extension
            def initialize(ext)
                @extension = ext
            end

            def css_files
                urlpath Jasmine::Core.css_files
            end

            def js_files
                [ '/assets/lanes/testing' ] +
                urlpath(Jasmine::Core.js_files)   +
                urlpath(Jasmine::Core.boot_files) +
                urlpath(spec_files(extension.identifier))
            end

          private

            def spec_files(path)
                dir = extension.root_path.join("spec")
                regex = /^#{dir}\//
                Dir.glob( dir.join(path,"**/*.{coffee,js}") ).map do |file|
                    file.sub(regex,'').sub(/coffee$/,'js')
                end
            end

            def urlpath(files)
                files.map{ |file| "/spec/"+file }
            end
        end

        ext = Extensions.controlling
        TestSpecs.current = TestSpecs.new(ext)
        Root.sprockets.append_path(ext.root_path.join("spec"))
        Root.sprockets.append_path(Jasmine::Core.path)

        routes.draw do

            get '/spec' do
                content_type 'text/html'
                erb :specs, locals: { specs: TestSpecs.current }
            end

            get "/spec/*" do |path|
                env_sprockets = request.env.dup
                env_sprockets['PATH_INFO'] = path
                settings.sprockets.call env_sprockets
            end

        end
    end
end
