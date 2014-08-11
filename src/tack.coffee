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

remove = ( arr, item ) ->
  i = arr.indexOf item
  while i > -1
    arr.splice i, 1
    i = arr.indexOf item
  arr

class Tack
  constructor: ( param ) ->
    if typeof param is "string"
      throw new Error "Invalid tag name." unless tags[ param ]
      @_tagName = param
      @_attributes = {}
      @_class = []
      @_children = []
      @_html = ""
    else if param instanceof Element
      @_tagName = param.tagName
    else
      { @_tagName, @_attributes, @_class, @_html } = tagName

  html: ( html ) ->
    if html?
      @_html = html
      @
    else
      @_html

  id: ( id ) ->
    if id?
      @_id = id
      @
    else
      @_id

  attr: ( name, value ) ->
    if value?
      @_attributes[ name ] = value
      @
    else
      @_attributes[ name ]

  removeAttr: ( name ) ->
    delete @_attributes[ name ]
    @

  addClass: ( className ) ->
    unless className in @_class
      @_class.push className
    @

  removeClass: ( className ) ->
    remove @_class, className
    @

  addChild: ( param ) ->
    @_children.push tackMaker param
    @

  render: ->
    result = []
    str = ""
    result.push "<#{ @_tagName } "
    if @_id
      result.push "id=\"#{ @_id }\" "
    if @_class.length
      result.push "class=\"#{ @_class.join " " }\" "
    for attr of @_attributes
      str += "#{ attr }=\"#{ @_attributes[ attr ] }\" "
    result.push str.trim()
    result.push ">"
    unless selfClosingTags[ @_tagName ]
      if @_children.length
        result.push child.render() for child in @_children
      result.push @_html
      result.push "</#{ @_tagName }>"
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
