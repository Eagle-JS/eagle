###
 * js common method
 * @author jackieLin <dashi_lin@163.com>
###
'use strict'

###
 * Object.hasOwnProperty profilly
###
exports.hasOwn = (obj, key) ->
    Object.hasOwnProperty.call obj, key


###
 * define obj attr
###
exports.def = (obj, key, val, enumerable) ->
    Object.defineProperty obj, key,
        value: val
        enumerable: !!enumerable
        writable: true
        configurable: true


###
 * flatten Array
###
exports.flatten = (array=[]) ->
    newArray = []
    array.forEach (v, i) ->
        if not Array.isArray v
            newArray.push v 
        else
            v.forEach (item) ->
                newArray.push item
    
    newArray

exports.hasProto = '__proto__' in {}