require 'shrine'
require 'image_processing/mini_magick'

module Lanes::Concerns

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
            size_800 = resize_to_limit(io.download, 800, 800)
            size_500 = resize_to_limit(size_800,    500, 500)
            size_300 = resize_to_limit(size_500,    300, 300)
            {original: size_800, medium: size_500, thumbnail: size_300}
        end

    end

end
