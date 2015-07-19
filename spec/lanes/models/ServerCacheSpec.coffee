describe "Lanes.Models.ServerCache", ->

    it "caches models", (done) ->
        record = LT.makeModel({
            cacheDuration: [5, 'seconds']
            props: { id: 'integer', name: 'string' }
        }, { id: 123 })

        syncSucceedWith(name: 'bob')

        Lanes.Models.ServerCache.fetchRecord(record).then ->
            expect(Lanes.Models.Sync.perform).toHaveBeenCalledWith('read', jasmine.any(Object))
            expect(record.name).toEqual('bob')

            Lanes.Models.Sync.perform.calls.reset()
            record.clear()
            record.id = 123
            expect(record.name).toBeUndefined()
            Lanes.Models.ServerCache.fetchRecord(record).then ->
                expect(Lanes.Models.Sync.perform).not.toHaveBeenCalled()
                expect(record.name).toEqual('bob')
                done()


    it "caches collections", (done) ->
        record = LT.makeModel({
            cacheDuration: [5, 'seconds']
            props: { id: 'integer', name: 'string' }
        }, { id: 123 })

        collection = Lanes.Test.makeCollection
            cacheDuration: [5, 'milliseconds']
            model: LT.defineModel
                props: { id: 'integer', name: 'string' }

        syncSucceedWith([{id:1, name: 'bob'}, {id:2, name: 'joe'}])

        Lanes.Models.ServerCache.fetchCollection(collection).then ->
            expect(Lanes.Models.Sync.perform).toHaveBeenCalledWith('read', jasmine.any(Object))
            expect(collection.length).toEqual(2)
            Lanes.Models.Sync.perform.calls.reset()
            Lanes.Models.ServerCache.fetchCollection(collection).then ->
                expect(Lanes.Models.Sync.perform).not.toHaveBeenCalled()
                done()

    it "expires the cache", (done) ->
        record = LT.makeModel({
            cacheDuration: [5, 'milliseconds']
            props: { id: 'integer', name: 'string' }
        }, { id: 123 })

        syncSucceedWith(name: 'bob')

        Lanes.Models.ServerCache.fetchRecord(record).then ->
            expect(Lanes.Models.Sync.perform).toHaveBeenCalled()
            Lanes.Models.Sync.perform.calls.reset()

            Lanes.Models.ServerCache.fetchRecord(record).then ->
                expect(Lanes.Models.Sync.perform).not.toHaveBeenCalled()

                _.delay( ->
                    Lanes.Models.ServerCache.fetchRecord(record).then ->
                        expect(Lanes.Models.Sync.perform).toHaveBeenCalled()
                        done()
                , 10)
