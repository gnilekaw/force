_ = require 'underscore'
jade = require 'jade'
fs = require 'fs'
cheerio = require 'cheerio'
moment = require 'moment'
{ resolve } = require 'path'
{ fabricate } = require 'antigravity'
Show = require '../../../models/show'
{ Cities, FeaturedCities } = require 'places'

render = (templateName) ->
  filename = resolve __dirname, "../templates/#{templateName}.jade"
  jade.compile(
    fs.readFileSync(filename),
    { filename: filename }
  )

describe 'Shows template', ->
  describe '#index with cities and featured show', ->
    xit 'renders correctly', ->
      html = render('../templates/index')
        sd: {}
        cities: Cities
        featuredCities: FeaturedCities
        featuredShow: new Show fabricate 'show'

      @$ = cheerio.load(html)

      @$('.shows-header').length.should.equal 1
      @$('.shows-page-featured-cities a').length.should.equal 11

  describe '#cities with single city and shows', ->
    it 'renders correctly', ->
      @currentShow = new Show fabricate 'show', status: 'running', id: 'running-show', name: 'running-show'
      @upcomingShow = new Show fabricate 'show', status: 'upcoming', id: 'upcoming-show', name: 'upcoming-show'
      @pastShow = new Show fabricate 'show', status: 'closed', id: 'closed-show', name: 'closed-show'

      html = render('../templates/city')
        sd: {}
        city: {name: 'New York'}
        opening: []
        upcoming: [@upcomingShow]
        current: [@currentShow]
        past: [@pastShow]

      html.should.containEql 'shows-city--current-shows'
      html.should.containEql 'shows-city--upcoming-shows'
      html.should.containEql 'shows-city--past-shows'

  describe '#all-cities with every city', ->
    it 'renders correctly', ->
      html = render('../templates/all_cities')
        sd: {}
        cities: Cities

      @$ = cheerio.load(html)
      @$('.all-cities-page-all-cities a').length.should.be.above 83
