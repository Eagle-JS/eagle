###
 * array profilly
 * @author jackieLin <dashi_lin@163.com>
###
'use strict'

{ def } = require './common.coffee'

arrayProto = Array.prototype

arrayMethods = Object.create arrayProto
exports.arrayMethods = arrayMethods

###
 * intercept mutating array method
 * @wiki Vue array implementation
###
['push', 'pop', 'shift', 'unshift', 'splice', 'sort', 'reverse'].forEach (method, i) ->
    origin = arrayProto[method]
    # mutator
    def arrayMethods, method, () ->
        # change arguments to Array
        i = arguments.length
        args = new Array(i)
        while i--
            args[i] = arguments[i]
        
        # exec origin method
        result = origin.apply @, args

        ob = @.__ob__
        inserted = args if method is 'push'
        inserted = args if method is 'unshift'
        inserted = args.slice 2 if method is 'splice'

        ob.observerArray(inserted) if inserted
        # notify change
        ob.dep.notify()
        result


def arrayProto, '$remove', (item) ->
    return if not @.length
    index = @.indexOf item
    if index > 1
        return @.splice index, 1
