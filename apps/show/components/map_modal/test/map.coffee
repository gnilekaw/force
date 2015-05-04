_ = require 'underscore'
benv = require 'benv'
sinon = require 'sinon'
Backbone = require 'backbone'
{ resolve } = require 'path'
{ fabricate } = require 'antigravity'
PartnerShow = require '../../../../../models/partner_show.coffee'
Partner = require '../../../../../models/partner.coffee'
geo = require '../../../../../components/geo/index.coffee'
ModalView = benv.requireWithJadeify resolve(__dirname, '../../../../../components/modal/view'), ['modalTemplate']
PageModalView= benv.requireWithJadeify resolve(__dirname, '../map'), ['template']
PageModalView::modalTemplate = ModalView::modalTemplate

describe 'PageModalView', ->

  beforeEach (done) ->
    benv.setup =>
      benv.expose $: benv.require 'jquery'
      Backbone.$ = $
      sinon.stub Backbone, 'sync'
      PageModalView.__set__ 'geo', loadGoogleMaps: (cb) -> cb()
      PageModalView.__set__ 'GMaps', class @GMaps
        addStyle: ->
        setStyle: ->
        addMarker: sinon.stub()
      @show = new PartnerShow fabricate 'show'
      @show.get('location').coordinates = {lat: 30, lng: 30 }
      @partner = new Partner fabricate 'partner'
      @view = new PageModalView model: @show, partner: @partner
      done()

  afterEach ->
    benv.teardown()
    Backbone.sync.restore()

  describe '#initialize', ->
    it 'displays the shows information correctly', ->
      @view.$('.map-modal-partner-name').html().should.containEql 'Gagosian Gallery'
      @view.$('.map-modal-partner-location-address').html().should.containEql '529 W 20th St.'
      @view.$('.map-modal-partner-location-city').html().should.containEql 'New York, NY'
      @view.$('.map-modal-show-running-dates').html().should.containEql 'July 12 – August 23'

  describe '#postRender', ->
    it 'should pass the correct coordinate information to google maps', ->
      @view.postRender()
      @GMaps.prototype.addMarker.args[0][0].lat.should.equal 30
      @GMaps.prototype.addMarker.args[0][0].lat.should.equal 30