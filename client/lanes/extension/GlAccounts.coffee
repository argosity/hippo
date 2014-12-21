class GlAccounts

    identifier: 'gl_accounts'

    setBootstrapModels: (data)->
        Lanes.Models.GlAccount.sharedCollection().reset(data)


Lanes.Extension.Base.extend(GlAccounts)
