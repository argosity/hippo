# This file will be loaded if the current extension is the
# one controlling Lanes.
#
# It will not be evaluated if another extension is loading this one
Lanes.configure do | config |
    config.root_view = "<%= class_name %>.Screens.<%= class_name %>"
end
