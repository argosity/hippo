module <%= namespace %>

    # All models in <%= namespace %> will inherit from
    # this common base class.
    class Model < Hippo::Model

        self.abstract_class = true

    end

end
