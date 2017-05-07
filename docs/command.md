---
# Front matter comment to ensure Jekyll properly reads file.
# Do not remove
title: hippo command
heading: The "hippo" command
position_after: model
---

Hippo framework installs a command line application which can be used to create and modify applicatons.

The command "hippo" utilizes subcommands that direct it's activities.

# hippo help

Built-in help can be accessed by either running `hippo help` or command specific help by prefixing the final part of the command with 'help'.  For instance `hippo generate help model` will display comphrensive help for the 'hippo generate model' subcommand.

# hippo new

Executing `hippo new <app name>` will create a skeleton application that contains all the components needed to develop and deploy a single page application.

It generates the following directory structure:

<pre class="ascii-tree">
├── Gemfile
├── Guardfile
├── Rakefile
├── config.ru
├── tmp
├── client
│   └── todo
│       ├── Extension.coffee
│       ├── components, data, views, styles, (empty directories)
│       ├── index.js
│       ├── screens
│       │   └── base
│       │       ├── Base.coffee
│       │       ├── index.js
│       │       ├── index.scss
│       │       └── layout.html
│       └── styles.scss
├── config
│   ├── database.yml
│   ├── hippo.rb
│   └── routes.rb
├── spec
│   └── todo
└── lib
    ├── todo
    │   ├── extension.rb
    │   └── version.rb
    └── todo.rb
</pre>


Notable directories created are:

 * *lib/<app_name>*  This directory will hold all server-side Ruby files that are needed by your application such as ActiveRecord models.
 * *config* Contains the routes and a config file for modifying Lane's behaviour.
 * *client/<app_name>*  Contains all the client code that makes up your application.  It has directories for views, data (models and collections), and screens.  A "Base" screen is created to start you off with.  You can use that screen as a base class for further screens if your application will be complex, or simply use it for your application if there will only be a single screen.  That's how the TODO MVC Example app is written.

# hippo generate

Constructs either a model, component or screen.

## Component

`hippo generate component <name>`

Will create a new component file along with an accompanying spec.  By default the content will only render a simple [I am a {class_name} component] message.


## Model

`hippo generate model <name> [field definitions]`

Creates a new model server and client side, a migration, fixtures file and accompanying specs.  It may be accompanied by a list of field names, which if given will be set on the appropriate files.

The field specifications are given as `field:type` and seperated by spaces.

For instance, `hippo generate model comment user:references title:string{80} content:text`, when executed inside of a project called "Blog":

  * Will create a Ruby ActiveRecord model called `Blog::Comment` and an accompanying migration to add a user_id, a title and content fields.
  * Setup a client model Blog.Data.Comment and a collection Blog.Data.BlogCollection
  * Spec files will be created to test both the ActiveRecord model and the client Model and Collection.

## Screen

`hippo generate screen <name>`

In the Hippo lexicon, a screen is a Component that is able to be loaded on demand.  By default, the styles and Javascript code that make up a screen are not loaded as part of the applications main bundles.  Instead the screen is loaded on demand when the user clicks on a menu.

Remote data events for all sub components bubble up to the screen.  This allows the screen to display a notification to the user alerting them that another user edited data that is being currently displayed somewhere on the view.

# hippo update

## Model

`hippo update model <name>`

When developing a data driven application, the data model usually undergoes several revisions.  The update command reads the schema from the database and updates the client model with the updated field names, types, null conditions.  It also reads the assocations from the ActiveRecord model and applies them to the model as well.

# hippo db

## Migrate

`hippo db migrate`

Calls rake db:migrate for each extension that is loaded.  Since hippo extensions ship with migrations, this provides an easy way to install their data structures as well as keep them up to date.

## Seed

`hippo db seed`

Calls rake db:seed for each extension that is loaded.  Often an extension will need to ship with certain default records.  This provides a way to provision them on install.  Commands can be placed in db/seeds.rb to be executed.
