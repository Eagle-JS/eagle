###
 * parse text
 * eg: 'hello {{message}}' => 'hello ( message )'
 * @author jackieLin <dashi_lin@163.com>
###
'use strict'

tagRE = /\{\{((?:.|\\n)+?)\}\}/g

module.exports = (text) ->
    return null if not tagRE.test text
    tokens = []
    index = lastIndex = tagRE.lastIndex = 0

    while match = tagRE.exec text
        index = match.index

        # first match
        tokens.push JSON.stringify text.slice lastIndex, index if index > lastIndex

        value = match[1]
        tokens.push "( #{ match[1].trim() })"
        lastIndex = index + match[0].length
    
    # last match
    tokens.push JSON.stringify text.slice lastIndex if lastIndex < text.length

    tokens.join '+'