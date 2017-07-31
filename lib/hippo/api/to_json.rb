require 'oj'

module Hippo::API
    def self.to_json(data)
        Oj.dump(data)
    end
end
