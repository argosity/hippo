Lanes.Workspace.create = function(selector, options, extension_data){
    return new Lanes.Workspace.Instance(selector, options, extension_data);
};

Lanes.Workspace.Instance = class Instance {

    constructor(selector, options, extension_data){
        _.extend(this,options);

        this.viewport = new Lanes.Views.Viewport({ selector: selector, instance: this });
        Lanes.Data.Bootstrap.initialize({
            csrf: options.csrf_token,
            root: options.root_path,
            data: extension_data
        });
        Lanes.$(document).ready( ()=> {
            this.boot();
        });
    }

    boot(){
        this.root = Lanes.$( this.viewport.selector );
        this.root.data().workspace = this;
        this.viewport.root = this.root;

        Lanes.lib.ResizeSensor(this.root[0],  _.bind( _.debounce( function(){
            this.viewport.set({ width: this.root.width(), height: this.root.height() });
        }, 250 ), this) );

        this.root.addClass('lanes root');
        this.root.tooltip({
            viewport: '.lanes',
            selector: '[data-tooltip-message]',
            title: function(){ return this.getAttribute('data-tooltip-message'); }
        });
        var view = Lanes.getPath(this.view);
        if (view){
            this.displayInitialView(view);
        } else {
            var definition=Lanes.Data.Screens.all.findWhere({view: this.view});
            if (definition){
                definition.getScreen().then( (screen)=>{
                    // break out of the promise so an errors during render get thrown properly
                    _.defer( ()=>{ this.displayInitialView(screen); } );
                }, (msg)=>{
                    Lanes.fatal("Unable to load initial screen ${this.view}", msg);
                });
            } else {
                Lanes.fatal(this.view + " doesn't exist!");
            }
        }
    }

    displayInitialView(view){
        this.view = new view({parent: this, model: this.viewport}).render();
        this.viewport.el = this.view.$el;

        this.root.append( this.view.el );

        Lanes.Views.Keys.initialize();
        Lanes.Data.PubSub.initialize();
        Lanes.Extensions.fireOnAvailable(this);
    }
};
