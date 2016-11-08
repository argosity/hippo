class Lanes.Screens.SystemSettings extends Lanes.React.Screen

    modelBindings:
        config: -> Lanes.config.system_settings

    getInitialState: ->
        isEditing: true
        commands: new Lanes.Screens.Commands(this, modelName: 'config')

    onChange: (path, ev) ->
        @config.settings.lanes[path] = if ev.target then ev.target.value else ev
        @forceUpdate()

    renderFileOptions: ->
        dir = @config.settings.lanes.storage_dir
        <LC.FieldWrapper
            model={@config} displayComponent={<span />}
            label='Store Directory' sm=9 value={dir}>
            <input type="text" className='value form-control'
                placeholder="Directory to store files" value={dir}
                onChange={_.partial(@onChange, 'storage_dir')} />
        </LC.FieldWrapper>

    fogValue: ->
        @state.fogValue or
            JSON.stringify(@config.settings.lanes.fog_credentials, null, 2)
    setFog: (ev) ->
        @setState(fogValue: ev.target.value)

    renderFogOptions: ->
        <LC.TextArea sm=9 name='fog' placeholder="FOG options (as JSON)" model={@config}
            getValue={@fogValue} onChange={@setFog} />

    saveConfig: ->
        comp.onBeforeSave?() for id, comp of @refs
        if @state.fogValue
            try
                @config.settings.lanes.fog_credentials = JSON.parse(@state.fogValue)
        @config.save(saveAll: true)
        comp.onSave?() for id, comp of @refs

    render: ->
        choices = ['file', 'fog']
        storage = @config.settings.lanes?.storage || 'file'

        <LC.ScreenWrapper identifier="system-settings">
            <BS.Nav bsStyle="pills" className="lanes-toolbar">
                <BS.NavItem>
                    <BS.Button componentClass="button"
                        onClick={@saveConfig}
                        className="save control"
                    >
                        <LC.Icon type="cloud-upload" />Save
                    </BS.Button>
                </BS.NavItem>
            </BS.Nav>
            <BS.Row>
                <LC.ImageAsset sm=4 asset={@config.logo}
                    label='Logo' size='thumb' />
                <LC.ImageAsset sm=4 asset={@config.print_logo}
                    label='Print Logo' size='thumb' />
            </BS.Row>
            {for id, Ext of Lanes.Extensions.instances when Ext.getSettingsElement
                Ext.getSettingsElement(ref: id, key: id, settings: @config.settings[id] || {})}
        </LC.ScreenWrapper>
