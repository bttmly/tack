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
    it "should produce the correct instance", ->
      input = document.createElement "input"
      input.id = "the-input"
      input.classList.add "class1"
      input.classList.add "class2"
      input.type = "text"
      input.name = "text-input"
      tag = tack input
      tag.attributes.name.should.equal "text-input"
      tag.attributes.type.should.equal "text"
      tag.attributes.id.should.equal "the-input"
      tag.tagName.should.equal "input"
      tag.classes.should.deep.equal ["class1", "class2"]
      tag.render().should.equal '<input class="class1 class2" id="the-input" name="text-input" type="text">'

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
      tag.render().should.equal '<div id="top"><ul class="list" id="middle"><li class="item" id="bottom">Hello</li></ul></div>'

  describe "building from options", ->
    it "should throw an error if the tagName property isn't a valid HTML tag name", ->
      ( -> tack tagName: "asdf" ).should.throw()
    it "should create the correct instance from the options", ->
      tag = tack
        tagName: "input"
        classes: ["class1", "class2"]
        attributes:
          type: "text"
          id: "the-input"
          name: "text-input"
      tag.tagName.should.equal "input"
      tag.attributes.type.should.equal "text"
      tag.attributes.id.should.equal "the-input"
      tag.attributes.name.should.equal "text-input"
      tag.classes.should.deep.equal ["class1", "class2"]

describe "Instance methods", ->
  tag = undefined
  proto = undefined
  ctor = undefined
  beforeEach ->
    tag = tack "div"
    proto = Object.getPrototypeOf tag
    ctor = proto.constructor

  describe ".attr()", ->
    it "Sets an attribute when called with two arguments, and returns self", ->
      tag.attr( "type", "value" ).should.equal tag
      tag.attributes.type.should.equal "value"

    it "Returns an attribute value called with one argument", ->
      tag.attr "type", "value"
      tag.attr( "type" ).should.equal "value"

    it "Can set the 'class' attribute properly", ->
      tag.attr( "class", "some classes" ).should.equal tag
      tag.classes.should.deep.equal ["some", "classes"]

    it "Can get the 'class' attribute properly", ->
      tag.addClass "some classes"
      tag.attr( "class" ).should.equal "some classes"

  describe ".id()", ->
    it "Sets the id attribute when called with an argument, and returns self", ->
      tag.id( "thing" ).should.equal tag
      tag.attributes.id.should.equal "thing"

    it "Returns the id when called with no arguments", ->
      tag.id "thing"
      tag.id().should.equal "thing"

  describe ".addClass()", ->
    it "Adds a class if not already present, and returns self", ->
      tag.addClass "otherThing"
      tag.addClass( "someThing" ).should.equal tag
      ( "someThing" in tag.classes ).should.be.ok
      tag.addClass "someThing"
      tag.classes.length.should.equal 2

    it "Adds multiple space separated classes", ->
      tag.addClass "class1 class2"
      tag.classes.indexOf( "class1" ).should.not.equal -1
      tag.classes.indexOf( "class2" ).should.not.equal -1

  describe ".removeClass()", ->
    it "Adds a class if not already present, and returns self", ->
      tag.addClass "someThing"
      tag.addClass "otherThing"
      tag.removeClass( "someThing" ).should.equal tag
      ( "someThing" in tag.classes ).should.not.be.ok
      tag.classes.length.should.equal 1

  describe ".hasClass()", ->
    it "Returns whether or not the element has that class", ->
      tag.addClass "has-it"
      tag.hasClass( "has-it" ).should.equal true
      tag.hasClass( "doesnt-have" ).should.equal false

  describe ".addChild()", ->
    it "Adds a child tack", ->
      tag.addChild "div"
      tag.children.length.should.equal 1
      tag.children[0].should.be.instanceof ctor

  describe ".childAt()", ->
    it "Returns the child at the given index", ->
      tag.addChild "p"
      tag.childAt( 0 ).tagName.should.equal "p"

  describe ".render()", ->
    it "Generates the correct HTML string", ->
      tag.id "some-id"
      tag.addClass "some-class"
      tag.attr "name", "some-name"
      tag.render().should.equal '<div class="some-class" id="some-id" name="some-name"></div>'

  describe ".create()", ->
    it "Creates a DOM node from a tack", ->
      tag.addClass "thing"
      tag.id "blah"
      tag.addChild "ul"
      tag.childAt( 0 ).addChild "li"
      node = tag.create()
      ( node instanceof Element ).should.equal true
      node.id.should.equal "blah"
      node.classList.contains( "thing" ).should.equal true
      node.children.length.should.equal 1
      node.children[0].tagName.should.equal "UL"
      node.children[0].children[0].tagName.should.equal "LI"

  describe ".clone()", ->
    it "Deeply clones a Tack", ->
      tag.addChild "ul"
      tag.childAt( 0 ).addChild "li"
      clone = tag.clone()
      clone.should.not.equal tag
      clone.childAt( 0 ).should.not.equal tag.childAt 0
      clone.childAt( 0 ).childAt( 0 ).should.not.equal tag.childAt( 0 ).childAt( 0 )


describe "Static methods", ->
  describe ".replace()", ->
    it "replaces one DOM node with another", ->
      div = document.createElement "div"
      span1 = document.createElement "span"
      span2 = document.createElement "span"
      div.appendChild span1
      div.children[0].should.equal span1
      tack.replace( span1, span2 )
      div.children[0].should.equal span2

  describe ".extend()", ->
    it "adds properties and/or methods to the Tack prototype", ->
      tack.extend
        func: ->
        prop: 10
      div = tack "div"
      div.func.should.be.a "function"
      div.prop.should.equal 10

  describe ".fromNode()", ->
    it "builds a Tack instance from a DOM node", ->
      div = document.createElement "div"
      tag = tack.fromNode( div )
      tag.render().should.equal "<div></div>"

