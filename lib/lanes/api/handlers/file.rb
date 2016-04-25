module Lanes::API::Handlers

    class File

        def self.saver
            lambda do
                Lanes.logger.debug "Saving File. Root=#{CarrierWave.root}"
                path = "#{params['extension_id']}/#{params['type']}"
                model = path.underscore.camelize.constantize
                authentication = Lanes::API::AuthenticationProvider.new(request)
                authentication.wrap_model_access(model, self) do
                    record = model.find(params['id'])
                    params['files'].each do |attr, data|
                        record.send(attr).store!( data )
                    end
                    record.save!
                    json_reply std_api_reply :create, { model: record }, success: true
                end
            end
        end

        def self.getter
            Lanes::API::RequestWrapper.with_authenticated_user do |user, req|
                req.send_file CarrierWave::Uploader::Base.root.call + '/' + req.params['splat'].first
            end
        end
    end
end
