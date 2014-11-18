module <%= namespace %>

    class Extension < Lanes::Extension

        identifier "<%= name %>"

        client_roots Pathname.new(__FILE__).dirname.join("..","..","client").entries
    end

end
