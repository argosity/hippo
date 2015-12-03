module Lanes
    API.routes.draw do
        get "default-records" do
            { success: true, data: Lanes::API.default_records }
        end

        Extensions.each do | ext |
            ext.route(self)
        end
    end
end
