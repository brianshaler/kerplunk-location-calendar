_ = require 'lodash'
moment = require 'moment'
React = require 'react'

YMD = require '../util/ymd'

{DOM} = React

module.exports = React.createFactory React.createClass
  getInitialState: ->
    d = new Date()
    minYMD: @props.minYMD ? [d.getFullYear(), 0, 1]
    maxYMD: @props.maxYMD ? [d.getFullYear(), d.getMonth() + 1, 1]

  render: ->
    range = YMD.monthRange @state.minYMD, @state.maxYMD
    maxTime = moment.utc YMD.getUTCYMD()
      .format 'X'
    maxTime = 86400 + parseInt maxTime
    options = _.map range, (YMD) =>
      date = moment.utc YMD
      time = parseInt date.format 'X'
      if time > maxTime
        date = moment.utc maxTime * 1000
      value = date.format 'YYYY-MM-DD'
      display = value
      DOM.option
        value: value
        key: "#{@props.name}-#{value}"
      , display

    DOM.select
      name: @props.name
      value: @props.value
      onChange: @props.onChange
    , options
