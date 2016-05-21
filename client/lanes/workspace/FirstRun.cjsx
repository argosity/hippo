class Lanes.Workspace.FirstRun extends Lanes.React.Screen

    openSS: ->
        Lanes.Screens.Definitions.all.get('system-settings').display()

    openUP: ->
        Lanes.Screens.Definitions.all.get('user-preferences').display()

    openUser: ->
        Lanes.Screens.Definitions.all.get('user-management').display()

    render: ->
        title = Lanes.Extensions.controlling().title()

        <LC.ScreenWrapper identifier="first-run">

            <BS.Row>
                <BS.Col xs=10 xsOffset=1>
                    <BS.PageHeader>
                        Welcome to {title}
                    </BS.PageHeader>
                </BS.Col>
            </BS.Row>
            <BS.Row>
                <BS.Col xs=8 xsOffset=1>
                    <p className="lead">
                        A few tips & tricks:
                    </p>
                </BS.Col>
            </BS.Row>
            <BS.Row>
                <BS.Col xs=8 xsOffset=2>
                    <ul>
                        <li>
                            {title} is composed of individual screens.  Each screen can be opened from the menu at the left.
                            When opened, each screen opens into a new tab in this window.
                        </li>
                        <li>
                            Many screens are dual-purpose and support both edit and display modes.
                            They can be switched between the modes by clicking
                            the <Lanes.Vendor.ReactToggle defaultChecked={true} /> control
                            at the top right of the screen.
                        </li>
                        <li>
                            You can setup the system by
                            selecting <LC.Icon type="cogs" /> <a onClick={@openSS}>System Settings</a>
                            from the menu option with
                            the <LC.Icon type="wrench" lg /> icon.
                        </li>
                        <li>
                            There’s also <LC.Icon type="user-secret" /> <a onClick={@openUP}>User Preferences</a> where
                            you can set which screens are displayed when {title} loads.
                        </li>
                        <li>
                            User accounts can be setup from
                            the <LC.Icon type='group' /> <a onClick={@openUser}>User Management</a> screen.
                        </li>
                    </ul>
                </BS.Col>
            </BS.Row>
            <BS.Row className="help">
                <BS.Col xs=7 xsOffset=4>
                    <p>Have a suggestion on improving {title}?</p>
                    <p><a href="https://argosity.com/" target="_blank">Argosity</a> would
                    love to hear it and help you.</p>
                </BS.Col>
            </BS.Row>

        </LC.ScreenWrapper>
