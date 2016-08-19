REACT_CACHE = Object.create(null)

Lanes.lib.HotReload =

    remember: (klass) ->
        return unless klass::FILE
        path = klass::FILE.path.join("/") + ".js"
        if REACT_CACHE[path]
            return klass
        else
            REACT_CACHE[path] = Lanes.Vendor.ReactProxy(klass)
            return REACT_CACHE[path].get()

    replaceCss: (asset) ->
        styles = document.head.querySelectorAll("link[rel='stylesheet'][href*='#{asset.path}']")
        for link in _.toArray(styles)[0..-2]
            link.parentElement.removeChild(link)

    replaceProps: (asset) ->
        klass = Lanes.u.objectForPath(asset.path)
        if klass and REACT_CACHE[asset.path]
            REACT_CACHE[asset.path].update(klass)
            for viewport in Lanes.React.Viewport.all()
                Lanes.Vendor.deepForceUpdate(viewport.reactRoot)

    initiate: (assets) ->
        Lanes.lib.RequestAssets (_.map(assets, 'path'))...
            .then (a) =>
                for asset in assets
                    if asset.type == "css"
                        this.replaceCss(asset)
                    else
                        this.replaceProps(asset)
