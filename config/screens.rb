Hippo::Screen.define_group "system-settings" do | group |
    group.title       = "Settings"
    group.description = "Modify system settings"
    group.icon        = "wrench"
end

Hippo::Screen.for_extension 'hippo' do | screens |

    # screens.define "user-preferences" do | screen |
    #     screen.title       = "User Preferences"
    #     screen.description = "Modify User Profile"
    #     screen.icon        = "user-secret"
    #     screen.group_id    = "system-settings"
    #     screen.model_class = "User"
    #     screen.view_class  = "UserPreferences"
    #     screen.asset  = 'user'
    # end
    screens.define "user-management" do | screen |
        screen.title       = "User Management"
        screen.description = "Add/Remove/Modify User Accounts"
        screen.icon        = "group"
        screen.group_id    = "system-settings"
        screen.model_class = "SystemSettings"
        screen.view_class  = "UserManagement"
        screen.asset       = 'hippo/screens/user-management'
    end

    screens.define "system-settings" do | screen |
        screen.title       = "System Settings"
        screen.description = "Update System Settings"
        screen.icon        = "cogs"
        screen.group_id    = "system-settings"
        screen.model_class = "SystemSettings"
        screen.asset       = 'hippo/screens/system-settings'
    end

    # screens.define "workspace-layout" do | screen |
    #     screen.url_prefix  = 'hippo/workspace'
    #     screen.js  = 'index.jsx'
    #     # screen.css = 'styles.scss'
    # end
end
