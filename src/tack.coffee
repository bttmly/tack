# element lists from atom/space-pen
tags = Object.create null
"a abbr address article aside audio b bdi bdo blockquote body button canvas
caption cite code colgroup datalist dd del details dfn dialog div dl dt em
fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header html i
iframe ins kbd label legend li main map mark menu meter nav noscript object
ol optgroup option output p pre progress q rp rt ruby s samp script section
select small span strong style sub summary sup table tbody td textarea tfoot
th thead time title tr u ul var video area base br col command embed hr img
input keygen link meta param source track wbr".split( /\s+/ ).forEach ( tag ) ->
  tags[tag] = true

selfClosingTags = Object.create null
"area base br col command embed hr img input keygen link meta param
 source track wbr".split( /\s+/ ).forEach ( tag ) ->
  selfClosingTags[tag] = true
  tags[tag] = true

map = Function::call.bind Array::map
each = Function::call.bind Array::forEach

remove = ( arr, item ) ->
  i = arr.indexOf item
  while i > -1
    arr.splice i, 1
    i = arr.indexOf item
  arr

defaults = ->
  attributes: {}
  class: []
  children: []

extend = ( target, objs... ) ->
  for obj in objs
    for prop of obj
      target[prop] = obj[prop]
  target

buildFromDomNode = ( node ) ->
  opts =
    attributes: {}
  if node.nodeType is 3
    new TackText node.textContent
  else if node.nodeType is 1
    each node.attributes, ( attr ) ->
      if attr.name is "class"
        opts.class = attr.value.split " "
      else
        opts.attributes[attr.name] = attr.value
    opts.tagName = node.tagName.toLowerCase()
    opts.children = map node.childNodes, ( node ) ->
      new Tack buildFromDomNode node
    opts

class TackText
  constructor: ( str ) ->
    @text = str
  render: -> @text
  toString: -> @text

class Tack
  constructor: ( param ) ->
    if typeof param is "string"
      throw new Error "Invalid tag name." unless tags[ param ]
      extend @, defaults(), tagName: param
    else if param instanceof Element
      extend @, defaults(), buildFromDomNode( param )
    else
      extend @, defaults(), param
    @class = @class.split " " if typeof @class is "string"

  id: ( id ) ->
    if id?
      @attributes.id = id
      @
    else
      @attributes.id

  attr: ( name, value ) ->
    if value?
      @attributes[ name ] = value
      @
    else
      @attributes[ name ]

  removeAttr: ( name ) ->
    delete @attributes[ name ]
    @

  addClass: ( className ) ->
    unless className in @class
      @class.push className
    @

  removeClass: ( className ) ->
    remove @class, className
    @

  hasClass: ( className ) ->
    @class.indexOf( className ) isnt -1

  toggleClass: ( className ) ->
    if @hasClass className
      @removeClass className
    else
      @addClass className

  addChild: ( param ) ->
    @children.push tackMaker param
    @

  removeChildAt: ( index ) ->
    @children.splice index, 1
    @

  addText: ( str ) ->
    @children.push new TackText str
    @

  map: ( fn ) ->
    copy = fn @clone()

    copy

  render: ->
    result = []
    str = ""
    result.push "<#{ @tagName } "
    if @class.length
      result.push "class=\"#{ @class.join " " }\" "
    for attr of @attributes
      str += "#{ attr }=\"#{ @attributes[ attr ] }\" "
    result.push str.trim()
    result.push ">"
    unless selfClosingTags[ @tagName ]
      if @children.length
        result.push child.render() for child in @children
      result.push "</#{ @tagName }>"
    result.join ""

  toString: -> @render()

  clone: ->
    new Tack @

tackMaker = ( param ) ->
  new Tack param

if typeof module isnt "undefined"
  module.exports = tackMaker
else
  window.tackMaker = tackMaker
