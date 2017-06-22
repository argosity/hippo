module Rails
    def self.root
        Hippo::Extensions.controlling.root_path
    end

    def self.application
        Hippo::Extensions.controlling
    end
end
