require 'oj'

module Lanes::API
    def self.to_json(data)
        Oj.dump(data, mode: :compat, time_format: :ruby)
    end
end
