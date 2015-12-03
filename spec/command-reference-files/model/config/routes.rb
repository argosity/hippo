Lanes::API.routes.draw do
    resources AppyApp::TestTest
    # Load Lanes at the site root.  Adjust to fit your needs
    get '/' do
        erb :lanes_root_view
    end
end
