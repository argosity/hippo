class Lanes.Components.ImageAsset extends Lanes.React.Component

    propTypes:
        asset: Lanes.PropTypes.Model.isRequired
        label: React.PropTypes.string
        size: React.PropTypes.oneOf([
            'thumb', 'medium', 'original'
        ]).isRequired

    modelBindings:
        asset: 'props'

    listenNetworkEvents: true

    mixins: [
        Lanes.React.Mixins.ReadEditingState
    ]

    bindEvents: ->
        model: "change:#{@props.name} change:#{@props.name}_data"

    handleImageChange: (ev) ->
        ev.preventDefault()
        @asset.blob = ev.target.files[0]

    renderImage: ->
        <img className="preview" src={@asset.thumbnail_url} />

    blankImage: ->
        null

    Label: ->
        return null unless @props.label
        <label>{@props.label}</label>

    Edit: ->
        return null unless @isEditingRecord()
        <form>
            <label className="selector">
                <span>
                    {if @asset.isPresent then 'Change' else 'Add'}
                </span>
                <input id='file' className="file" type="file"
                    onChange={@handleImageChange} />
            </label>
        </form>

    render: ->
        Component = if @asset.hasImage then @renderImage else @blankImage
        className = _.classnames('image-asset', @props.className, {
            'with-image': @asset.hasImage
        })
        <BS.Col
            {...Lanes.u.bsSizes(@props)}
            className={className}
        >
            <@Label />
            <Component />
            <@Edit />
        </BS.Col>
