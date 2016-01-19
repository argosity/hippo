class Lanes.Components.ImageSaver extends Lanes.React.Component

    propTypes:
        model: Lanes.PropTypes.Model
        name: React.PropTypes.string.isRequired

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
        <img className="preview" src={@model.imageUrlFor('logo', 'thumb')} />

    render: ->
        value = if @model.hasImage(@props.name) then @renderImage() else null
        className = _.classnames(@props.className, 'image-saver')
        <LC.FieldWrapper {...@props} className={className} value={value}>
            {value}
            <form>
                <label className="selector">
                    {if value then 'Update' else 'Choose'}
                    <input id='file' className="file" type="file" onChange={@handleImageChange} />
                </label>
            </form>
        </LC.FieldWrapper>
