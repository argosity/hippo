Lanes.Workspace.create = (selector, options, extension_data)->
    return new Lanes.Workspace.Instance(selector, options, extension_data);


class Lanes.Workspace.Instance

    constructor: (selector, options)->
        this.viewport = new Lanes.Views.Viewport({ selector: selector, instance: this });
        Lanes.Data.Bootstrap.initialize({
            csrf: options.csrf_token,
            root: options.api_path,
            data: options
        });
        Lanes.$(document).ready => @boot(options)

    boot: (options)->
        this.root = Lanes.$( this.viewport.selector );
        this.root.data().workspace = this;
        this.viewport.root = this.root;

        Lanes.lib.ResizeSensor(this.root[0],  _.bind( _.debounce( =>
            @viewport.set({ width: this.root.width(), height: this.root.height() });
        , 250 ), this) );

        this.root.addClass('lanes root');
        this.root.tooltip({
            viewport: '.lanes'
            selector: '[data-tooltip-message]'
            title: => @getAttribute('data-tooltip-message')
        });
        Lanes.Views.Keys.initialize();
        Lanes.Data.PubSub.initialize() if options.pub_sub;
        
        view = Lanes.getPath(options.root_view);
        if view
            this.displayInitialView(view);
        else
            definition=Lanes.Data.Screens.all.findWhere({view: options.root_view});
            if definition
                definition.getScreen().then( (screen)=>
                    # break out of the promise so an errors during render get thrown properly
                    _.defer( => @displayInitialView(screen); )
                ,(msg)->
                    Lanes.fatal("Unable to load initial screen ${options.root_view}", msg);
                )
            else
                Lanes.fatal(options.root_view + " doesn't exist!");




    displayInitialView:(view)->
        this.view = new view({parent: this, model: this.viewport}).render();
        this.viewport.el = this.view.$el;

        this.root.append( this.view.el );
        Lanes.Extensions.fireOnAvailable(this);


