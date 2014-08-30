if typeof require is "function"
  require( "chai" ).should()
  tackMaker = require "../src/tack"
else
  tackMaker = window.tackMaker

haveSameAttributes = ( el1, el2 ) ->
  return false unless el1.attributes.length is el2.attributes.length


describe "Maker function", ->
  describe "Building from string (tagName)", ->
    it "throws an error if passed an invalid tag name", ->
      ( -> tackMaker "asdf" ).should.throw()

    it "works when passed a valid tag name", ->
      tag = undefined
      ( -> tag = tackMaker "input" ).should.not.throw()
      tag.tagName.should.equal "input"
      tag.attributes.should.deep.equal {}
      tag.class.should.deep.equal []
      tag.children.should.deep.equal []

  describe "Building from a DOM node", ->
    input = document.createElement "input"
    input.id = "the-input"
    input.classList.add "class1"
    input.classList.add "class2"
    input.type = "text"
    input.name = "text-input"
    tag = tackMaker input
    console.log tag.toString()

describe "Methods", ->
  tag = undefined
  proto = undefined
  ctor = undefined
  beforeEach ->
    tag = tackMaker "div"
    proto = Object.getPrototypeOf tag
    ctor = proto.constructor

  describe "attr", ->
    it "Sets an attribute when called with two arguments, and returns self", ->
      tag.attr( "type", "text" ).should.equal tag
      tag.attributes.type.should.equal "text"

    it "Returns an attribute value called with one argument", ->
      tag.attr "type", "text"
      tag.attr( "type" ).should.equal "text"

  describe "id", ->
    it "Sets the id attribute when called with an argument, and returns self", ->
      tag.id( "thing" ).should.equal tag
      tag.attributes.id.should.equal "thing"

    it "Returns the id when called with no arguments", ->
      tag.id "thing"
      tag.id().should.equal "thing"

  describe "addClass", ->
    it "Adds a class if not already present, and returns self", ->
      tag.addClass "someThing"
      tag.addClass "otherThing"
      tag.addClass( "someThing" ).should.equal tag
      ( "someThing" in tag.class ).should.be.ok
      tag.class.length.should.equal 2

  describe "removeClass", ->
    it "Adds a class if not already present, and returns self", ->
      tag.addClass "someThing"
      tag.addClass "otherThing"
      tag.removeClass( "someThing" ).should.equal tag
      ( "someThing" in tag.class ).should.not.be.ok
      tag.class.length.should.equal 1

  describe "addChild", ->
    it "Adds child Stringers", ->
      tag.addChild "div"
      tag.children.length.should.equal 1
      tag.children[0].should.be.instanceof ctor

  describe "render", ->
    it "Generates the correct HTML string", ->
      tag.id "some-id"
      tag.addClass "some-class"
      tag.attr "name", "some-name"
      tag.render().should.equal '<div class="some-class" id="some-id" name="some-name"></div>'

if typeof mocha isnt "undefined"
  do mocha.run
