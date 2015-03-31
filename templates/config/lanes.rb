# This file will be loaded if the current extension is the
# one controlling Lanes.
#
# It will not be evaluated if another extension is loading this one
Lanes.configure do | config |
    # You can specify a different initial vew by setting it here
    # It must be set if the "Workspace" extension is disabled in
    # lib/<%= identifier %>/extension.rb
    # config.root_view = "<%= class_name %>.Screens.<View Name>"
end
