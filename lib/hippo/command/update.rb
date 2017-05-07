module Hippo
    module Command

        class Update < Thor

            desc 'update model [NAME]', 'Updates a model'
            long_desc Command.usage_from_file("update_model")
            register Command::UpdateModel, 'model', 'model [NAME]', 'Updates a client model to match the server definition'

        end

    end
end
