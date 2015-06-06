# An example of how to define a screen group
# Lanes::Screen.define_group '<%= identifier %>-screens' do | group |
#     group.title       = "<%= namespace %> Screens"
#     group.description = "Screens relating to <%= namespace %>"
#     group.icon        = "heart"
# end

Lanes::Screen.for_extension '<%= namespace %>' do | screens |

end
