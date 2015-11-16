class Lanes.Components.Calendar extends Lanes.React.Component

    statics:
        Events: Lanes.Vendor.Dayz.EventsCollection

    propTypes:
        display:           React.PropTypes.oneOf(['month', 'week', 'day']),
        date:              React.PropTypes.object.isRequired,
        dayComponent:      React.PropTypes.func,
        events:            React.PropTypes.instanceOf(Lanes.Vendor.Dayz.EventsCollection),
        dayLabelComponent: React.PropTypes.func,
        onDayClick:        React.PropTypes.func,
        onEventClick:      React.PropTypes.func

    render: ->
        <Lanes.Vendor.Dayz {...@props} />
