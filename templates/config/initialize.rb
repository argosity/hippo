# This file will be loaded as part of Lanes startup.
#
# Extensions are called in load order, so be aware latter extensions may
# override config options specified
Lanes.configure do | config |
    # You can specify a different initial vew by setting it here
    # It must be set if the "Workspace" extension is disabled in
    # lib/<%= identifier %>/extension.rb
    # config.root_view = "<%= class_name %>.Screens.<View Name>"
end
