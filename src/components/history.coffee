_ = require 'lodash'
React = require 'react'
ReactiveData = require 'reactive-data'
moment = require 'moment'

CalendarComponent = require './calendar'
LegendComponent = require './legend'
SummaryComponent = require './summary'

YMD = require './util/ymd'
Store = require './util/store'
MonthPicker = require './interface/monthPicker'

{DOM} = React

DAY = 86400 * 1000

module.exports = React.createFactory React.createClass
  getInitialState: ->
    date = new Date()

    minDate: moment.utc([
        date.getFullYear() - 5
        0
        1
      ]).toDate()
    startDate: moment.utc([
        date.getFullYear()
        0
        1
      ]).toDate()
    endDate: moment.utc([
        date.getFullYear()
        date.getMonth()
        date.getDate()
      ]).toDate()
    calendar: {}
    selectedDate: false
    store: Store
      name: 'calendar'
      request: @props.request
      endpoint: '/location/get.json'
      # fetch: @onFetch
      lists: [{key: 'time', name: 'calendar'}]

  restoreState: ->
    savedState = localStorage?.getItem 'calendarState'
    obj = {}
    try
      obj = JSON.parse savedState
    catch ex
      return {}
    dateKeys = ['minDate', 'startDate', 'endDate']
    return {} if !obj?
    for key in dateKeys
      if obj[key]
        obj[key] = new Date obj[key]
    obj ? {}

  _setState: (obj) ->
    state = @restoreState()
    newState = _.merge state, obj
    if newState.calendar
      delete newState.calendar
    localStorage?.setItem 'calendarState', JSON.stringify newState
    return unless obj and Object.keys(obj).length > 0
    @setState obj

  componentDidMount: ->
    state = @restoreState()
    if state?
      state.minDate = moment.utc([(new Date()).getFullYear() - 4, 0, 1]).toDate()
    if state?.startDate
      @setState state

  updateStartDate: (e) ->
    e.preventDefault()
    @_setState
      startDate: new Date Date.parse e.target.value

  updateEndDate: (e) ->
    e.preventDefault()
    @_setState
      endDate: new Date Date.parse e.target.value

  jumpToRange: (range) ->
    (e) =>
      e.preventDefault()
      @_setState
        selectDateRange: false
        startDate: moment.utc(range.substring 0, 10).toDate()
        endDate: moment.utc(range.substring 13).toDate()

  onSelectDate: (date) ->
    # console.log 'date selected', date
    @_setState
      selectedDate: date

  render: ->
    startTime = @state.startDate.getTime()
    endTime = @state.endDate.getTime()
    days = _.filter @state.calendar, (day) ->
      startTime <= day.time <= endTime
    cities = _.groupBy days, (day) ->
      "#{day.location.city},#{day.location.region ? ''},#{day.location.country}"

    thisJan = "#{new Date().getFullYear()}-01-01"
    lastJan = "#{new Date().getFullYear() - 1}-01-01"

    startFormatted = moment.utc(@state.startDate)
      .format 'YYYY-MM-DD'
    endFormatted = moment.utc(@state.endDate)
      .format 'YYYY-MM-DD'

    today = moment.utc Date.now() + 86400000
      .format 'YYYY-MM-DD'

    selectedRange = "#{startFormatted} - #{endFormatted}"
    thisYear = "#{thisJan} - #{today}"
    thisYearSelected = thisYear == selectedRange
    lastYear = "#{lastJan} - #{thisJan}"
    lastYearSelected = lastYear == selectedRange
    otherSelected = !thisYearSelected and !lastYearSelected

    history = DOM.div null,
      DOM.div
        className: 'row'
      ,
        if !@state.selectDateRange
          DOM.div
            className: 'col-sm-12'
          ,
            DOM.a
              className: "btn btn-lg #{if thisYearSelected then 'btn-info' else 'btn-default'}"
              href: '#'
              onClick: @jumpToRange thisYear
            , 'This year'
            ' '
            DOM.a
              className: "btn btn-lg #{if lastYearSelected then 'btn-info' else 'btn-default'}"
              href: '#'
              onClick: @jumpToRange lastYear
            , 'Last year'
            ' '
            DOM.a
              className: "btn btn-lg #{if otherSelected then 'btn-info' else 'btn-default'}"
              href: '#'
              onClick: (e) =>
                e.preventDefault()
                @setState
                  selectDateRange: true
            , 'Other...'
        else
          DOM.div null,
            DOM.div
              className: 'col-sm-12'
            ,
              DOM.div null, 'Jump to date range:'
              _.map (i for i in [0..4]), (ago) =>
                start = "#{new Date().getFullYear() - ago}-01-01"
                end = if ago == 0
                  moment.utc Date.now() + 86400000
                    .format 'YYYY-MM-DD'
                else
                  "#{new Date().getFullYear() - ago + 1}-01-01"
                range = "#{start} - #{end}"
                DOM.div
                  key: "select-year-#{start}"
                ,
                  DOM.a
                    href: '#'
                    onClick: @jumpToRange range
                  , range
            DOM.div
              className: 'col-sm-6'
            ,
              MonthPicker
                name: 'startDate'
                minYMD: YMD.getUTCYMD @state.minDate.getTime()
                value: moment.utc(@state.startDate).format 'YYYY-MM-DD'
                onChange: @updateStartDate
            DOM.div
              className: 'col-sm-6'
            ,
              MonthPicker
                name: 'endDate'
                minYMD: YMD.getUTCYMD @state.minDate.getTime()
                maxYMD: YMD.getUTCYMD @state.endDate.getTime()
                value: moment.utc(@state.endDate).format 'YYYY-MM-DD'
                onChange: @updateEndDate
            DOM.div
              className: 'col-sm-12'
            ,
              DOM.a
                href: '#'
                onClick: (e) =>
                  e.preventDefault()
                  @setState
                    selectDateRange: false
              , 'cancel'


      DOM.div
        className: 'row'
      ,
        DOM.div
          className: 'months col-sm-6'
        ,
          CalendarComponent _.extend {}, @props,
            startDate: @state.startDate
            endDate: @state.endDate
            onSelectDate: @onSelectDate
            store: @state.store
          SummaryComponent _.extend {}, @props,
            cities: cities
            totalDays: days.length
            start: @state.startDate.getTime()
            end: @state.endDate.getTime()
            store: @state.store
        DOM.div
          className: 'months col-sm-6'
        ,
          LegendComponent _.extend
            start: @state.startDate.getTime()
            end: @state.endDate.getTime()
            # cities: cities
            totalDays: days.length
            onSelectDate: @onSelectDate
            store: @state.store
          , @props

    DOM.section
      className: 'content'
    ,
      history
      # if @state.selectedDate
      #   EditDayComponent _.extend {}, @props,
      #     key: "edit-#{@state.selectedDate.formatted}"
      #     date: @state.selectedDate.date
      #     dateKey: @state.selectedDate.formatted
      #     year: parseInt @state.selectedDate.moment.format 'YYYY'
      #     month: parseInt @state.selectedDate.moment.format 'MM'
      #     day: parseInt @state.selectedDate.moment.format 'DD'
      #     location: @state.selectedDate.location
      #     onClose: =>
      #       @_setState
      #         selectedDate: false
      # else
      #   history
