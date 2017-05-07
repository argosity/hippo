# This file will be loaded as part of Hippo startup.
#
# Extensions are called in load order, so be aware latter extensions may
# override config options specified
Hippo.configure do | config |
    # You can specify a different initial vew by setting it here
    # It must be set if the "Workspace" extension is disabled in
    # lib/appy-app/extension.rb
    # config.root_view = "AppyApp.Screens.<View Name>"
end
