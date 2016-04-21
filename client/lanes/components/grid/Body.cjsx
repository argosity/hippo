class Lanes.Components.Grid.Body extends Lanes.React.BaseComponent

    propTypes:
        query:      React.PropTypes.instanceOf(Lanes.Models.Query).isRequired
        cellStyles: React.PropTypes.object.isRequired

    fieldConvertors:
        bigdec: (v) -> _.bigDecimal(v).toFixed(2)

    onRowClick: (ev, row, index) ->
        ourBounds = _.dom(@).el.getBoundingClientRect()
        clickBounds = _.dom(ev.target).el.getBoundingClientRect()
        top = this.refs.list.getScroll() + (
            clickBounds.top - ourBounds.top
        )
        left = ev.clientX - ourBounds.left
        selectedIndex = (if @props.selectedIndex == index then null else index)
        selectedModel = if selectedIndex?
            @props.query.results.modelAt(selectedIndex, clone: true)
        else null
        @props.onRowClick(selectedModel, selectedIndex,
            {top, left, container: ourBounds, rowHeight: clickBounds.height}
        )

    getDefaultEditingPosition: ->
        el = _.dom(@).el
        container = el.getBoundingClientRect()
        {
            container, top: 0, left: container.width * 0.4
            rowHeight: el.querySelector('.r')?.clientHeight || 50
        }

    convertValue: (value, field) ->
        if @fieldConvertors[field.type] then @fieldConvertors[field.type](value) else value

    renderColumn: (rowNum, index, field, results, row) ->
        value = results.valueForField(rowNum, field)

        onColClick = if field.onColumnClick
            _.partial(field.onColumnClick, _,
                {value, field, index, rowNum, row, query: @props.query }
            )
        else
            null

        value = if field.format
            field.format(value, row, @props.query)
        else
            @convertValue(value, field)

        value = React.createElement( field.component,
            {value: value, query: @props.query, row}
        ) if field.component

        <div key={field.id}
            onClick={onColClick}
            {...@props.cellStyles.props[index]}
        >
            {value}
        </div>

    renderRow: (rowNum, ref) ->
        fields = []
        results = @props.query.results
        row = results.rowRepresentation(rowNum)
        for field, index in @props.query.fields.models when field.visible
            fields.push @renderColumn(rowNum, index, field, results, row)

        if @props.onRowClick
            onClick = _.partial(@onRowClick, _, row, rowNum)
        <div key={rowNum} ref={ref} className="r" onClick={onClick} >
            {fields}
        </div>

    render: ->
        <div className={_.classnames('grid-body', 'is-editing': @props.editing)}>

            <LC.NetworkActivityOverlay model={@props.query} />

            <Lanes.Components.Grid.Editor
                {...@props}
                cellStyles={@props.cellStyles}
                onSave={@props.onEditSave}
                onCancel={@props.onEditCancel}
                editing={@props.editing} />

            <Lanes.Vendor.List
                useTranslate3d
                isEditing={!!@props.editing}
                itemRenderer={@renderRow}
                length={@props.query.results.length}
                forceUpdateProp={@props.query.changeCount}
                type='variable'
                ref="list"
            />
        </div>
