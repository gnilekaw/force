_ = require 'underscore'
{ STATUSES } = require('sharify').data
Backbone = require 'backbone'
analytics = require '../../../../lib/analytics.coffee'
mediator = require '../../../../lib/mediator.coffee'
Sticky = require '../../../../components/sticky/index.coffee'
# Sub-header
RelatedGenesView = require '../../../../components/related_links/types/artist_genes.coffee'
RelatedRepresentationsGenesView = require '../../../../components/related_links/types/artist_representations.coffee'
# Main section
ArtworkFilter = require '../../../../components/artwork_filter/index.coffee'
# Bottom sections
RelatedPostsView = require '../../../../components/related_posts/view.coffee'
RelatedShowsView = require '../../../../components/related_shows/view.coffee'
ArtistFillwidthList = require '../../../../components/artist_fillwidth_list/view.coffee'
lastModified = require './last_modified.coffee'
template = -> require('../../templates/overview.jade') arguments...

module.exports = class OverviewView extends Backbone.View
  subViews: []
  fetches: []

  initialize: ({ @user }) ->
    @sticky = new Sticky

  setupSubHeader: ->
    @setupRelatedGenes()
    @setupRelatedRepresentations()

  setupArtworkFilter: ->
    filterRouter = ArtworkFilter.init el: @$('#artwork-section'), model: @model
    @filterView = filterRouter.view
    @subViews.push @filterView

  setupRelatedShows: ->
    if STATUSES.shows
      @fetches.push @model.related().shows.fetch()
      subView = new RelatedShowsView collection: @model.related().shows
      @$('#artist-related-shows').html subView.render().$el
      @subViews.push subView
      @setupRelatedSection @$('#artist-related-shows-section')

  setupRelatedPosts: ->
    if STATUSES.posts
      @fetches.push @model.related().posts.fetch()
      subView = new RelatedPostsView collection: @model.related().posts, numToShow: 4
      @$('#artist-related-posts').html subView.render().$el
      @subViews.push subView
      @setupRelatedSection @$('#artist-related-posts-section')

  setupRelatedGenes: ->
    @subViews.push new RelatedGenesView(el: @$('.artist-related-genes'), id: @model.id)

  setupRelatedRepresentations: ->
    @subViews.push new RelatedRepresentationsGenesView(el: @$('.artist-related-representations'), id: @model.id)

  setupRelatedSection: ($el) ->
    $section = @fadeInSection $el
    @sticky.add $section.find('.artist-related-section-header')
    $el

  fadeInSection: ($el) ->
    $el.show()
    _.defer -> $el.addClass 'is-fade-in'
    $el

  setupRelatedArtists: ->
    _.each _.pick(STATUSES, 'artists', 'contemporary'), (display, key) =>
      if display
        @fetches.push @model.related()[key].fetch
          data: size: 5
          success: =>
            @renderRelatedArtists key

  setupLastModifiedDate: ->
    @fetches.push @waitForFilter()
    $.when.apply(null, @fetches).then =>
      lastModified @model, @filterView.artworks

  waitForFilter: ->
    dfd = $.Deferred()
    { filter, artworks } = @filterView
    @listenToOnce artworks, 'sync', dfd.resolve
    dfd.promise()

  renderRelatedArtists: (type) ->
    $section = @$("#artist-related-#{type}-section")
    if @model.related()[type].length
      @setupRelatedSection $section
      collection = new Backbone.Collection(@model.related()[type].take 5)
      subView = new ArtistFillwidthList
        el: @$("#artist-related-#{type}")
        collection: collection
        user: @user
      subView.fetchAndRender()
      @subViews.push subView
    else
      $section.remove()

  postRender: ->
    # Sub-header
    @setupSubHeader()
    # Main section
    @setupArtworkFilter()
    # Bottom sections
    @setupRelatedArtists()
    @setupRelatedShows()
    @setupRelatedPosts()
    @setupLastModifiedDate()

  render: ->
    @$el.html template(artist: @model)
    _.defer => @postRender()
    this

  remove: ->
    _.invoke @subViews, 'remove'
