# Hippo web framework

Hippo is a web framework that aims to make writing single page apps as simple as traditional Rails apps.

[![Build Status](https://travis-ci.org/argosity/hippo.svg?branch=master)](https://travis-ci.org/argosity/hippo)

It's extracted from the Stockor ERP application and is still very much a work in progress.

Some of it's features are:

* **Integrated web server**: Sinatra is used internally with RESTful routes auto-created for each model. This frees the developer from the hassel of integrating disparate systems and allows Hippo to provide tools that are guaranteed to work together.

* **Rich JSON requests**: Clients can perform ad-hoc querys against server-side data and the the reply format can be extensively customized. Operators are provided for specifying which fields and associations are included in the result set, as well as ordering and pagination support. It's also easy to write custom query operators. ActiveRecord is used internally to eager-load associations in order to prevent N+1 queries.

* **Real-Time data updates**: Whenever a CRUD operation is performed on a model, the web-server will relay the event to client observers that have registered for updates. By default a model is registered for updates whenever it's bound to a view, which works to prevent unwanted updates and allows records to be garbage collected. Updates are performed by long-pulling via the message-bus gem. A client-side identity map is also used so that only one copy of the model for a given id exists and is updated.

* **Next-Gen web-framework**: Client is built in React using [mobex-decorated-models](https://github.com/nathanstitt/mobx-decorated-models).

* **Integrated continual testing environment**: When ran in development mode, Hippo watches for file changes and runs the appropriate spec for both your client and server code automatically. Minispec is utilized for the Ruby models, and client code tested via Jest.

* **Role-driven security**: Models can be marked as readable, writeable, or deletable for roles. Additionally, fields can be marked as read-only or invisible to prevent unauthorized access.

* **Extendible**:  Extensions can be registered with the framework and will be automatically compiled and included in builds. Components are loaded on-demand and are not included unless an extension requires them. Hippo also dynamically loads the Javascript and CSS for screens on-demand immediatly before they are displayed.

* **Embeddable and Responsive**: Designed from the ground up to be embeddable in hostile environments. All code is non-conflicting and wrapped in closures. Sass is auto-namespaced. Detect changes in it's container's size and relay them to clasess for responsive layouts. A modified Bootstrap based css layout can optionally be loaded which will provide a responsive grid that's bound to the container's size, not the documents.


## Contributing

The standard instructions are always good:

 1. Fork it ( http://github.com/argosity/hippo/fork )
 2. Create your feature branch (`git checkout -b my-new-feature`)
 3. Commit your changes (`git commit -am 'Add some feature'`)
 4. Push to the branch (`git push origin my-new-feature`)
 5. Create new Pull Request
