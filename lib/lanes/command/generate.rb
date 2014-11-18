module Lanes
    module Command

        class Generate < Thor

            desc 'generate model [NAME]', 'Creates or update a model'
            long_desc Pathname.new(__FILE__).dirname.join("generate_model.usage").read
            register Command::Model, 'model', 'model [NAME] ...FIELDS', 'Creates a new model'

        end

    end
end
