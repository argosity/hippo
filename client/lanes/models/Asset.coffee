IMAGES = [
    "image/png", "image/jpg", "image/gif"
]

IS_IMAGE = (content_type) ->
    !!(content_type && IMAGES.indexOf(content_type) isnt -1)

class Lanes.Models.Asset extends Lanes.Models.Base

    props:
        id:        'integer'
        order:     'integer'
        file_data: 'object'

    session:
        data:     'string'
        blob:     'object'
        owner:    'object'
        parent:   'object'
        metadata: 'object'
        parent_association: 'string'

    derived:
        original_url:
            deps: ['data', 'file_data'], fn: ->
                if @data then @data else @urlFor('original')
        medium_url:
            deps: ['data', 'file_data'], fn: ->
                if @data then @data else @urlFor('medium')
        thumbnail_url:
            deps: ['data', 'file_data'], fn: ->
                if @data then @data else @urlFor('thumbnail')

        isPresent:
            deps: ['data', 'file_data'], fn: ->
                @data || !_.isBlank(@file_data)

        hasImage:
            deps: ['data', 'file_data'], fn: ->
                (@data && IS_IMAGE(@metadata.content_type)) ||
                    (@file_data && IS_IMAGE(@file_data.original?.metadata.mime_type))
    events:
        'change:blob': 'onBlobChange'

    initialize: ->
        @on('change:parent', =>
            oldParent = _this. previousAttributes().parent
            @stopListening(oldParent, 'save', @save) if oldParent
            @listenTo(@parent, 'save', @save)
        )

    baseUrl: ->
        Lanes.config.api_path + '/asset'

    urlFor: (type) ->
        data = @file_data[type]
        if data then "#{@baseUrl()}/#{data.id}" else undefined

    onBlobChange: ->
        if @blob
            @metadata = { content_type: @blob.type }
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
            if err
                @errors = { http: err.message }
            else
                reply = JSON.parse(body)
                if reply.errors or reply.success is false
                    @errors = reply.errors
                else
                    @metadata = @blob = @data = null
                    @set( reply.data )
        )
