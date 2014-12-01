module Lanes
    module Command

        class Generate < Thor

            long_desc Command.usage_from_file("generate_model")
            method_options( GenerateModel::OPTIONS )
            register Command::GenerateModel, 'model', 'model [NAME] ...FIELDS', 'Creates a new model'

            long_desc Command.usage_from_file("generate_screen")
            method_options( GenerateScreen::OPTIONS )
            register Command::GenerateScreen, 'screen', 'screen [NAME]', 'Creates a new Screen'

            long_desc Command.usage_from_file("generate_view")
            method_options( GenerateView::OPTIONS )
            register Command::GenerateView, 'view', 'view [NAME]', 'Creates a new View'

        end

    end
end
