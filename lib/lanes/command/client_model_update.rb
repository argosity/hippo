module Lanes
    module Command

        module ClientModelUpdate
            # @param file [Pathname] file to replace the props on
            def replace_props(file, columns)
                contents = file.read
                match = contents.match(/\n(\s+props\s*:\s*)\n+(\s+)\w/m)
                if !match
                    raise Thor::Error.new("Unable to detect existing props section")
                end
                (props,indent) = match.capture3
p match
                maxlen = columns.map{|field| field.name.length }.max

                contents = "#{props}"
                columns.each do | column |
                    contents << sprintf("#{indent}%-#{maxlen+1}s",column.name+':') + type_specification(column) + "\n"
                end
puts contents
#                gsub_file file, /\n\s+props\s*:\s*\n.*?\n\n/m, contents

#     props:
# <% len = max_name_length(@columns)
#    @columns.each do | column | -%>
#         <%= sprintf("%-#{len+1}s",column.name+':') -%> <%= type_specification(column) %>
# <% end -%>

# <% if @associations.any? -%>
#     associations:
# <% len = max_name_length(@associations)
#    @associations.each do | assoc | -%>
#         <%= sprintf("%-#{len+2}s",assoc.name.to_s+':') -%> { <%= assoc.collection? ? 'collection' : 'model' -%>: "<%= assoc.class_name.demodulize %>" }
# <% end -%>
# <% end -%>




            end



        end
    end
end


__END__

    props:
<% fields.each do |field| -%>
<% if field.reference? -%>
        <%= sprintf("%-#{max_field_length}s",field.name+'_id') %>: "<%= field.client_type %>"
<% else -%>
        <%= sprintf("%-#{max_field_length}s",field.name) %>: "<%= field.client_type %>"
<% end -%>
<% end %>
<% if reference_fields.any? -%>

    associations:
<% reference_fields.each do |field| -%>
        <%= sprintf("%-#{max_field_length}s ",field.name) %>: { <%= field.belongs_to? ? 'model' : 'collection' -%>: "Lanes.<%= namespace.camelize %>.<%= field.name.camelize %>" }
<% end -%>
<% end -%>
