---
# Front matter comment to ensure Jekyll properly reads file.
# Do not remove
title: lanes command
heading: The "lanes" command
position_after: model
---

Lanes framework installs a command line application which can be used to create and modify applicatons.

The command "lanes" utilizes subcommands that direct it's activities.

# lanes help

Built-in help can be accessed by either running `lanes help` or command specific help by prefixing the final part of the command with 'help'.  For instance `lanes generate help model` will display comphrensive help for the 'lanes generate model' subcommand.

# lanes new

Executing `lanes new <app name>` will create a skeleton application that contains all the components needed to develop and deploy a single page application.

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
│   ├── lanes.rb
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

# lanes generate

Constructs either a model, view or screen.

## View

`lanes generate view <name>`

Will create a new view file, template and an accompanying spec.  By default the view will have no content, and it's template is composed of a single DIV.


## Model

`lanes generate model <name> [field definitions]`

Creates a new model server and client side, a migration, fixtures file and accompanying specs.  It may be accompanied by a list of field names, which if given will be set on the appropriate files.

The field specifications are given as `field:type` and seperated by spaces.

For instance, `lanes generate model comment user:references title:string{80} content:text`, when executed inside of a project called "Blog":

  * Will create a Ruby ActiveRecord model called `Blog::Comment` and an accompanying migration to add a user_id, a title and content fields.
  * Setup a client model Blog.Data.Comment and a collection Blog.Data.BlogCollection
  * Spec files will be created to test both the ActiveRecord model and the client Model and Collection.

## Screen

`lanes generate screen <name>`

In the Lanes lexicon, a screen is a View that has a few extra properties, "title" and "specification".  It is capable of being dynamically loaded and also consolidates pubsub events for all it's client views.

The specification contains attributes that are checked to see if the logged in user can access the screen or not.  If they are not allowed access, then the screen will not be listed as available and they will not be able to load it or it's data.

Remote data events for all subviews are applied by the view, and then bubble up to the screen.  This allows the screen to display a notification to the user alerting them that another user edited the data that is being currently displayed.

# lanes update

## Model

`lanes update model <name>`

When developing a data driven application, the data model usually undergoes several revisions.  The update command reads the schema from the database and updates the client model with the updated field names, types, null conditions.  It also reads the assocations from the ActiveRecord model and applies them to the model as well.

# lanes db

## Migrate

`lanes db migrate`

Calls rake db:migrate for each extension that is loaded.  Since lanes extensions ship with migrations, this provides an easy way to install their data structures as well as keep them up to date.

