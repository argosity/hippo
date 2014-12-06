class GlAccounts

    identifier: 'gl_accounts'

    setBootstrapData: (data)->
        Lanes.Data.GlAccount.sharedCollection().reset(data)


Lanes.Extension.Base.extend(GlAccounts)
