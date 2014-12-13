---
title: Model
heading: Lanes.Data.Model
position_after: view
---

Lanes provides a Lanes.Data.Model class that all other models extend from.

A Model is an extension of [Ampersand State](http://ampersandjs.com/docs#ampersand-state), and supports all the features that AmpersandState does.

<aside class="note">
Unlike the Models in Backbonejs, Lanes' Models track thier "dirty" state.  This allows them to perform true HTTP "patch" requests and only send the attributes that have been modified to the server.  They can also be interogated and only saved if they contain unsaved data.
</aside>

Models also have associations, which are lazily instanciated and can be optionally fetched along with the model/collection.

Models and collections use an Identity Map that stores models that are bound to {% doc_link view title:Views %%}

Model methods that make requests to the server can specify options to control what data is returned.  An explanation of the options can be found under [Request Options](#request-options)



### API Reference

# initialize

`new Model({options})`

Called by the constructor after the models initialized.  Initialize can be used by to perform additional initialization of the class.

If a collection reference is provided to initalize, it will be copied onto the model.

# Model.fetch(id,options)

Fetches and instantiates a record.  Is useful for when you all you know is the record's ID.  The identity map is consulted, and if the record is present there the existing copy is returned.

``` coffee
class Balance extends Lanes.Data.Model
    props:
        id: 'integer'
        amount: 'bigdec'

balance = new Balance(id: 10, amount:42.11)
view = new MyApp.Views.Checkbook( model: balance )

Balance.fetch(10) # retrieves balance from idmap
Balance.fetch(11) # fetches balance with id 11 from server
```

# fetch(options)

Retrieves the current state of the model from the server.  Options can be any of the valid
[load options](#request-options)

# save(options)

Saves record state to server.  If options.saveAll is true, then the entire data set will be sent to the server, otherwise only modified fields are saved and a `PATCH` is performed.

Save also saves it's associations along with itself.

``` coffee
class Car extends Lanes.Data.Model
    associations:
        driver: { model: Person }
    props:
        id: 'integer'
        color: 'string'

driver = new Driver(name: 'Jane')
car = new Car(color: 'red', driver: driver )
car.color = 'Blue'
car.save() # will send { color: 'Blue', driver:{ name: 'Jane' } }
```

# destroy()

Deletes the record from the server

# set()

Sets field and values.  Marks the fields as unsaved and the record as "dirty".  Can be invoked as either `set(field,value)` or `set({ field:value, field2:value2 })`

# unsavedData()

returns the field and values that have been modified and the unsavedData from associations as well.

``` coffee
class Car extends Lanes.Data.Model
    associations:
        driver: { model: Person }
    props:
        id: 'integer'
        color: 'string'

driver = new Driver(name: 'Jane')
car = new Car()
car.set(color: 'red', driver: driver)
car.unsavedData() #  { color: 'Blue', driver:{ name: 'Jane' } }
```

# isDirty

True if there are unsaved fields, false otherwise.  **Note**: this does not check
associations, only fields that belong to the record itself.

# hasAttribute(attr)

Checks if the given field is defined on the Model.

# errorMsg(field,value)

Returns a string with an appropriate error message for setting the field to value.

If the change is considered valid, an empty string is returned.

The default implementation only checks the 'required' status of the field.  Models inheriting from `Lanes.Data.Model` may provide an alternative implementation.

# withAssociations(list...)

Loads any assocations in list if they are not already present.


# Request Options

The following options can be used with any method that make requests to the server.

 * **with** use an exported query scope to limit records returned.
 * **query** an array of objects to query the record with
 * **include** an array of exported associations that should be included with the results.
 * **fields** an array of fields (usually methods) to include in the result set.
 * **order** an object containing fields and ASC/DESC strings.
 * **limit** number of records to return
 * **offset** to start query at row
 * **format** If set to "array", the results will be returned as an array, otherwise stand JSON objects are returned.


Given a server-side model such as:

``` ruby
class Invoice < Lanes::Model
   belongs_to   :customer, export: true
   has_many     :lines,    export: true
   export_scope :payment_reference, lambda{ | value |
       joins(:payments).where( payments: { amount: value } )
   }
   def trust_factor
       return invoke_magic_formula
   end
   export_methods :trust_factor
end
```

It can be queried by the client:

``` coffee
class Invoice extends Lanes.Data.Model
    props:
        id: 'integer'
        total: 'bigdec'
    session:
        trust_factor: 'string'
    associations:
        customer: { model: Customer }
        lines:    { collection: InvoiceLines }

# Fetch the Invoice with id 1 and it's associated customer and lines.
# The results from calling the "trust_factor" method will also be included
Invoice.fetch({
   include: ['customer','lines'],
   fields: ['trust_factor']
})

# Fetch using the "payment_reference" scope on the model
Invoice.where( with: { payment_reference: 'ABRACADABRA' } )

# Fetch using an fairly complex adhoc query to find
# all invoices by a customer who's name starts with "Bob"
Invoice.where( query: { customer: { name: { value: 'Bob%', op: 'like' } )

# A simple query to find records who's "tag" field is set to "GOOD"
# 100 records will be returned, sorted by "name" and
# will start at the 101st record
Invoice.where(
  query: {tag: 'GOOD'},
  order: { name: 'DESC' },
  limit: 100, start: 100
)
```
