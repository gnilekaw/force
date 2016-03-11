helpers = require '../view_helpers'

describe 'ArtistViewHelpers', ->
  describe 'pageTitle', ->
    it 'formats correctly with or without name and count', ->
      helpers.pageTitle(
        id: 'foo-bar'
        name: null
        counts: artworks: null
      ).should.containEql 'Unnamed Artist - Artworks, Bio & Shows on Artsy'

      helpers.pageTitle(
        id: 'foo-bar'
        name: null
        counts: artworks: 0
      ).should.containEql 'Unnamed Artist - Artworks, Bio & Shows on Artsy'

      helpers.pageTitle(
        id: 'foo-bar'
        name: 'Foo Bar'
        counts: artworks: 0
      ).should.containEql 'Foo Bar - Artworks, Bio & Shows on Artsy'

      helpers.pageTitle(
        id: 'foo-bar'
        name: 'Foo Bar'
        counts: artworks: 10
      ).should.containEql 'Foo Bar - 10 Artworks, Bio & Shows on Artsy'

    it 'formats correctly with meta override', ->
      helpers.pageTitle(
        id: 'art-stage-singapore-2016'
        name: 'Foo Bar'
        counts: artworks: 10
      ).should.containEql 'Art Stage Singapore  2016 | Artsy'

  describe 'pageDescription', ->
    it 'formats correctly without character limit', ->
      helpers.pageDescription(
        id: 'foo-bar'
        name: 'Foo Bar'
        gender: 'male'
        blurb: 'Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah'
      ).should.containEql 'Find the latest shows, biography, and artworks for sale by Foo Bar. Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah'

    it 'formats correctly with character limit', ->
      helpers.pageDescription(
        id: 'foo-bar'
        name: 'Foo Bar'
        gender: 'male'
        blurb: 'Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah'
      , 100).should.containEql 'Find the latest shows, biography, and artworks for sale by Foo Bar. Blah Blah Blah Blah Blah Blah...'

    it 'formats correctly with meta override', ->
      helpers.pageDescription(
        id: 'art-stage-singapore-2016'
        name: 'Foo Bar'
        gender: 'male'
        blurb: 'Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah'
      ).should.containEql 'Explore work from Asia and beyond as 140+ regional and international galleries—Tomio Koyama Gallery, Whitestone Gallery, and amanasalto among them—gather in Singapore.'

  it 'formatAlternateNames', ->
    helpers.formatAlternateNames(alternate_names: []).should.containEql ''
    helpers.formatAlternateNames(alternate_names: ['Joe Shmoe']).should.containEql 'Joe Shmoe'
    helpers.formatAlternateNames(alternate_names: ['Joe Shmoe', 'Someone Else']).should.containEql 'Joe Shmoe; Someone Else'

  it 'displayNationalityAndBirthdate', ->
    helpers.displayNationalityAndBirthdate(nationality: 'American', years: 'born 1955')
      .should.containEql 'American, born 1955'

    helpers.displayNationalityAndBirthdate(nationality: 'American')
      .should.containEql 'American'

    helpers.displayNationalityAndBirthdate(years: 'born 1955')
      .should.containEql 'born 1955'

    helpers.displayNationalityAndBirthdate({}).should.containEql ''

  it 'displayFollowers', ->
    result = helpers.displayFollowers(counts: follows: 0)
    (result == undefined).should.be.true()
    helpers.displayFollowers(counts: follows: 1).should.containEql '1 Follower'
    helpers.displayFollowers(counts: follows: 2).should.containEql '2 Followers'

  it 'mdToHtml', ->
    artist = blurb: "Jeff Koons plays with ideas of taste, pleasure, celebrity, and commerce. “I believe in advertisement and media completely,” he says. “My art and my personal life are based in it.” Working with seductive commercial materials (such as the high chromium stainless steel of his “[Balloon Dog](/artwork/jeff-koons-balloon-dog-blue)” sculptures or his vinyl “Inflatables”), shifts of scale, and an elaborate studio system involving many technicians, Koons turns banal objects into high art icons. His paintings and sculptures borrow widely from art-historical techniques and styles; although often seen as ironic or tongue-in-cheek, Koons insists his practice is earnest and optimistic. “I’ve always loved [Surrealism](/gene/surrealism) and [Dada](/gene/dada) and [Pop](/gene/pop-art), so I just follow my interests and focus on them,” he says. “When you do that, things become very metaphysical.” The “Banality” series that brought him fame in the 1980s included pseudo-[Baroque](/gene/baroque) sculptures of subjects like Michael Jackson with his pet ape, while his monumental topiaries, like the floral _Puppy_ (1992), reference 17th-century French garden design."
    result = helpers.mdToHtml artist, 'blurb'
    result.should.containEql """
      <p>Jeff Koons plays with ideas of taste, pleasure, celebrity, and commerce. “I believe in advertisement and media completely,” he says. “My art and my personal life are based in it.” Working with seductive commercial materials (such as the high chromium stainless steel of his “<a href="/artwork/jeff-koons-balloon-dog-blue">Balloon Dog</a>” sculptures or his vinyl “Inflatables”), shifts of scale, and an elaborate studio system involving many technicians, Koons turns banal objects into high art icons. His paintings and sculptures borrow widely from art-historical techniques and styles; although often seen as ironic or tongue-in-cheek, Koons insists his practice is earnest and optimistic. “I’ve always loved <a href="/gene/surrealism">Surrealism</a> and <a href="/gene/dada">Dada</a> and <a href="/gene/pop-art">Pop</a>, so I just follow my interests and focus on them,” he says. “When you do that, things become very metaphysical.” The “Banality” series that brought him fame in the 1980s included pseudo-<a href="/gene/baroque">Baroque</a> sculptures of subjects like Michael Jackson with his pet ape, while his monumental topiaries, like the floral <em>Puppy</em> (1992), reference 17th-century French garden design.</p>
    """

  it 'toJSONLD', ->
    artist = {
      image: large: '/foo/bar/large.jpg'
      name: 'Foo Bar'
      href: '/foo-bar'
      gender: 'male'
      birthday: '1900'
      deathday: '2000'
    }

    result = helpers.toJSONLD(artist)
    result.should.containEql {
      "@context": "http://schema.org"
      "@type": "Person"
      image: '/foo/bar/large.jpg'
      name: 'Foo Bar'
      gender: 'male'
      birthDate: '1900'
      deathDate: '2000'
      additionalType: 'Artist'
    }
    result.url.should.containEql '/foo-bar'

