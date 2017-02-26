import React from 'react';

export default class Layout extends React.Component {
    /* static modelBindings = {
     *     uistate() { return Lanes.Workspace.Extension.uistate; },
     *     viewport() { return this.context.viewport; },
     * };

     * static childContextTypes =
     *     { uistate: Lanes.PropTypes.State };
     * getChildContext() {
     *     return (
     *         { uistate: this.uistate }
     *     );
     * }

     * pageClasses() {
     *     return (
     *         _.classnames('page-container', this.uistate.screen_menu_size,
     *             { popover_menu: this.uistate.popover_menu },
     *         )
     *     );
     * }

     * componentWillMount() {
     *     return (
     *         this.uistate.set(this.props)
     *     );
     * }*/

    render() {
        return (
            <div className="layout">
                <h3>Layouted</h3>
            </div>
        );
    }
}


/* <LC.Modal {...this.context.viewport.modalProps} />
 * <Lanes.Workspace.Navbar history={this.state.history} />
 * <div className={this.pageClasses()}>
 * <Lanes.Workspace.ScreensMenu history={this.state.history} />
 * <Lanes.Workspace.ScreenView />
 * </div>*/
