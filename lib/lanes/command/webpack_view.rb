require 'erb'
require 'ostruct'

module Lanes::Command

    class WebpackView

        attr_reader :directory, :erb, :view, :ext

        def initialize(view)
            @ext = Lanes::Extensions.controlling
            @directory = ext.root_path.join('tmp')
            @view = view
            @erb = ERB.new(ext.root_path.join('views', view).read)
        end

        def write
            destination.write erb.result(binding)
        end

        def destination
            directory.join(view)
        end

        def include(partial, locals = {})
            subview = ERB.new(ext.root_path.join('views', partial).read)
            context = OpenStruct.new(locals).instance_eval { binding }
            subview.result(context)
        end
    end

end
