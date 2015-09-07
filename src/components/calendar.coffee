_ = require 'lodash'
React = require 'react'
moment = require 'moment'

Box = require './box'

{DOM} = React

module.exports = React.createFactory React.createClass
  render: ->
    months = _.map @props.months, (month, monthKey) =>
      empties = []
      dow = parseInt moment.utc(Date.parse "#{monthKey}-01").format('d')
      for i in [1..dow] by 1
        empties.push Box
          key: "calendar-empty-#{monthKey}-#{i}"

      DOM.div
        key: "month-#{monthKey}"
        className: 'month col-xs-4 col-md-4 col-lg-3'
      ,
        DOM.h3 null, moment(monthKey+'-01').format('MMMM YYYY')
        DOM.div
          className: 'calendar-days'
          style:
            maxWidth: 7 * 13
            height: 6 * 13
        , [empties].concat _.map month, (day) =>
          Box _.extend {}, @props,
            key: "calendar-#{day.formatted}"
            day: day
            onSelectDate: @props.onSelectDate

    DOM.div
      className: 'months'
      style:
        width: '100%'
    ,
      DOM.h2 null, 'Calendar'
      DOM.div
        className: 'row'
      , months
