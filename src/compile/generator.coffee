###
 * 解析 eagle 指令，生成代码
 * @author jackieLin <dashi_lin@163.com>
###

'use strict'

parseText = require './text-parse.coffee'
{ flatten } = require '../util/common.coffee'

onReg = /e-on:([^=]+)/

generator = 
    ###
     * el dom element
     * key dom key unique
    ###
    element: (el, key) ->
        if exp = @.getAttr el, 'e-for'
            return @.loop el, exp
        else if exp = @.getAttr el, 'e-if'
            return @.condition el, exp.trim()
        else
            # generate vdom
            return "__h__( '#{el.tag}', #{this.attrs(el)}, #{ this.children(el.children, el) })"

    ###
     * get element attr
    ###
    getAttr: (el, attr='') ->
        el.attrsMap = el.attrsMap or {}

        val = el.attrsMap[attr]
        # delete for avoid Infinite loop
        delete el.attrsMap[attr]
        val
    
    ###
     * generator all other attrs
    ###
    generateAllAttrs: (el, prefix) ->
        # eventMap = {}
        attributes = []

        keys = Object.keys(el.attrsMap).filter (v, i) ->
            v.indexOf(prefix) >= 0

        result = keys.reduce (prev, next) ->
            exp = next.match(onReg)

            if exp and exp.length is 2
                prev.push "'ev-#{ exp[1] }': events.#{ el.attrsMap[next] }"
            else if next.indexOf("#{ prefix }data") >= 0
                attributes.push "'#{ next.replace(prefix, '') }': #{ el.attrsMap[next] }"
            else
                prev.push "'#{ next.replace(prefix, '') }': #{ el.attrsMap[next] }"
            prev
        , []

        keys.map (v, i) ->
            delete el.attrsMap[v]

        {
            html: result
            attr: attributes
        }

    ###
     * generator dom attrs
    ###
    attrs: (el) ->
        return '{}' if not el
        attributes = []
        result = '{'
        # add class support
        if (exp = @.getAttr(el, 'e-class')) or el.attrsMap.class
            attributes.push "className: _renderClass(#{ exp or '\'\'' }, '#{ el.attrsMap.class or '' }')"
        
        directive = @.generateAllAttrs el, 'e-'
        attributes.push directive.html

        # result += directive.html

        # remain attribute
        attributes.push Object.keys(el.attrsMap).map (v, i) ->
            message = ''
            # html for should change htmlFor
            # @wiki https://github.com/Matt-Esch/virtual-dom/issues/278
            if v is 'for'
                message = "htmlFor: '#{ el.attrsMap[v] }'"
            else
                message = "'#{ v }': '#{ el.attrsMap[v] }'"
            message
        
        # flatten
        attributes = flatten attributes

        result += attributes.join ','
        
        result += ',' if result.length isnt 1 and directive.attr.length
        result += "attributes: { #{ directive.attr } }" if directive.attr.length

        result += '}'
        # console.info result
        result

    ###
     * generator children
    ###
    children: (children, parent) ->
        return if not Array.isArray children
        # console.info "[ #{ @.parseText parent.text } ]"
        return "[ #{ @.parseText parent.text } ]" if not children.length and parent
        "[#{ children.map(@.node).join ',' }]"

    
    ###
     * parse text
    ###
    parseText: (text) ->
        return '' if not text
        result = parseText text
        return "'#{ text }'" if not result
        result

    ###
     * generator node
    ###
    node: (node) ->
        generator.element node if node.tag

    ###
     * if directive
    ###
    condition: (el, exp) ->
        "(#{ exp }) ? #{ this.element(el) } : ''"

    ###
     * for directive
     * (item, index) in list || item in index
    ###
    loop: (el, exp) ->
        inMatch = exp.match /\(?([\w]*)\s*,?\s*([\w]*)\)?\s+(?:in|of)\s+(.*)/

        if not inMatch
            throw new Error 'Invalid v-for expression: #{exp}'
        
        list = inMatch[3].trim()
        index = inMatch[2].trim() || 'ix'
        item = inMatch[1].trim()
        key = el.attrsMap['key'] || 'undefined'

        "(#{list}).map(function(#{item}, #{index}) { return #{this.element(el, key)} })"

###
 * 将 ast 树生成 vdom 字符串
###
module.exports = (ast) ->
    if not ast
        return
    
    # console.log ast
    code = generator.element ast
    new Function "with(this) { return #{code} }"