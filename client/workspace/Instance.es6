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
        this.root = Lanes.$( this.ui.selector );
        this.root.data().workspace = this;
        this.ui.root = this.root;

        Lanes.lib.ResizeSensor(this.root[0],  _.bind( _.debounce( function(a,b,c){
            this.ui.set({ viewport_width: this.root.width(), viewport_height: this.root.height() });
        }, 250 ), this) );

        this.root.addClass('lanes root');
        this.root.tooltip({
            viewport: '.lanes',
            selector: '[data-tooltip-message]',
            title: function(){ return this.getAttribute('data-tooltip-message'); }
        });

        var view = Lanes.getPath(this.view);
        if (!view){
            Lanes.fatal(this.view + " doesn't exist!");
        }
        this.view = new view({parent: this, model: this.ui}).render();
        this.ui.viewport = this.view.$el;

        this.root.append( this.view.el );

        Lanes.Views.Keys.initialize();
        Lanes.Data.PubSub.initialize();
        Lanes.Extensions.fireOnAvailable(this);

        this.login_dialog = new Lanes.Views.LoginDialog({ parent: this });

        // var screen = Lanes.Data.Screens.all.findWhere({ id: 'user-maintenance' });
        // screen.display();
    }
};
