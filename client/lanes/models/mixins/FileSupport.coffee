isFileDefinition = (def) ->
    (_.isString(def) and def is 'file') or (_.isObject(def) and def.type is 'file')

Lanes.Models.Mixins.FileSupport = {

    included: (klass) ->
        files = _.pickBy klass::props, (def, name) -> isFileDefinition(def)
        return if _.isEmpty(files)
        session = {}
        for name, def of files
            session["#{name}_data"] = 'any'
            session["#{name}_file"] = 'any'
        _.extend( klass::session ||= {}, session)

    initialize: ->
        @on('save', @_uploadFileAfterSave)
        for name, def of @_definition when isFileDefinition(def)
            @on("change:#{name}_file", _.partial(@readPossibleImage, name))

    hasImage: (attr) ->
        this[attr] || this["#{attr}_data"]

    imageUrlFor: (attr, type = '') ->
        if this["#{attr}_data"]
            this["#{attr}_data"]
        else if (file = this[attr])
            if type then file[type].url else file.url
        else
            ''

    readPossibleImage: (name) ->
        return unless (file = this["#{name}_file"])
        reader = new FileReader()
        reader.onloadend = =>
            @["#{name}_data"] = reader.result
        reader.readAsDataURL(file)


    _uploadFileAfterSave: ->
        files = _.pickBy @_definition, (def, name) =>
            isFileDefinition(def) and @["#{name}_file"]
        return if _.isEmpty(files)

        form = new FormData()
        for name, def of files
            form.append("files[#{name}]", this["#{name}_file"], this["#{name}_file"].name)
        form.append("type", @modelTypeIdentifier())
        form.append("id", @getId())
        form.append("extension_id", @FILE.extension.identifier)
        url = Lanes.config.api_path + '/save-file-attribute'

        Lanes.Vendor.xhr.post(url, {body: form}, (err, resp, body) =>
            if err
                @errors = { http: err.message }
            else
                model = JSON.parse(body)?.data?.model
                @set(model)
                this["#{name}_data"] = this["#{name}_file"] = null for name, def of files
        )
}
