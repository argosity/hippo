module Lanes
    module API

        class RouteSet
            def initialize(root)
                @root = root
            end

            def draw(&block)
                @root.instance_eval(&block)
            end
        end

        def self.routes(&block)
            @routes ||= RouteSet.new(API::Root)
        end

    end
end
