class Lanes.lib.AssetLoader

    constructor: (urls, cb) ->
        finished = 0
        completed = {}
        onComplete = (url, success, error = false) ->
            finished += 1
            completed[url] = { success: success == true, error: error }
            cb(completed) if finished == urls.length

        for baseUrl in urls
            url = "#{baseUrl}?#{parseInt(Math.random() * 100000)}"
            if /.css($|\?)/.test(url)
                Lanes.lib.loader.css(url, onComplete)
            else
                Lanes.lib.loader.js(url, onComplete)

Lanes.lib.RequestAssets = (urls...) ->
    urls = urls[0] if urls.length == 1 && _.isArray(urls[0])
    new _.Promise(  (resolve, reject) ->

        new Lanes.lib.AssetLoader(urls, (completed) ->
            failures = _.pick(completed, (status, url) -> !status.success )
            if _.isEmpty(failures)
                resolve(completed)
            else
                Lanes.warn( _.keys(failures).join(',') + " failed to load" )
                reject( failures )
        )
    )
