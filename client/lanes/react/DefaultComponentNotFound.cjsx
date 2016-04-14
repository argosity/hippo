class Lanes.React.Root.DefaultComponentNotFound extends Lanes.React.Component
    propTypes:
        extension: React.PropTypes.object

    render: ->
        identifier = @props.extension?.identifier || "UnknownExtension"
        <div className="fancy-header">
            <h1>{_.classify(identifier)}.rootElement() did not return an element to render!</h1>
        </div>
