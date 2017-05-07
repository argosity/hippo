# All components in <%= namespace.camelize %> will default to
# being extended by this helper.  It calls
# Hippo default helper, which will in turn call React.createClass
<%= namespace %>.Components.Base = {

    extend: (klass) ->
        # Call Hippo default, which will eventually call React.createClass
        Hippo.React.Component.extend(klass)
}
