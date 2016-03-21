_ = require 'lodash'
React = require 'react'
moment = require 'moment'

Month = require './month'

{DOM} = React

DAY = 86400 * 1000

module.exports = React.createFactory React.createClass
  getInitialState: ->
    # calendar: @props.Repository.getLatest('kerplunk-location-calendar') ? {}
    months: []
    monthRequests: {}

  updateCalendar: (data) ->
    months = _.groupBy data, (day) ->
      day.moment.format 'YYYY-MM'
    months = _.map months, (month, monthKey) =>
      # month: month
      monthKey: monthKey
      key: monthKey
    @setState
      months: months

  componentDidMount: ->
    @unsub = @props.Repository.subscribe 'kerplunk-location-calendar', (data) =>
      @updateCalendar data

  componentWillUnmount: ->
    @unsub()

  render: ->
    startTime = @props.startDate.getTime()
    endTime = @props.endDate.getTime()
    month = moment.utc(startTime)
    monthCount = Math.ceil (endTime - startTime) / (28 * DAY)
    startMonth = moment.utc(startTime).format 'YYYY-MM'
    monthKeys = []
    while month.toDate() < endTime and monthKeys.length <= monthCount
      monthKeys.push month.format 'YYYY-MM'
      month.add 1, 'M'

    months = _.map monthKeys, (monthKey) =>
      Month _.extend {}, @props,
        key: monthKey
        monthKey: monthKey
        onSelectDate: @props.onSelectDate
        store: @props.store

    DOM.div
      className: 'months'
      style:
        width: '100%'
    ,
      DOM.h2 null, 'Calendar'
      DOM.div
        className: 'row'
      , months
