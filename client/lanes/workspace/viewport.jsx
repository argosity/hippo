import React from 'react';

/* const Screen = React.createClass({
 *
 *     displayName: 'Screen',
 *     shouldComponentUpdate() {
 *         return (
 *             false
 *         );
 *     },
 *     render() {
 *         return (
 *             React.createElement(this.props.screen.component(), this.props.screen.props)
 *         );
 *     },
 * });*/

export default class ScreenView extends React.Component {
    /* contextTypes: {
     *     uistate: React.PropTypes.object.isRequired,
     * },*/

    /* static modelBindings: {
     *     displaying() { return Lanes.Screens.Definitions.displaying; },
     *     allScreens() { return Lanes.Screens.Definitions.all; },
     * },

     * bindEvents: {
     *     displaying: 'add remove reset change:active',
     *     allScreens: 'change:loading',
     * },
     */
    renderScreen(screen) {
        return (
            <div
                key={screen.id}
                className={_.classnames('screen', { active: screen.active })}
            >
                <Screen screen={screen} />
            </div>
        );
    }

    renderLoading() {
        const screen = Lanes.Screens.Definitions.all.findWhere({ loading: true });
        return (
            <LC.NetworkActivityOverlay visible message={`Loading ${screen.title}…`} />
        );
    }

    BaseView() {
        const Base = __guardMethod__(Lanes.Extensions.controlling(), 'initialScreen', o => o.initialScreen()) || Lanes.Workspace.FirstRun;
        return (
            <div className="screen active base">
                <Base />
            </div>
        );
    }

    render() {
        const child = this.displaying.isEmpty() ? React.createElement(this.BaseView, null) : this.displaying.map(this.renderScreen);
        return (
            <div className={`page-content ${this.context.uistate.layout_size}`}>
                {this.allScreens.isLoading() ? this.renderLoading() : undefined}
                {child}
            </div>
        );
    }
}

/*
 * function __guardMethod__(obj, methodName, transform) {
 *     if (typeof obj !== 'undefined' && obj !== null && typeof obj[methodName] === 'function') {
 *         return (
 *         transform(obj, methodName)
 *         );
 *     } else {
 *         return (
 *         undefined
 *         );
 *     }
 * }*/
