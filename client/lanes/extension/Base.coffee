class BaseExtension

    @afterExtended: (klass) ->
        Lanes.Extensions.register(klass)

    title: ->
        _.titleize @identifier

    setBootstrapData: (data) ->
        @data = data

Lanes.Extensions.Base = Lanes.lib.MakeBaseClass(
    Lanes.Vendor.Ampersand.State, BaseExtension
)
