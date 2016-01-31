class Lanes.Screens.SystemSettings extends Lanes.React.Screen

    dataObjects:
        config: -> Lanes.config.system_settings

    getInitialState: ->
        isEditing: true
        commands: new Lanes.Screens.Commands(this, modelName: 'config')

    onChange: (path, ev) ->
        @config.settings.lanes[path] = if ev.target then ev.target.value else ev
        @forceUpdate()

    renderFileOptions: ->
        dir = @config.settings.lanes.storage_dir
        <LC.FieldWrapper label='Store Directory' sm=9 {...@props} value={dir}>
            <input type="text" className='value form-control'
                placeholder="Directory to store files" value={dir}
                onChange={_.partial(@onChange, 'storage_dir')} />
        </LC.FieldWrapper>

    renderFogOptions: ->
        value = JSON.stringify(@config.settings.lanes.fog_credentials, null, 2)
        <LC.FieldWrapper label='Fog Options' sm=9 {...@props} value={value}>
            <BS.Input type="textarea" placeholder="FOG options (as JSON)" value={value}
                onChange={_.partial(@onChange, 'fog_credentials')} />
        </LC.FieldWrapper>

    saveConfig: ->
        @config.save(saveAll: true)

    render: ->
        choices = ['file', 'fog']
        storage = @config.settings.lanes?.storage || 'file'

        <LC.ScreenWrapper identifier="user-preferences">
            <BS.Nav bsStyle="pills" className="lanes-toolbar">
                <BS.Button navItem componentClass="button"
                    onClick={@saveConfig} className="save navbar-btn control">
                    <LC.Icon type="cloud-upload" />Save
                </BS.Button>
            </BS.Nav>

            <BS.Row>
                <LC.FieldWrapper label='File Storage' sm=3 {...@props} value={storage}>
                    <Lanes.Vendor.ReactWidgets.DropdownList
                        data={choices} value={storage} onChange={_.partial(@onChange, 'storage')} />
                </LC.FieldWrapper>
                {if storage is 'file' then @renderFileOptions() else @renderFogOptions()}
            </BS.Row>
            <BS.Row>
                <LC.ImageSaver label='Logo' sm=4 model={@config} name='logo' />
            </BS.Row>
            {for id, Ext of Lanes.Extensions.instances when Ext.settingsElement
                <Ext.settingsElement settings={@config.settings[id]} key={id} /> }
        </LC.ScreenWrapper>
