Lanes::API.routes.draw do
    resources AppyApp::TestTest
    # Set default view for the site root.  Adjust to fit your needs
    root_view :lanes_root_view
end
