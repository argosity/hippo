Lanes::Screen.define "user-management" do | screen |
    screen.title       = "User Management"
    screen.description = "Add/Remove/Modify User Accounts"
    screen.icon        = "icon-group"
    screen.group_id    = "system-settings"
    screen.model_class = "User"
    screen.view_class  = "Lanes.Access.Screens.UserManagement"
    screen.js  = 'lanes/access/screens/user-management.js'
    screen.css = 'lanes/access/screens/user-management.css'
end

Lanes::Screen.define_group "system-settings" do | group |
    group.title       = "System Settings"
    group.description = "Modify system settings"
    group.icon        = "icon-wrench"
end
