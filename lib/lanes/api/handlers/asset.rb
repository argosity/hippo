module Lanes::API::Handlers

    class Asset

        def self.saver
            lambda do
                model = params['owner_type'].underscore.camelize.constantize

                authentication = Lanes::API::AuthenticationProvider.new(request)
                authentication.wrap_model_access(model, self) do
                    owner = model.find(params['owner_id'])
                    asset = if params['id']
                                ::Lanes::Asset.find(params['id'])
                            else
                                assoc = owner.class.reflections[
                                    params['owner_association']
                                ]
                                if assoc.collection?
                                    owner.send(params['owner_association']).build
                                else
                                    owner.send("build_#{params['owner_association']}")
                                end
                            end

                    asset.update(file: params['file'])

                    json_reply std_api_reply asset.new_record? ? :update : :create,
                                             asset,
                                             success: asset.save
                end
            end
        end

        def self.getter
            root = Lanes::Extensions.controlling.root_path.join('public', 'files')
            lambda do
                send_file(root.join( params['splat'].first ).to_s)
            end
        end
    end
end
