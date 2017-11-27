Hippo::Screen.define_group "system-settings" do | group |
    group.title       = "Settings"
    group.description = "Modify system settings"
    group.icon        = "wrench"
end

Hippo::Screen.for_extension 'hippo' do | screens |
    screens.define "preferences" do | screen |
        screen.title       = "Preferences"
        screen.description = "User Preferences"
        screen.icon        = "heartbeat"
        screen.group_id    = "system-settings"
        screen.asset       = 'hippo/screens/preferences'
    end

    screens.define "user-management" do | screen |
        screen.title       = "User Management"
        screen.description = "Add/Remove/Modify User Accounts"
        screen.icon        = "group"
        screen.group_id    = "system-settings"
        screen.roles       = ['administrator']
        screen.asset       = 'hippo/screens/user-management'
    end

    screens.define "system-settings" do | screen |
        screen.title       = "System Settings"
        screen.description = "Update System Settings"
        screen.icon        = "cogs"
        screen.group_id    = "system-settings"
        screen.roles       = ['administrator']
        screen.asset       = 'hippo/screens/system-settings'
    end

end
