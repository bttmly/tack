require( "chai" ).should()
Function::bind = Function::bind or require( "function-bind" )
tack = require "../src/tack.coffee"

describe "Maker function", ->
  describe "Building from string (tagName)", ->
    it "throws an error if passed an invalid tag name", ->
      ( -> tack "asdf" ).should.throw()

    it "works when passed a valid tag name", ->
      tag = undefined
      ( -> tag = tack "input" ).should.not.throw()
      tag.tagName.should.equal "input"
      tag.attributes.should.deep.equal {}
      tag.classes.should.deep.equal []
      tag.children.should.deep.equal []

  describe "Building from a DOM node", ->
    it "should produce the correct html", ->
      input = document.createElement "input"
      input.id = "the-input"
      input.classList.add "class1"
      input.classList.add "class2"
      input.type = "text"
      input.name = "text-input"
      tag = tack input
      tag.toString().should.equal '<input class="class1 class2" id="the-input" type="text" name="text-input">'

    it "should work recursively if node has children", ->
      html = """
        <ul class="list" id="middle">
          <li class="item" id="bottom">
            Hello
          </li>
        </ul>
      """
      div = document.createElement "div"
      div.id = "top"
      div.innerHTML = html
      tag = tack div
      tag.children.length.should.equal 1
      tag.childAt( 0 ).tagName.should.equal "ul"
      tag.childAt( 0 ).childAt( 0 ).tagName.should.equal "li"
      console.log tag.render()
      tag.render().should.equal '<div id="top"><ul class="list" id="middle"><li class="item" id="bottom">Hello</li></ul></div>'

describe "Methods", ->
  tag = undefined
  proto = undefined
  ctor = undefined
  beforeEach ->
    tag = tack "div"
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
      ( "someThing" in tag.classes ).should.be.ok
      tag.classes.length.should.equal 2

  describe "removeClass", ->
    it "Adds a class if not already present, and returns self", ->
      tag.addClass "someThing"
      tag.addClass "otherThing"
      tag.removeClass( "someThing" ).should.equal tag
      ( "someThing" in tag.classes ).should.not.be.ok
      tag.classes.length.should.equal 1

  describe "addChild", ->
    it "Adds a child tack", ->
      tag.addChild "div"
      tag.children.length.should.equal 1
      tag.children[0].should.be.instanceof ctor

  describe "childAt", ->
    it "Returns the child at the given index", ->
      tag.addChild "p"
      tag.childAt( 0 ).tagName.should.equal "p"

  describe "render", ->
    it "Generates the correct HTML string", ->
      tag.id "some-id"
      tag.addClass "some-class"
      tag.attr "name", "some-name"
      tag.render().should.equal '<div class="some-class" id="some-id" name="some-name"></div>'
