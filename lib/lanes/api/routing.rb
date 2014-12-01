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

        self.routes.draw do
            get '/' do
                content_type 'text/html'
                erb :index
            end

            get "default-records" do
                { success: true, data: Lanes::API.default_records }
            end

            Extensions.each do | ext |
                ext.route(self)
            end

        end


    end
end
