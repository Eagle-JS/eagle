###
 * 延迟队列
 * @author jackieLin <dashi_lin@163.com>
###

'use strict'

{ common } = require '../util/index.coffee'
nextTick = common.nextTick

queue = []
queueIds = {}
waiting = false

###
 * id 是否在队列里面
###
isInQueue = (id) ->
    queueIds[id]


flushBatcherQueue = () ->
    runBatcherQueue queue
    resetBatcherState()


resetBatcherState = () ->
    queue = []
    queueIds = {}
    waiting = false


###
 * run batch queue
 * @param queue
###
runBatcherQueue = (queue = []) ->
    queue.forEach (v, i) ->
        id = v.id
        queueIds[id] = null
        try
            v.run()
        catch err
            console.warn "Watcher id #{id} error. #{ err.stack() }"


###
 * push watcher item
###
exports.pushWatcher = (watcher = {}) ->
    id = watcher.id
    # 新的 watcher
    if not isInQueue id
        queueIds[id] = true
        queue.push watcher
        if not waiting
            waiting = true
            nextTick flushBatcherQueue
