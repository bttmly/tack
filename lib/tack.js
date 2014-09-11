!function(e){if("object"==typeof exports&&"undefined"!=typeof module)module.exports=e();else if("function"==typeof define&&define.amd)define([],e);else{var f;"undefined"!=typeof window?f=window:"undefined"!=typeof global?f=global:"undefined"!=typeof self&&(f=self),f.tack=e()}}(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var Tack, TackText, buildFromDomNode, defaults, each, extend, map, normalizeTextNode, reduce, remove, selfClosingTags, tack, tags,
  __slice = [].slice,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

tags = "a abbr address article aside audio b bdi bdo blockquote body button canvas caption cite code colgroup datalist dd del details dfn dialog div dl dt em fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header html i iframe ins kbd label legend li main map mark menu meter nav noscript object ol optgroup option output p pre progress q rp rt ruby s samp script section select small span strong style sub summary sup table tbody td textarea tfoot th thead time title tr u ul var video area base br col command embed hr img input keygen link meta param source track wbr".split(/\s+/).reduce(function(tags, tag) {
  tags[tag] = true;
  return tags;
}, Object.create(null));

selfClosingTags = "area base br col command embed hr img input keygen link meta param source track wbr".split(/\s+/).reduce(function(selfClosingTags, tag) {
  selfClosingTags[tag] = true;
  tags[tag] = true;
  return selfClosingTags;
}, Object.create(null));

map = Function.prototype.call.bind(Array.prototype.map);

each = Function.prototype.call.bind(Array.prototype.forEach);

reduce = Function.prototype.call.bind(Array.prototype.reduce);

remove = function(arr, item) {
  var i;
  i = arr.indexOf(item);
  while (i > -1) {
    arr.splice(i, 1);
    i = arr.indexOf(item);
  }
  return arr;
};

defaults = function() {
  return {
    attributes: {},
    classes: [],
    children: []
  };
};

extend = function() {
  var obj, objs, prop, target, _i, _len;
  target = arguments[0], objs = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
  for (_i = 0, _len = objs.length; _i < _len; _i++) {
    obj = objs[_i];
    for (prop in obj) {
      target[prop] = obj[prop];
    }
  }
  return target;
};

normalizeTextNode = function(node) {
  if (node.nodeType === 3) {
    return node.textContent = node.textContent.replace(/↵/g, "\n").trim();
  }
};

buildFromDomNode = function(node) {
  var opts;
  opts = {
    attributes: {}
  };
  if (node.nodeType === 3) {
    return new TackText(node.textContent);
  } else if (node.nodeType === 1) {
    each(node.attributes, function(attr) {
      if (attr.name === "class") {
        return opts.classes = attr.value.split(" ");
      } else {
        return opts.attributes[attr.name] = attr.value;
      }
    });
    opts.tagName = node.tagName.toLowerCase();
    opts.children = reduce(node.childNodes, function(acc, node) {
      normalizeTextNode(node);
      if (node.nodeType === 1 || node.textContent) {
        acc.push(buildFromDomNode(node));
      }
      return acc;
    }, []);
    return new Tack(opts);
  }
};

TackText = (function() {
  function TackText(str) {
    this.text = str;
  }

  TackText.prototype.render = function() {
    return this.text;
  };

  TackText.prototype.toString = function() {
    return this.text;
  };

  return TackText;

})();

Tack = (function() {
  Tack.fromNode = buildFromDomNode;

  function Tack(param) {
    if (typeof param === "string") {
      if (!tags[param]) {
        throw new Error("Invalid tag name.");
      }
      extend(this, defaults(), {
        tagName: param
      });
    } else if (param instanceof Element) {
      extend(this, defaults(), buildFromDomNode(param));
    } else {
      extend(this, defaults(), param);
    }
    if (typeof this.classes === "string") {
      this.classes = this.classes.split(" ");
    }
  }

  Tack.prototype.id = function(id) {
    if (id != null) {
      this.attributes.id = id;
      return this;
    } else {
      return this.attributes.id;
    }
  };

  Tack.prototype.attr = function(name, value) {
    if (value != null) {
      this.attributes[name] = value;
      return this;
    } else {
      return this.attributes[name];
    }
  };

  Tack.prototype.removeAttr = function(name) {
    delete this.attributes[name];
    return this;
  };

  Tack.prototype.addClass = function(className) {
    if (__indexOf.call(this.classes, className) < 0) {
      this.classes.push(className);
    }
    return this;
  };

  Tack.prototype.removeClass = function(className) {
    remove(this.classes, className);
    return this;
  };

  Tack.prototype.hasClass = function(className) {
    return this.classes.indexOf(className) !== -1;
  };

  Tack.prototype.toggleClass = function(className) {
    if (this.hasClass(className)) {
      return this.removeClass(className);
    } else {
      return this.addClass(className);
    }
  };

  Tack.prototype.addChild = function(param) {
    this.children.push(tack(param));
    return this;
  };

  Tack.prototype.childAt = function(index) {
    return this.children[index];
  };

  Tack.prototype.removeChildAt = function(index) {
    this.children.splice(index, 1);
    return this;
  };

  Tack.prototype.addText = function(str) {
    this.children.push(new TackText(str));
    return this;
  };

  Tack.prototype.render = function() {
    var attr, attrs, child, result, str, _i, _j, _len, _len1, _ref;
    result = [];
    str = "";
    result.push("<" + this.tagName + " ");
    if (this.classes.length) {
      result.push("class=\"" + (this.classes.join(" ")) + "\" ");
    }
    attrs = Object.keys(this.attributes).sort();
    for (_i = 0, _len = attrs.length; _i < _len; _i++) {
      attr = attrs[_i];
      str += "" + attr + "=\"" + this.attributes[attr] + "\" ";
    }
    result.push(str.trim());
    result.push(">");
    if (!selfClosingTags[this.tagName]) {
      if (this.children.length) {
        _ref = this.children;
        for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
          child = _ref[_j];
          result.push(child.render());
        }
      }
      result.push("</" + this.tagName + ">");
    }
    return result.join("");
  };

  Tack.prototype.toString = function() {
    return this.render();
  };

  Tack.prototype.create = function() {
    var attr, cl, el, _i, _len, _ref;
    el = document.createElement(this.tagName);
    for (attr in this.attributes) {
      el.setAttribute(attr, this.attributes[attr]);
    }
    _ref = this.classes;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      cl = _ref[_i];
      el.classList.add(cl);
    }
    el.innerHTML = this.children.map(function(child) {
      return child.render();
    }).join("");
    return el;
  };

  Tack.prototype.clone = function() {
    return new Tack(this);
  };

  return Tack;

})();

tack = function(param) {
  return new Tack(param);
};

module.exports = tack;



},{}]},{},[1])(1)
});