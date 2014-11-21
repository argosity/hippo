require 'jasmine-core'

module Lanes
    module API

        class TestSpecs
            cattr_accessor :current

            def initialize(root)
                @root = root
            end

            def css_files
                urlpath Jasmine::Core.css_files
            end

            def js_files
                urlpath(Jasmine::Core.js_files)   +
                urlpath(Jasmine::Core.boot_files) +
                urlpath(spec_files("helpers"))    +
                urlpath(spec_files("client"))
            end

          private

            def spec_files(path)
                dir = @root.join("spec")
                regex = /^#{dir}\//
                Dir.glob( dir.join(path,"**/*.{coffee,js}") ).map do |file|
                    file.sub(regex,'').sub(/coffee$/,'js')
                end
            end

            def urlpath(files)
                files.map{ |file| "/spec/"+file }
            end
        end


        Lanes.config.get(:specs_root) do | root |
            TestSpecs.current = TestSpecs.new(root)
            Root.sprockets.append_path(root.join("spec"))
        end


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
