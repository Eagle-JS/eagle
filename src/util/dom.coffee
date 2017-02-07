###
 * dom
 * @author jackieLin <dashi_lin@163.com>
###
'use strict'

###
 * @param oldEl {Dom}
 * @param newEl {Dom}
 * replace oldEl to newEl
###
exports.replaceWith = (newEl, oldEl) ->
    return if not newEl or not oldEl
    parentNode = oldEl.parentNode
    parentNode.replaceChild newEl, oldEl


###
 * @param el            {Dom}
 * @param htmlString    {String}
 * html function
###
exports.html = (el, htmlString) ->
    return if not el or not htmlString
    el.innerHTML = htmlString
    el