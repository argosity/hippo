REACT_CACHE = {}

Lanes.lib.HotReload =

    rememberReact: (klass) ->
        return unless klass::FILE
        path = klass::FILE.path.join("/") + ".js"
        unless REACT_CACHE[path]
            REACT_CACHE[path] = klass
            Lanes.Vendor.hotRL(klass, path)

    replaceCss: (asset) ->
        styles = document.head.querySelectorAll("link[rel='stylesheet'][href*='#{asset.path}']")
        for link in _.toArray(styles)[0..-2]
            link.parentElement.removeChild(link)

    replaceProps: (asset) ->
        klass = Lanes.u.objectForPath(asset.path) # Lanes.StockorDemo.LoginDialog
        Lanes.Vendor.hotRL(klass, asset.path) if klass

        # Need to copy new proto over the old one
        # unsure how to identify new and old one's though
        # else
        #     for klass in prev

    initiate: (assets) ->
        console.log _.pluck(assets, 'path')

        Lanes.lib.RequestAssets (_.pluck(assets, 'path'))...
            .then (a) =>
                for asset in assets
                    if asset.type == "css"
                        this.replaceCss(asset)
                    else
                        this.replaceProps(asset)
