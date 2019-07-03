_ = require 'lodash'
React = require 'react'

Month = require './month'
Store = require './util/store'

{DOM} = React

module.exports = React.createFactory React.createClass
  getInitialState: ->
    store: Store
      name: 'calendar'
      request: @props.request
      endpoint: '/location/get.json'
      lists: [{key: 'time', name: 'calendar'}]

  render: ->
    return DOM.div() if typeof document == 'undefined'

    Month _.extend {}, @props,
      onSelectDate: (e) ->
        e.preventDefault()
        console.log 'whatcha gonna do'
      buildUrlForDate: (date) ->
        "/posts/day/#{date.moment.format 'YYYY/MM/DD'}"
      store: @state.store
