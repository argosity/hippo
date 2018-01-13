module Hippo

    module Templates

        class Base
            include ::Hippo::Concerns::AttrAccessorWithDefault

            class_attribute :defined_format
            attr_reader :variables
            attr_reader :basename

            attr_accessor_with_default :extension_id

            def self.format(fmt)
                self.defined_format = fmt
            end

            def root_path
                Hippo::ROOT_PATH.join('templates')
            end

            def pathname
                root_path.join(filename)
            end

            def class_as_name
                self.class.to_s.demodulize.underscore
            end

            def filename
                bn = basename || class_as_name
                bn + extension
            end

            def source
                pathname.read
            end

            def extension
                '.' + defined_format.to_s
            end

        end

    end

end
