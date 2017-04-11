import React from 'react';

import PropTypes from 'prop-types';

export default class Calendar extends React.Component {
    static statics =
        {Events: Lanes.Vendor.Dayz.EventsCollection};

    static propTypes = {
        display:           PropTypes.oneOf(['month', 'week', 'day']),
        date:              PropTypes.object.isRequired,
        dayComponent:      PropTypes.func,
        events:            PropTypes.instanceOf(Lanes.Vendor.Dayz.EventsCollection),
        dayLabelComponent: PropTypes.func,
        onDayClick:        PropTypes.func,
        onEventClick:      PropTypes.func
    };
    render() {
        return (
            <Lanes.Vendor.Dayz {...this.props}>
                {this.props.children}
            </Lanes.Vendor.Dayz>
        );
    }
}
