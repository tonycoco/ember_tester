EmberTester.PostsRoute = Ember.Route.extend
  model: ->
    EmberTester.Post.find()
