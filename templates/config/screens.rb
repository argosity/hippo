# An example of how to define a screen group
# Hippo::Screen.define_group '<%= identifier %>-screens' do | group |
#     group.title       = "<%= namespace %> Screens"
#     group.description = "Screens relating to <%= namespace %>"
#     group.icon        = "heart"
# end

Hippo::Screen.for_extension '<%= identifier %>' do | screens |

end
