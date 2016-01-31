class <%= screen_class %> extends <%= namespace %>.Screens.Base

    render: ->
        <LC.ScreenWrapper identifier="<%= identifier %>">
            <div className="fancy-header">
                <h1>Hello bright shiny world</h1>
                <h2>Served by the <%=namespace%> extension&rsquo;s <%= class_name %> screen</h2>
            </div>
        </LC.ScreenWrapper>
