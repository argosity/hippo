module Hippo
    module Command

        class Generate < Thor

            long_desc Command.usage_from_file("generate_model")
            method_options( GenerateMigration::OPTIONS )
            register Command::GenerateMigration, 'migration', 'migration [NAME] ...FIELDS', 'Creates a new migration'
            long_desc Command.usage_from_file("generate_model")
            method_options( GenerateModel::OPTIONS )
            register Command::GenerateModel, 'model', 'model [NAME] ...FIELDS', 'Creates a new model'

            long_desc Command.usage_from_file("generate_screen")
            method_options( GenerateScreen::OPTIONS )
            register Command::GenerateScreen, 'screen', 'screen [NAME]', 'Creates a new Screen'

            long_desc Command.usage_from_file("generate_component")
            method_options( GenerateComponent::OPTIONS )
            register Command::GenerateComponent, 'component', 'component [NAME]', 'Creates a new Component to be shared between screens'

        end

    end
end
