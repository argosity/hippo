import React from 'react';

export default class Calendar extends React.Component {
    static statics =
        {Events: Lanes.Vendor.Dayz.EventsCollection};

    static propTypes = {
        display:           React.PropTypes.oneOf(['month', 'week', 'day']),
        date:              React.PropTypes.object.isRequired,
        dayComponent:      React.PropTypes.func,
        events:            React.PropTypes.instanceOf(Lanes.Vendor.Dayz.EventsCollection),
        dayLabelComponent: React.PropTypes.func,
        onDayClick:        React.PropTypes.func,
        onEventClick:      React.PropTypes.func
    };
    render() {
        return (
            <Lanes.Vendor.Dayz {...this.props}>
                {this.props.children}
            </Lanes.Vendor.Dayz>
        );
    }
}
