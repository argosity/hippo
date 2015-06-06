# All components in AppyApp will default to
# being extended by this helper.  It calls
# Lanes default helper, which will in turn call React.createClass
AppyApp.Components.Base = {

    extend: (klass) ->
        # Call Lanes default, which will eventually call React.createClass
        Lanes.React.Component.extend(klass)
}
