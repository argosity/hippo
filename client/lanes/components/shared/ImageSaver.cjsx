class Lanes.Components.ImageSaver extends Lanes.React.Component

    propTypes:
        model: Lanes.PropTypes.Model
        name: React.PropTypes.string.isRequired
        size: React.PropTypes.oneOf([
            'thumb', 'medium', 'original'
        ]).isRequired

    listenNetworkEvents: true
    bindDataEvents: ->
        model: "change:#{@props.name} change:#{@props.name}_data"

    uploadImage: ->
        imageFormData = new FormData()
        imageFormData.append('imageFile', imageFile)

    handleImageChange: (ev) ->
        ev.preventDefault()
        @model.set("#{@props.name}_file", ev.target.files[0])

    renderImage: ->
        <img className="preview" src={@model.imageUrlFor(@props.name, @props.size)} />

    blankImage: ->
        null

    render: ->
        hasImage  = @model.hasImage(@props.name)
        Component = if hasImage then @renderImage else @blankImage
        className = _.classnames(@props.className, 'image-saver', {
            'with-image': hasImage
        })

        <LC.FieldWrapper
            {...@props}
            className={className}
            displayComponent={Component}
        >
            <Component />
            <form>
                <label className="selector">
                    <span>{if hasImage then 'Update' else 'Choose'}</span>
                    <input id='file' className="file" type="file" onChange={@handleImageChange} />
                </label>
            </form>
        </LC.FieldWrapper>
