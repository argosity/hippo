require 'mini_magick'
require 'carrierwave'
require 'fastimage'

module Lanes::Concerns

    class ImageUploader < CarrierWave::Uploader::Base

        include CarrierWave::MiniMagick

        version :medium do
            process :resize_to_fill => [800, 800]
        end

        version :thumb do
            process :resize_to_fill => [200,200]
        end

        def cache_dir
            '/tmp'
        end

        def store_dir
            "images/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
        end

        def filename
            if original_filename.present?
                ext = FastImage.type(file.file)
                "#{secure_token}.#{ext}"
            end
        end

        protected

        def secure_token
            var = :"@#{mounted_as}_secure_token"
            model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.hex(6))
        end
    end

end
