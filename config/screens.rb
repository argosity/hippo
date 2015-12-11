Lanes::Screen.for_extension 'lanes' do | screens |

    screens.define "user-preferences" do | screen |
        screen.title       = "User Preferences"
        screen.description = "Modify User Profile"
        screen.icon        = "user-secret"
        screen.group_id    = "system-settings"
        screen.model_class = "User"
        screen.view_class  = "UserPreferences"
        screen.js  = ''
        screen.css = ''
    end

end
