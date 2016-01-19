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

    screens.define "system-settings" do | screen |
        screen.title       = "System Settings"
        screen.description = "Update System Settings"
        screen.icon        = "cogs"
        screen.group_id    = "system-settings"
        screen.model_class = "User"
        screen.view_class  = "SystemSettings"
        screen.js  = ''
        screen.css = ''
    end

end
