# # require lanes/components/grid
# # require lanes/access/User

# describe "Lanes.Components.Grid", ->

#     DATA = {total:1,success:true,message:"Retrieve succeeded",data:[
#         [1,"TEST","Nathan Stitt",null,"0.0"]
#     ]}
#     RESPONSE = {
#         status:200,
#         contentType: "application/json"
#         responseText: JSON.stringify(DATA)
#     }

#     beforeEach ->
#         jasmine.Ajax.install()
#     afterEach ->
#         jasmine.Ajax.uninstall()

#     it "loads", ->
#         query = new Lanes.Models.Query(
#             fields: [ 'code', 'name', 'notes' ]
#             modelClass: Lanes.Models.User
#         )
#         grid = new Lanes.Components.Grid(recordQuery:query)
#         expect( grid.render() ).toBe( grid )
#         request = jasmine.Ajax.requests.mostRecent()
#         expect(request.url).toMatch(/^\/users.json/)

#         request.respondWith(RESPONSE)
#         expect( grid.dt_api.rows().length ).toEqual(1)
