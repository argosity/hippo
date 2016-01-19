module Lanes::API::Handlers

    class File

        def self.saver
            lambda do
                path = "#{params['extension_id']}/#{params['type']}"
                model = path.underscore.camelize.constantize
                record = model.find(params['id'])
                params['files'].each do |attr, data|
                    record.send(attr).store!( data )
                end
                record.save!

                json_reply std_api_reply :create, { model: record }, success: true
            end
        end

        def self.getter
            lambda do
                send_file CarrierWave::Uploader::Base.root + '/' + params['splat'].first
            end
        end
    end
end
