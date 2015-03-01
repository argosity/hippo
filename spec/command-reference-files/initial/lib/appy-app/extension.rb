require_relative '../appy-app'

module AppyApp

    class Extension < Lanes::Extensions::Definition

        identifier "appy-app"

        root_path Pathname.new(__FILE__).dirname.join("..","..").expand_path

    end

end
