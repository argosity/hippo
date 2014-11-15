class BaseExtension

    setBootstrapData: (data)->

    @extended:(klass)->
        Lanes.Extensions.register(klass)


Lanes.Extension.Base = Lanes.lib.MakeBaseClass( Lanes.Vendor.Ampersand.State, BaseExtension )
