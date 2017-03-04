Lanes::Screen.define_group "system-settings" do | group |
    group.title       = "Settings"
    group.description = "Modify system settings"
    group.icon        = "wrench"
end

Lanes::Screen.for_extension 'lanes' do | screens |

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
        screen.asset       = 'lanes/access/screens/user-management'
    end

    screens.define "system-settings" do | screen |
        screen.title       = "System Settings"
        screen.description = "Update System Settings"
        screen.icon        = "cogs"
        screen.group_id    = "system-settings"
        screen.model_class = "SystemSettings"
        screen.asset       = 'lanes/screens/system-settings'
    end

    # screens.define "workspace-layout" do | screen |
    #     screen.url_prefix  = 'lanes/workspace'
    #     screen.js  = 'index.jsx'
    #     # screen.css = 'styles.scss'
    # end
end
