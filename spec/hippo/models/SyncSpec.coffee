describe "Hippo.Models.Sync", ->

    it "it can encode retreival options", (done) ->
        calledWithUrl = ""
        spyOn(Hippo.Vendor, 'xhr').and.callFake( (options, cb) ->
            calledWithUrl = options.url
            console.dir options
            cb(false, {}, "{}")
        )

        options =
            url: 'endpoint'
            query: { foo: 'bar' }
            fields: ['foo', 'bar']
            with:   'bar_finder_method'
            include: ['extra_special_values', 'secrets']
            order: {'foo', 'desc'}
            limit: 100
            start: 2
            format: 'array'

        Hippo.Models.Sync.restorePerform ->
            Hippo.Models.Sync.perform('GET', options).then (a,b,c)->
                expect(Hippo.Vendor.xhr).toHaveBeenCalled()
                expect(calledWithUrl)
                    .toEqual("endpoint.json?q[foo]=bar&f[]=foo&f[]=bar&w=bar_finder_method&i[]=extra_special_values&i[]=secrets&o[foo]=foo&o[desc]=desc&l=100&s=2&df=array")

                done()
