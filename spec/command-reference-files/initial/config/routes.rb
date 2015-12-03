Lanes::API.routes.draw do
    # Load Lanes at the site root.  Adjust to fit your needs
    get '/' do
        erb :lanes_root_view
    end
end
