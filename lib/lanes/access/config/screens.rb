Lanes::Screen.define_group "system-settings" do | group |
    group.title       = "System Settings"
    group.description = "Modify system settings"
    group.icon        = "wrench"
end

Lanes::Screen.for_extension 'access' do | screens |
    screens.define "user-management" do | screen |
        screen.title       = "User Management"
        screen.description = "Add/Remove/Modify User Accounts"
        screen.icon        = "group"
        screen.group_id    = "system-settings"
        screen.model_class = "User"
        screen.view_class  = "UserManagement"
        screen.url_prefix  = 'lanes/access/screens'
        screen.js  = 'user-management.js'
        screen.css = 'user-management.css'
    end
end
