# An example of how to define a screen group
# Lanes::Screen.define_group 'appy-app-screens' do | group |
#     group.title       = "AppyApp Screens"
#     group.description = "Screens relating to AppyApp"
#     group.icon        = "heart"
# end

Lanes::Screen.for_extension 'AppyApp' do | screens |
    screens.define "ready-set-go" do | screen |
        screen.title       = "Ready Set Go"
        screen.description = ""
        screen.icon        = ""
        screen.group_id    = ""
        screen.model_class = ""
        screen.view_class  = "ReadySetGo"
        # Can optionally explicity set files to be included
        # screen.js          = "ready-set-go.js"
        # screen.css         = "ready-set-go.css"
    end

end
