# element lists from atom/space-pen
tags =
"a abbr address article aside audio b bdi bdo blockquote body button canvas
caption cite code colgroup datalist dd del details dfn dialog div dl dt em
fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header html i
iframe ins kbd label legend li main map mark menu meter nav noscript object
ol optgroup option output p pre progress q rp rt ruby s samp script section
select small span strong style sub summary sup table tbody td textarea tfoot
th thead time title tr u ul var video area base br col command embed hr img
input keygen link meta param source track wbr".split( /\s+/ ).reduce ( tags, tag ) ->
  tags[tag] = true
  tags
, Object.create null

selfClosingTags =
"area base br col command embed hr img input keygen link meta param
 source track wbr".split( /\s+/ ).reduce ( selfClosingTags, tag ) ->
  selfClosingTags[tag] = true
  tags[tag] = true
  selfClosingTags
, Object.create null

map = Function::call.bind Array::map
each = Function::call.bind Array::forEach
reduce = Function::call.bind Array::reduce

remove = ( arr, item ) ->
  i = arr.indexOf item
  while i > -1
    arr.splice i, 1
    i = arr.indexOf item
  arr

defaults = ->
  attributes: {}
  classes: []
  children: []

extend = ( target, objs... ) ->
  for obj in objs
    for prop of obj
      target[prop] = obj[prop]
  target

normalizeTextNode = ( node ) ->
  if node.nodeType is 3
    node.textContent = node.textContent.replace( /↵/g, "\n" ).trim()

buildFromDomNode = ( node ) ->
  opts =
    attributes: {}
  if node.nodeType is 3
    new TackText node.textContent
  else if node.nodeType is 1
    each node.attributes, ( attr ) ->
      if attr.name is "class"
        opts.classes = attr.value.split " "
      else
        opts.attributes[attr.name] = attr.value
    opts.tagName = node.tagName.toLowerCase()
    opts.children = reduce node.childNodes, ( acc, node ) ->
      normalizeTextNode node
      if node.nodeType is 1 or node.textContent
        acc.push buildFromDomNode node
      acc
    , []
    new Tack opts

class TackText
  constructor: ( str ) ->
    @text = str

  render: -> @text

  toString: -> @render()

class Tack
  constructor: ( param ) ->
    if typeof param is "string"
      throw new Error "Invalid tag name." unless tags[ param ]
      extend @, defaults(), tagName: param
    else if param instanceof Element
      extend @, defaults(), buildFromDomNode( param )
    else
      extend @, defaults(), param
    @classes = @classes.split " " if typeof @classes is "string"

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
    unless className in @classes
      @classes.push className
    @

  removeClass: ( className ) ->
    remove @classes, className
    @

  hasClass: ( className ) ->
    className in @classes

  toggleClass: ( className ) ->
    if @hasClass className
      @removeClass className
    else
      @addClass className

  addChild: ( param ) ->
    @children.push tack param
    @

  childAt: ( index ) ->
    @children[index]

  removeChildAt: ( index ) ->
    @children.splice index, 1
    @

  addText: ( str ) ->
    @children.push new TackText str
    @

  render: ->
    result = []
    str = ""
    result.push "<#{ @tagName }"
    if @classes.length
      result.push " class=\"#{ @classes.join " " }\""
    attrs = Object.keys( @attributes ).sort()
    for attr in attrs
      str += " #{ attr }=\"#{ @attributes[ attr ] }\""
    result.push str
    result.push ">"
    unless selfClosingTags[ @tagName ]
      if @children.length
        result.push child.render() for child in @children
      result.push "</#{ @tagName }>"
    result.join ""

  toString: -> @render()

  create: ->
    el = document.createElement @tagName
    for attr of @attributes
      el.setAttribute attr, @attributes[attr]
    for cl in @classes
      el.classList.add cl
    el.innerHTML = @children.map ( child ) ->
      child.render()
    .join ""
    el

  clone: ->

    new Tack @

tack = ( param ) ->
  new Tack param

extend tack,
  fromNode: buildFromDomNode
  replace: ( oldNode, newNode ) ->
    parent = oldNode.parentElement
    parent.insertBefore newNode, oldNode
    parent.removeChild oldNode
  extend: ( obj ) ->
    extend Tack::, obj

module.exports = tack
