module <%= namespace.camelize %>

    # All models in <%= namespace.camelize %> will inherit from
    # this common base class.
    class Model < Lanes::Model

        self.abstract_class = true

    end

end
