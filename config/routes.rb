require 'lanes/access/user'

module Lanes
    API.routes.draw do
        resources User
    end
end
