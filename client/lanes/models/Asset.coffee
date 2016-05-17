class Lanes.Models.Asset extends Lanes.Models.Base

    props:
        id:        'integer'
        order:     'integer'
        thumbnail: 'object'
        medium:    'object'
        original:  'object'
        metadata:  'object'

    session:
        data: 'string'
        blob: 'object'
        owner: 'object'
        parent: 'object'
        parent_association: 'string'

    derived:
        original_url:
            deps: ['data', 'original'], fn: ->
                if @data then @data else @original?.url
        medium_url:
            deps: ['data', 'medium'], fn: ->
                if @data then @data else @medium?.url
        thumbnail_url:
            deps: ['data', 'thumbnail'], fn: ->
                if @data then @data else @thumbnail?.url

        hasImage:
            deps: ['data', 'original', 'metadata'], fn: ->
                @metadata?.content_type?.includes?('image')
    events:
        'change:blob': 'onBlobChange'
        'parent:save': 'onParentSave'

    initialize: ->
        @on('change:parent', =>
            oldParent = _this. previousAttributes().parent
            @stopListening(oldParent, 'save', @save) if oldParent
            @listenTo(@parent, 'save', @save)
        )


    onBlobChange: ->
        if @blob
            @metadata ||= {}
            @metadata.content_type = @blob.type
            reader = new FileReader()
            reader.onloadend = (ev) =>
                @data = reader.result if ev.type is 'loadend'
            reader.readAsDataURL(@blob)

        else
            @data = null
            @mdatadata?.content_type = undefined


    save: ->
        return unless @blob

        form = new FormData()
        form.append("id", @id) if @id
        form.append("file", @blob, @blob.name)
        form.append("owner_type", _.classify(@parent.modelTypeIdentifier()))
        form.append("owner_id", @parent.getId())
        form.append("owner_association", @parent_association)
        form.append("extension_id", @parent.extensionIdentifier())

        url = Lanes.config.api_path + '/asset'

        Lanes.Vendor.xhr.post(url, {body: form}, (err, resp, body) =>
            @blob = null
            if err
                @errors = { http: err.message }
            else
                reply = JSON.parse(body)
                if reply.errors or reply.success is false
                    @errors = reply.errors
                else
                    @set( reply.data )
        )
