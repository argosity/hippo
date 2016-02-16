class BaseExtension

    @extended: (klass) ->
        Lanes.Extensions.register(klass)

Lanes.Extensions.Base = Lanes.lib.MakeBaseClass(
    Lanes.Vendor.Ampersand.State, BaseExtension
)
