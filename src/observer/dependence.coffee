###
 * add dependence between observers and watchers
 * @author jackieLin <dashi_lin@163.com>
###

'use strict'

module.exports = class Dependence
    constructor: ->
        @.subsMap = {}
        @.subs = []
    
    ###
     * add watcher without repeat
    ###
    addSub: (sub) ->
        if not @.subsMap[sub.id]
            @.subs.push sub
            @.subsMap[sub.id] = sub
    
    removeSub: (sub) ->
        @.subs.$remove sub
        delete @.subsMap[sub.id]

    depend: ->
        @.addSub Dependence.target
    
    ###
     * exec add watchers
    ###
    notify: ->
        @.subs.forEach (v, i) ->
            v.update()

###
 * every component has one target watcher every time
###
Dependence.target = null