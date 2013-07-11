EmberTester.Router.map ->
  @resource "posts", ->
    @resource "post",
      path: ":post_id"
