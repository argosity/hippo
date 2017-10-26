module Hippo::API::Handlers

    class Asset

        def self.deleter
            lambda do
                asset = ::Hippo::Asset.find(params['id'])
                asset.destroy
                json_reply std_api_reply(:destroy, asset, {})
            end
        end


        def self.saver
            lambda do
                model = params['owner_type'].underscore.camelize.constantize

                authentication = Hippo::API::AuthenticationProvider.new(request)
                authentication.wrap_model_access(model, self) do
                    owner = model.find(params['owner_id'])
                    asset = if params['id']
                                ::Hippo::Asset.find(params['id'])
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
                    asset.file = params['file']
                    json_reply std_api_reply asset.new_record? ? :update : :create,
                                             asset, success: asset.save
                end
            end
        end

        def self.file_getter
            root = Hippo::Extensions.controlling.root_path.join('public', 'files')
            lambda do
                send_file(root.join(params['splat'].first).to_s)
            end
        end

        def self.asset_getter
            webpack = Hippo::API::Root.webpack
            if Hippo.env.production?
                lambda do
                    begin
                        file = webpack.file(params['asset'].to_sym, raise_on_not_found: false)
                        if file
                            response['Cache-Control'] = "public, max-age=0, must-revalidate"
                            redirect "/assets/#{file}"
                        else
                            halt 404
                        end
                    rescue Hippo::Webpack::NotFound
                        halt 404
                    end
                end
            else
                lambda do
                    webpack.wait_until_available
                    file = webpack.file(params['asset'].to_sym, raise_on_not_found: false)
                    if file
                        protocol = 'http'
                        protocol += 's' if Hippo::Webpack.using_ssl?
                        redirect "#{protocol}://#{env['SERVER_NAME']}:#{webpack.process.port}/assets/#{file}"
                    else
                        halt 404
                    end
                end
            end
        end

    end
end
