# An example of how to define a screen group
# Hippo::Screen.define_group 'appy-app-screens' do | group |
#     group.title       = "AppyApp Screens"
#     group.description = "Screens relating to AppyApp"
#     group.icon        = "heart"
# end

Hippo::Screen.for_extension 'appy-app' do | screens |
    screens.define "ready-set-go" do | screen |
        screen.title       = "Ready Set Go"
        screen.description = ""
        screen.icon        = ""
        screen.group_id    = ""
        screen.model_class = ""
        screen.view_class  = "ReadySetGo"
    end

end
