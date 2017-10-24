module Precision

    def precision(number, precision)
        sprintf("%.#{precision}f", number)
    end

end

Liquid::Template.register_filter(Precision)
