# Tack [![Build Status](https://travis-ci.org/nickb1080/tack.svg?branch=master)](https://travis-ci.org/nickb1080/tack)

jQuery-inspired syntax for building HTML strings.

## Factory

### `tack(String tagName | Element el | Object options)`
`tack()` is the factory function for `Tack` instances.
When passed a `tagName`, builds an instance with that value as it's tag name.
When passed a DOM element `el`, builds an instance from the properites of that element.
When passed an `options` object, builds an instance into which `options` are merged

## Instance Methods

### `.attr(String name, [String value])`
**Get signature**: When `value` isn't provided, returns the instance's value for the attribute `name`.

**Set signature**: When `value` is provided, sets the instance's `name` attribute to `value` and returns the instance.

### `.removeAttr(String name)`
Removes the attribute called `name` from the instance.

### `.id([String value])`
**Get signature**: When `value` isn't provided, returns the instance's value for the "id" attribute.

**Set signature**: When `value` is provided, sets the instance's "id" attribute to `value` and returns the instance.

### `.addClass(String className)`
Adds a space-separated list of classes to the instance.

### `.removeClass(String className)`
Removes a space-separated list of classes from the instance.

### `.toggleClass(String className)`
Toggles a space-separated list of classes on the instance.

### `.hasClass(String className)`
Returns whether or not an instance has each class in a space-separated list of classes.

### `.addChild(param)`
Creates a new instance from by passing `param` to the `tack()` factory, and adds it to the instance's children.

### `.childAt(Number index)`
Returns the child at `index` in an instance's children.

### `.render()`
Builds the corresponding HTML for an instance (recursively calling render as appropriate on each child).

### `.create()`
Creates a DOM node from an instance.

### `.clone()`
Returns a new deep copy (i.e. children are recursively copied) of an instance.

## Static Methods

### `.extend(Object methods)`
Extends `Tack.prototype` with `methods`.
