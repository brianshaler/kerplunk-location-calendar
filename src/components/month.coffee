_ = require 'lodash'
React = require 'react'
moment = require 'moment'
ReactiveData = require 'reactive-data'

Box = require './box'

{DOM} = React

module.exports = React.createFactory React.createClass
  getInitialState: ->
    monthKey = @props.monthKey

    start = moment
      .utc("#{@props.monthKey}-01")
      .toDate()
      .getTime()
    end = moment
      .utc("#{@props.monthKey}-01")
      .add month: 1
      .toDate()
      .getTime()
    if end > Date.now()
      date = new Date()
      end = moment.utc([
        date.getFullYear()
        date.getMonth()
        date.getDate()
      ]).toDate().getTime()

    start: start
    end: end
    month: @props.store.getFromList 'calendar', (item) ->
      start <= item.time < end
    # month: month = _.filter data, (day) =>
    #   @props.monthKey == day.moment.format 'YYYY-MM'

  updateCalendar: (data) ->
    @setState
      month: data

  componentDidMount: ->
    @props.store.requestRange @state.start, @state.end
    @props.store.addFilterListener @updateCalendar, (item) =>
      @state.start <= item.time < @state.end

  componentWillUnmount: ->
    @props.store.removeListener @updateCalendar

  render: ->
    empties = []
    days = _.filter @state.month, (day) =>
      @state.start <= day.time < @state.end
    dow = parseInt moment.utc("#{@props.monthKey}-01").format('d')
    for i in [1..dow] by 1
      empties.push Box
        key: "calendar-empty-#{@props.monthKey}-#{i}"

    DOM.div
      key: "month-#{@props.monthKey}"
      className: 'month col-xs-4 col-md-4 col-lg-3'
    ,
      DOM.h3 null, moment.utc(@props.monthKey+'-01').format('MMMM YYYY')
      DOM.div
        className: 'calendar-days'
        style:
          maxWidth: 7 * 13
          height: 6 * 13
      , [empties].concat _.map days, (day) =>
        Box _.extend {}, @props,
          key: "calendar-#{day.formatted}"
          day: day
          onSelectDate: @props.onSelectDate
