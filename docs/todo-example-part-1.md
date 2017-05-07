---
title: TODO MVC Example
position_after: command
---

As is required by all new frameworks, this is an example of creating a TODO application using the Hippo framework.

First install Hippo via Rubygems.  `gem install hippo`

As always when using Hippo, the first thing you'll need to do is generate your application.  We will name this app simply as `todo`

{% highlight bash %}
hippo new todo
{% endhighlight %}

This will create a new directory with a skeleton Hippo application.  Read more about the directories and what their purposes are at {% doc_link command heading:'hippo new' %}.

[Our example app at this point](https://github.com/argosity/hippo-todo-demo/tree/c5ee64a5e932055470bf2d13d417f118b89114d6)

# Setup

A sample database configuration file is located in `config/database.yml` which will use a postgresql database named todo_dev.  For the purposes of this example, we'll just create a new postgresql database that matches the configuration: `createdb todo_dev`

Fire up the hippo testing server: `hippo serve`.  The test server will start the app and you can view it at: `http://localhost:8888/`.   You should see a simple "Todo" message.  You can also view the Jasmine specs at `http://localhost:8888/spec`

Next we'll create a data model `hippo generate model task title:string{80} completed:boolean` [commit](https://github.com/argosity/hippo-todo-demo/commit/e22d058d49c482f9be0167068adab1e37be868bc)

Since a task should default to being non-completed, we'll edit the migration to default that field to `false` and add a validation to the model [commit](https://github.com/argosity/hippo-todo-demo/commit/4fda061c13d399062850173eff7bb616563a82bf)

Hippo uses the concept of **Screens** to dynamically load a React component and all it's dependencies.  In this case, the Todo app will have only one screen which we can create by running: `hippo generate screen main` [commit](https://github.com/argosity/hippo-todo-demo/commit/f8614fd7d2e29987639ed7c6141e35c5e51e035f)

Looking at the Todo app, it has four distinct areas. A `sidebar`, `header`, `footer` and `listing` components. We can create views for them by executing `hippo generate component <name>`, where '< name >' is the view to create. [commit](https://github.com/argosity/hippo-todo-demo/commit/cdd63af42efada9d3c9a05658337e44141a0500a)

We'll copy the styles from the [TodoMVC template](https://github.com/tastejs/todomvc/tree/master/template).

First we take the TodoMVC html template and break it apart into sections and copy them to each view.  We're then able to plug each component's into the Screen. [commit](https://github.com/argosity/hippo-todo-demo/commit/cb2651fc3c7bfc0d2f093023056241b93c9b0597)

Run migration: `hippo db migrate`

We'll also create a TaskSummary model that is in charge of summarizing the state of the tasks.  It will listen to the tasks collection and perform calculations when events occur. [commit](https://github.com/argosity/hippo-todo-demo/commit/61a9cb6a6101816becf7f0aa556dd6506f9ffed4)

# Data and events

## Header
It's responsible for interaction with the "What needs to be done?" input.  When text is present and the "enter" key is pressed, it should save a record and add it to the collection.  We're able to do so in [just a few lines of code](https://github.com/argosity/hippo-todo-demo/commit/bbdf8c8a95ddea8285615d4a7898d9054b22c4b4)

## Listing
This component is a bit more complex.  It's split into two components, a parent which handles toggling all todo's between being complete and pending, and a collection of task components that model each individual task. [Listing](https://github.com/argosity/hippo-todo-demo/blob/master/client/todo/components/Listing.cjsx)

Each Task component is responsible for handling it's own editing state and saving value to it's model. [TaskComponent](https://github.com/argosity/hippo-todo-demo/blob/master/client/todo/components/Task.cjsx)

## Footer
The only action this component takes is to delete any tasks that are marked as complete when the "Clear Completed" button is clicked.  It also displays quite a few values from our TasksSummary.  Lane's data-bindings make these easy to wire up. [Footer](https://github.com/argosity/hippo-todo-demo/blob/master/client/todo/components/Footer.cjsx)

You might notice that Hippo makes it super easy to batch update or delete a collection.  The footer simply calls destroyAll on the "completed" sub-collection provided by the TaskSummary.  Since that sub-collection filters the main collection to only contain "completed" tasks, it's safe to just destroy all the model's in one go.

# Routing

For a simple app like the this one, it's easiest to just allow the URL change to trigger what the filtered collection is displaying. [Routing](https://github.com/argosity/hippo-todo-demo/blob/master/client/todo/Routes.cjsx)

# Deploying

For the example we'll host it on Heroku.  Other deployments should be similar to deploying a Rails application.

Simply commit the source and add a remote per Heroku's instructions: [https://devcenter.heroku.com/articles/git](https://devcenter.heroku.com/articles/git)

When you `git push heroku`, Heroku will notice that Hippo uses sprockets and will automatically run `rake assets:precompile`, and then run the application using the puma webserver.

On first deploy and when your db schema has changed, you will have to provision and migrate the database on Heroku by running: `heroku run rake db:migrate`
