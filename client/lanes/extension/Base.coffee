class BaseExtension

    @afterExtended: (klass) ->
        Lanes.Extensions.register(klass)

    title: ->
        _.titleize @identifier


Lanes.Extensions.Base = Lanes.lib.MakeBaseClass(
    Lanes.Vendor.Ampersand.State, BaseExtension
)
