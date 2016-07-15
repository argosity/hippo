class Lanes.Components.ImageAsset extends Lanes.React.Component

    propTypes:
        model: Lanes.PropTypes.Model.isRequired
        name: React.PropTypes.string.isRequired
        size: React.PropTypes.oneOf([
            'thumb', 'medium', 'original'
        ]).isRequired

    modelBindings:
        asset: -> @props.model[@props.name]

    listenNetworkEvents: true

    bindEvents: ->
        model: "change:#{@props.name} change:#{@props.name}_data"

    handleImageChange: (ev) ->
        ev.preventDefault()
        @asset.blob = ev.target.files[0]

    renderImage: ->
        <img className="preview" src={@asset.thumbnail_url} />

    blankImage: ->
        null

    render: ->
        Component = if @asset.hasImage then @renderImage else @blankImage
        className = _.classnames('image-asset', @props.className, {
            'with-image': @asset.hasImage
        })

        <LC.FieldWrapper
            {...@props}
            className={className}
            displayComponent={Component}
        >
            <Component />
            <form>
                <label className="selector">
                    <span>{if @asset.hasImage then 'Update' else 'Choose'}</span>
                    <input id='file' className="file" type="file" onChange={@handleImageChange} />
                </label>
            </form>
        </LC.FieldWrapper>
