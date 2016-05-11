_ = require 'underscore'
moment = require 'moment'
Artist = require '../../models/artist.coffee'
{ timespanInWords } = require '../../components/util/date_helpers.coffee'
{ capitalize, numberFormat } = require 'underscore.string'

module.exports =
  capitalize: capitalize

  pageDescription: (artist, limit) ->
    artist = new Artist _.pick artist, 'id', 'name', 'gender', 'blurb'
    artist.toPageDescription(limit)

  formatAlternateNames: (artist) ->
    if alts = artist.alternate_names then artist.alternate_names.join('; ') else ''

  displayNationalityAndBirthdate: (artist) ->
    _.compact([
      artist.nationality
      @formatBirthDeath artist if artist.birthday?.length
    ]).join ', '

  formatBirthDeath: (artist) ->
    if artist.deathday?.length
      "#{artist.birthday}–#{artist.deathday}"
    else
      "b. #{artist.birthday}"

  artistMeta: (artist) ->
    return '' if not (artist.hometown or artist.location)
    _.compact([
      artist.nationality if artist.nationality?.length
      @formatBirthDeath artist if artist.birthday?.length
      artist.hometown if artist.hometown?.length
      "based in #{artist.location}" if artist.location?.length
    ]).join ', '

  displayFollowers: (artist) ->
    "#{numberFormat(c)}" if c = artist.counts.follows

  mdToHtml: (artist, attr) ->
    artist = new Artist _.pick artist, attr
    artist.mdToHtml attr

  formatAuctionDetail: (end) ->
    minuteFormat = if end.minute() > 0 then ':mm' else ''
    end.format('[Auction Closes] MMM D [at] h' + minuteFormat + ' A');

  formatShowDetail: (item) ->
    _.compact([
      item.city
      timespanInWords(item.start_at, item.end_at, day: 'D')
    ]).join ', '