if typeof require is "function"
  require( "chai" ).should()
  tagMaker = require "../src/tack"

describe "Maker function", ->
  it "throws an error if passed an invalid tag name", ->
    ( -> tagMaker "asdf" ).should.throw()

  it "works when passed a valid tag name", ->
    tag = undefined
    ( -> tag = tagMaker "input" ).should.not.throw()
    tag._tagName.should.equal "input"
    tag._attributes.should.deep.equal {}
    tag._class.should.deep.equal []
    tag._children.should.deep.equal []
    tag._html.should.equal ""

describe "Methods", ->
  tag = undefined
  proto = undefined
  ctor = undefined
  beforeEach ->
    tag = tagMaker "div"
    proto = Object.getPrototypeOf tag
    ctor = proto.constructor

  describe "attr", ->
    it "Sets an attribute when called with two arguments, and returns self", ->
      tag.attr( "type", "text" ).should.equal tag
      tag._attributes.type.should.equal "text"

    it "Returns an attribute value called with one argument", ->
      tag.attr "type", "text"
      tag.attr( "type" ).should.equal "text"

  describe "id", ->
    it "Sets the id attribute when called with an argument, and returns self", ->
      tag.id( "thing" ).should.equal tag
      tag._id.should.equal "thing"

    it "Returns the id when called with no arguments", ->
      tag.id "thing"
      tag.id().should.equal "thing"

  describe "addClass", ->
    it "Adds a class if not already present, and returns self", ->
      tag.addClass "someThing"
      tag.addClass "otherThing"
      tag.addClass( "someThing" ).should.equal tag
      ( "someThing" in tag._class ).should.be.ok
      tag._class.length.should.equal 2

  describe "removeClass", ->
    it "Adds a class if not already present, and returns self", ->
      tag.addClass "someThing"
      tag.addClass "otherThing"
      tag.removeClass( "someThing" ).should.equal tag
      ( "someThing" in tag._class ).should.not.be.ok
      tag._class.length.should.equal 1

  describe "addChild", ->
    it "Adds child Stringers", ->
      tag.addChild "div"
      tag._children.length.should.equal 1
      tag._children[0].should.be.instanceof ctor

  describe "render", ->
    it "Generates the correct HTML string", ->
      tag.id "some-id"
      tag.addClass "some-class"
      tag.attr "name", "some-name"
      tag.render().should.equal '<div id="some-id" class="some-class" name="some-name"></div>'

if typeof mocha isnt "undefined"
  do mocha.run
