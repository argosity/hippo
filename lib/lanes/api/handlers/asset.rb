module Lanes::API::Handlers

    class Asset

        def self.saver
            lambda do
                Lanes.logger.debug "Saving File. Root=#{CarrierWave.root}"

                path = "#{params['extension_id']}/#{params['owner_type']}"
                model = path.underscore.camelize.constantize

                authentication = Lanes::API::AuthenticationProvider.new(request)
                authentication.wrap_model_access(model, self) do
                    owner = model.find(params['owner_id'])
                    asset = if params['id']
                                ::Lanes::Asset.find(params['id'])
                            else
                                owner.send("build_#{params['owner_association']}")
                            end
                    asset.store_uploaded_file(params['file'])

                    json_reply std_api_reply asset.new_record? ? :update : :create,
                                             asset,
                                             success: asset.save
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
