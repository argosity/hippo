require 'shrine'
require 'image_processing/mini_magick'

module Hippo::Concerns

    class AssetUploader < Shrine
        module LocationHash
            module InstanceMethods
                CHAR_CHOICES = [*('a'..'z'),*('0'..'9')]
                def generate_location(io, context)
                    basename, _ = super.split("/")
                    path = Array.new(3){ CHAR_CHOICES.shuffle[0,4].join }
                    path.push(basename).join('/')
                end
            end
        end
        ::Shrine::Plugins.register_plugin(:location_hash, LocationHash)

        include ImageProcessing::MiniMagick

        plugin :activerecord
        plugin :rack_file
        plugin :processing
        plugin :store_dimensions
        plugin :determine_mime_type
        plugin :versions
        plugin :location_hash


        process(:store) do |io, context|
            if io.metadata['mime_type'] && io.metadata['mime_type'].starts_with?('image')
                size_1000 = resize_to_limit(io.download, 1000, 1000)
                size_600 = resize_to_limit(size_1000,     600, 600)
                size_300 = resize_to_limit(size_600,      300, 300)
                {original: io, large: size_1000, medium: size_600, thumbnail: size_300}
            else
                {original: io}
            end
        end

    end

end
