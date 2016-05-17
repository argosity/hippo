require 'mini_magick'
require 'carrierwave'
require 'fastimage'

module Lanes::Concerns

    class AssetUploader < CarrierWave::Uploader::Base

        include CarrierWave::MiniMagick

        process :store_attributes

        version :medium,  :if => :image? do
            process :resize_to_fit => [800, 800]
        end

        version :thumbnail,  :if => :image? do
            process :resize_to_fit => [200,200]
        end

        def cache_dir
            '/tmp'
        end

        def filename
            if original_filename && model && model.read_attribute(mounted_as).present?
                model.read_attribute(mounted_as)
            end
        end

        def store_dir
            token = secure_token
            "#{token[0, 2]}/#{token[2, 2]}"
        end

        protected

        def store_attributes
            if file && model
                model.metadata['size'] = file.size
                model.metadata['content_type'] = file.content_type
                if image?(file)
                    img = ::MiniMagick::Image.open(file.file)
                    model.metadata['width'] = img.width
                    model.metadata['height'] = img.height
                end
            end
        end

        def image?(new_file)
            new_file.content_type.include? 'image'
        end

        def secure_token
            model[mounted_as] ||= ::Lanes::Strings.random
        end

    end

end
