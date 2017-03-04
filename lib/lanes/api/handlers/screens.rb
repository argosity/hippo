require_relative '../../access/user'

require 'irb'

module Lanes::API::Handlers

    module Screens
        def self.get
            lambda do
                authentication = Lanes::API::AuthenticationProvider.new(request)
                if authentication.current_user.nil?
                    return json_reply std_api_reply :get, {}, success: true
                end
                screens = Lanes::Screen.select do | screen |
                    authentication.current_user.can_read?(screen.model)
                end
                # Lanes::Screen.each_group
                json_reply std_api_reply :get, {
                                             screens: screens.map{|s| s.identifier }
                                         }, success: true
            end
        end

    end

end
