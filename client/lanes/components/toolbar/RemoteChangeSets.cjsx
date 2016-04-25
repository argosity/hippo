class Change extends Lanes.React.Component

    renderField: (field) ->
        unless _.isObject(field.from)
            from = <div className="from">{field.from}</div>
        unless _.isObject(field.to)
            to = <div className='to'>{field.to}</div>

        <div className='change' key={field.name}>
            <div className="field">{@model.record_name} {_.field2title field.name}:</div>
            {from}
            {to}
        </div>

    render: ->
        user =
            if @model.by?.email
                <a href={"mailto:#{@model.by.email}"}>{@model.by.name}</a>
            else if @model?.by.name
                @model.by.name
            else
                'Unknown User'

        user =
            <LC.Tooltip id='user-email' placement='left'
                content={Lanes.Vendor.Moment( @model.created_at ).fromNow()}
            >{user}</LC.Tooltip>

        <div className="update">
            {user}
            <div className="changes">
                {@renderField(change) for change in @model.displayed_changes }
            </div>
        </div>

class Lanes.Components.Toolbar.RemoteChangeSets extends Lanes.React.Component

    propTypes:
        model: Lanes.PropTypes.State

    render: ->
        return null unless @model?.changes
        title = <span>
            <i className="icon icon-cloud-download icon-lg" />
            <LC.CountBadge superScript count={@model.changes.length} />
        </span>
        <BS.Nav navbar pullRight className="changes-notification">
          <BS.DropdownButton id="record-changes" title={title}>
              <div className="scroller">
                  {@model.changes.map (ch) -> <Change key={ch.cid} model={ch} />}
              </div>
          </BS.DropdownButton>
        </BS.Nav>
