class Change extends Lanes.React.Component

    renderField: (field) ->
        <span key={field.name}>
            <p className="field">{@model.record_name} {_.field2title field.name}:</p>
            <span className="change">{field.from}<br />{field.to}</span>
        </span>

    render: ->
        if @model.by
            user = <LC.Tooltip placement='left' content={@model.by.email}>
                <span>{@model.by.name}</span>
            </LC.Tooltip>

        <div className="update">
            {user}
            <p className="ago">{Lanes.Vendor.Moment( @model.created_at ).fromNow()}</p>
            <p className="changes">
                {@renderField(change) for change in @model.displayed_changes }
            </p>
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
        <BS.Nav navbar right className="changes-notification">
          <BS.DropdownButton eventKey={3} title={title}>
              <div className="scroller">
                  {@model.changes.map (ch) -> <Change key={ch.cid} model={ch} />}
              </div>
          </BS.DropdownButton>
        </BS.Nav>

        # <ul className="nav navbar-nav navbar-right">
        #     <li className="dropdown">
        #         <a href="#" className="dropdown-toggle"
        #             data-toggle="dropdown" role="button"
        #             aria-haspopup="true" aria-expanded="false"
        #         >
        #             <i className="icon icon-cloud-download" /> Changes {@props.model.changes.length}
        #         </a>
        #         <ul className="dropdown-menu">
        #             <li><a href="#">Action</a></li>
        #             <li><a href="#">Another action</a></li>
        #             <li><a href="#">Something else here</a></li>
        #             <li role="separator" className="divider"></li>
        #             <li><a href="#">Separated link</a></li>
        #         </ul>
        #     </li>
        # </ul>


        # title = <span>
        #     <i className="icon icon-cloud-download" /> Changes {@props.model.changes.length}
        # </span>
        # <BS.SplitButton bsStyle="default" title={title}
        #     navItem
        #     componentClass="button"
        #     onClick={@props.onSave}
        #     className="changes navbar-btn"
        # >
        #     <BS.MenuItem eventKey='1'>Action</BS.MenuItem>
        #     <BS.MenuItem eventKey='2'>Another action</BS.MenuItem>
        #     <BS.MenuItem eventKey='3'>Something else here</BS.MenuItem>
        #     <BS.MenuItem divider />
        #     <BS.MenuItem eventKey='4'>Separated link</BS.MenuItem>
        # </BS.SplitButton>
