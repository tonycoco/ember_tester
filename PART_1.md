# Rails + Ember.js - Part 1

*Updated: 7/10/2013*

Check out the [original post](http://www.devmynd.com/blog/2013-3-rails-ember-js), [markdown](https://github.com/tonycoco/ember_tester/blob/master/PART_1.md) or [tag](https://github.com/tonycoco/ember_tester/tree/part_1) all saved on GitHub in a [repository](https://github.com/tonycoco/ember_tester).

## Introduction

I usually sling Ruby, but lately I've been dreaming of the client-side. I've been dreaming because I watched [Tom Dale and Yehuda Katz](http://www.tilde.io) blast their mind-bullets through my skull and show me a new(ly 1.0ish) JavaScript framework called, [Ember.js](http://emberjs.com). (See: [Part 1](http://www.youtube.com/watch?v=_6yMxU-_ARs), [Part 2](http://www.youtube.com/watch?v=TTy1pbXdKJg), [Part 3](http://www.youtube.com/watch?v=4Ed_o3_59ME), and [Part 4](http://www.youtube.com/watch?v=aBvOXnTG5Ag))

I've never been a big fan of magic, but it is pretty baller when you see it up close. Like the first time you see someone levitate, then realize, "I'm just standing in the right spot for this tool to fool me." (See: [This cool kid.](http://www.youtube.com/watch?v=U8JomWZiOpQ))

The magic of Ember.js is _strong_. It leans on the lessons of its predecessors. It is basically Backbone.js at its core. So, if you want to ninja it all up, go for it. I'm not getting any younger, so letting someone else do the lifting once in a while is not a bad thing (for me).

Plus, JavaScript, in general, is the new hotness. Actually, it's more like the coolest old dude in the room that everyone knows and now he has a new story that everyone wants to hear. It's a language without a lot of strong opinions ([most of the time](https://github.com/twitter/bootstrap/issues/3057)). It has a crazy install base. Nearly every computer since like 1997 has a JavaScript engine running somewhere on it. JavaScript also requires almost nothing else to dig in. Want to write a JavaScript program? Okay, go ahead. Start writing.

There's no compiler, no convoluted instructions on how to install some stuff to get it running, and no real barriers to entry (other than the fact that you need to learn the syntax itself). Need classes? Okay, create them. _Do it yourself, you lazy bums_.

_NOTE: Please don't check my facts. 1997 was just a guess, okay? Thanks._

Annnnnnnd, scene. No more ranting. I promise.

*Update: I'm using CoffeeScript now. Because I said so. Plus, it's "just JavaScript".*

## The Guides

Now, the nomenclature is a bit different from Rails in Ember.js, but it makes sense if you've ever done any desktop application development. Models, Views, and Controllers are based on the desktop way of thinking. Not the server-side architecure version that Rails peeps are used to. Read up on what each part of Ember.js does [here](http://emberjs.com/guides). The Ember.js guides are a great starting point for anyone trying to wrap their brain around what Ember.js is actually doing behind the scenes.

## Ember Extension

This tool promises to make debugging Ember.js applications much easier. Debugging is often painful because most of Ember.js lives in memory and not in files. The Ember Extension is a Chrome Extension that works with the Web Inspector Tools.

The Tilde Team seems to still be working out its kinks. But, here are some resources I've found useful so far...

* [Trying the Ember Inspector Out](http://www.kaspertidemann.com/how-to-try-out-the-ember-inspector-in-google-chrome)
* [Yehuda's Demo](https://www.youtube.com/watch?v=18OSYuhk0Yo&hd=1)
* [GitHub](https://github.com/tildeio/ember-extension)

## Installing Ember.js with Rails

Okay, I'm going to cover a lot of ground here, but I've also tried to break this down into simple, managable pieces. This tutorial only assumes you have basic knowledge of a Rails application and almost zero knowledge of an Ember.js application, other than JavaScript.

I'm also using Rails 4.0.0. To install it...

    gem install rails

### Strap It Up

Let me be honest, this is super easy for a green project, but probably not the easiest task for a project that already has some clutter.

So, let's take the pie-in-the-sky route...

    rails new ember_tester -d postgresql -T

If you're using the PostgreSQL database, create the role and give it access with the superuser flag...

    createuser ember_tester -s

Bewm. Rails. With PostgreSQL (Heroku friendly, but not necessary).

Add in the _ember-rails_ gem to the _Gemfile_ and do some clean-up. Here's what mine looks like...

    source "https://rubygems.org"

    gem "rails", "4.0.0"

    gem "coffee-rails", "~> 4.0.0"
    gem "ember-rails"
    gem "foreman"
    gem "jquery-rails"
    gem "pg"
    gem "sass-rails", "~> 4.0.0"
    gem "uglifier", ">= 1.3.0"

And bundle it up...

    bundle install

Now you can bootstrap your new Rails app with Ember.js...

    rails generate ember:bootstrap

This creates a bunch of common folders and hooks you up with a namespace.

Making development mode work requires you to add the following to your _config/environments/development.rb_ environment file...

    config.ember.variant = :development

Stop here if you're all like, "Dude, I got it from here."

### Setting Up a Resource

Now, let's set up a Post resource on the Rails side of things...

    rails generate resource Post title:string body:text --no_helper

This will not only set up the Rails files, it will set up the Ember.js files as well! You get the file structure for free. This is helpful and, even if these files are basically empty placeholders now, in the long run you will end up using them.

Let's set up some seed data in your _db/seeds.rb_ file...

    puts "Seeding..."

    Post.create(
      title: "A Sample Post",
      body: "This will be a simple post record."
    )

    puts "Complete!"

Now, create/migration/seed your database...

    rake db:create db:migrate db:seed

### A Simple API

Okay, so we now have a resource, but I think the route Rails just gave us needs some help becoming an API for our new Ember.js client. So, let's make the _config/routes.rb_ look more like...

    EmberTester::Application.routes.draw do
      namespace :api do
        namespace :v1 do
          resources :posts
        end
      end

      root "ember#start"
    end

And, fix the _app/controllers/posts_controller.rb_. First, let's move it to the correct spot for our new API::V1 module...

    mkdir -p app/controllers/api/v1
    mv app/controllers/posts_controller.rb app/controllers/api/v1/posts_controller.rb

Also, we need to modulerize that PostsController. While we are in there, let's just give it some basic functionality of show and index actions...

    class Api::V1::PostsController < ApplicationController
      respond_to :json

      def index
        respond_with Post.all
      end

      def show
        respond_with Post.find(params[:id])
      end
    end

Yes, I know you can use some fancy pants API builder gem, but this is supposed to be a simple example application.

Ok, I'm gonna catch some heat for this, but we are going to remove "Turbolinks". We already got rid of the line requiring it in the Gemfile. Next, remove it from _app/assets/javascripts/application.js_ manifest. You can also remove it in the _app/views/layouts/application.html.erb_ file…

    "data-turbolinks-track" => true

Ugh. Get rid of that crap.

Now, add a controller that Ember.js can start with...

    rails generate controller Ember start --no_helper

Start a Rails server...

    rails server

You can now do...

    curl http://localhost:3000/api/v1/posts.json

And, that should return some JSON data for you.

What's happening here? Rails is happening. That route we created is now serving a JSON representation of _Post.all_ from the controller. The object (in this case, an Array of Post objects) gets serialized with the [active_model_serializers](https://github.com/rails-api/active_model_serializers) gem. This gem gives you a serializer class to tell Rails what the JSON should look like when someone requests it. Take a look at the _app/serializers/post_serializer.rb_ file. The _active_model_serializers_ gem plays nice with Ember.js and _ember-rails_ includes it for you. The Rails resource generator even generated a serializer class for us.

Do you know how hard this would have been like 6 years ago in Java? Pain. Full.

### Hooking Up to Ember.js

Point your browser at _http://localhost:3000_ and see what you have so far. You should see in the Web Inspector's console a few debug messages from Ember.js. And, you should see the application (with Handlebars) template rendering.

Ember.js does a lot for you. It gets everyone all bound up for you. Just waiting.

#### The Store

We need to tell Ember.js that we are foolin' and moved the API into our own little secret path. In the _app/assets/javascripts/store.js.coffee_…

    DS.RESTAdapter.reopen
      namespace: "api/v1"

    EmberTester.Store = DS.Store.extend
      revision: 12
      adapter: DS.RESTAdapter.create()

Ember.js's Store is like the _config/database.yml_ in Rails. It tells [ember-data](https://github.com/emberjs/data) where to get data for the models. It sets up all the adapters so you can have any data source backing your Ember.js application.

#### Routes

Now, we should route users around. Create a new route file for our Posts index...

    touch app/assets/javascripts/routes/posts_route.js.coffee

Fill it in...

    EmberTester.PostsRoute = Ember.Route.extend
      model: ->
        EmberTester.Post.find()

The model function now just returns all the Post records in our Store.

Now, in our _app/assets/javascripts/router.js.coffee_ we can connect the routes to the resources...

    EmberTester.Router.map ->
      @resource "posts", ->
        @resource "post",
          path: ":post_id"

Nesting these routes makes the _{{outlet}}_ areas of the templates work to render inside each other. _{{outlet}}_ works like _yield_ in Rails. Nesting routes should happen when the user-interface deems it nested as well.

#### Candybars... I mean, Handlebars

Let's edit up our _app/assets/javascripts/templates/application.handlebars_ template and add some navigation...

    <header id="header">
      <h2>{{#linkTo "index"}}Home{{/linkTo}}</h2>

      <nav>
        <ul>
          <li>{{#linkTo "posts"}}Posts{{/linkTo}}</li>
        </ul>
      </nav>
    </header>

    <div id="content">
    {{outlet}}
    </div>

The _app/assets/javascripts/templates/posts.handlebars_ template...

    <h1>Posts</h1>

    <ul>
    {{#each post in controller}}
      <li>{{#linkTo "post" post}}{{post.title}}{{/linkTo}}</li>
    {{else}}
      <li>There are no posts.</li>
    {{/each}}
    </ul>

    {{outlet}}

And, finally the _app/assets/javascripts/templates/post.handlebars_ template...

    <h1>{{title}}</h1>

    <p>{{body}}</p>

You're done. Take a deep breath.

Now, we didn't do anything very exciting yet. Future posts will detail more functionality that Ember.js and Rails can do together. Coming soon will be how to connect Pusher with Rails and Ember.js!
