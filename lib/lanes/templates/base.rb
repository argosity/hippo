module Lanes

    module Templates

        class Base
            include ::Lanes::Concerns::AttrAccessorWithDefault

            class_attribute :defined_format

            attr_accessor_with_default :extension_id

            def self.format(fmt)
                self.defined_format = fmt
            end

            def root_path
                Lanes::Extensions.for_identifier(extension_id.to_s).root_path.join('templates')
            end

            def pathname
                root_path.join(filename)
            end

            def class_as_name
                self.class.to_s.demodulize.underscore
            end

            def filename
                class_as_name + self.extension
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
