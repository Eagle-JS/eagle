###
 * Eagle Component
 * @author jackieLin <dashi_lin@163.com>
###

'use strict'

parser = require '../compile/index.coffee'
h = require 'virtual-dom/h'
createElement = require 'virtual-dom/create-element'
diff = require 'virtual-dom/diff'
patch = require 'virtual-dom/patch'
Delegator = require 'dom-delegator'
{ replaceWith, html } = require '../util/dom.coffee'
observer = require '../observer/index.coffee'
Watcher = require '../observer/watcher.coffee'

module.exports = class Component
    constructor: (@options) ->
        # option message change to this
        Object.keys(@.options).forEach (v) =>
            @[v] = @.options[v]

        @.el = document.querySelector @.options.el || 'body'

        # template exists, add to dom
        html @.el, @.options.template if @.options.template

        Object.keys(@.data).forEach (v, i) =>
            @.proxy v
        
        @.ob = observer @.data

        # events
        @.delegator = new Delegator()

        # generator render
        @.render = parser @.el.outerHTML
        # console.info @.render

        @.update @.render.call @

        @.watchers = []
        # vm watcher
        @.watcher = new Watcher @, @.render, @.update


    ###
     * patch vtree
    ###
    update: (vtree) ->
        # first time
        if not @._oldTree
            @.rootNode = createElement vtree
            replaceWith @.rootNode, @.el
        else
            patches = diff @._oldTree, vtree
            @.rootNode = patch @.rootNode, patches

        @._oldTree = vtree
    
    ###
     * add data key to component
    ###
    proxy: (key) ->
        Object.defineProperty @, key,
            configurable: true,
            enumerable: true,
            get: () =>
                @.data[key]
            set: (val) =>
                @.data[key] = val
    
    
    ###
     * renderClass
    ###
    _renderClass: (dynamic, cls) ->
        classes = '' if not cls
        classes = cls + ' ' if cls
        classes += Object.keys(dynamic).filter((v) -> dynamic[v]).join ' '
        classes
        
    __h__: h