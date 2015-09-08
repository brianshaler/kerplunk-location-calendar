_ = require 'lodash'
React = require 'react'
ReactiveData = require 'reactive-data'
moment = require 'moment'

if window?
  window.momentjs = moment

CalendarComponent = require './calendar'
LegendComponent = require './legend'
SummaryComponent = require './summary'
#EditDayComponent = require './editDay'

{DOM} = React

DAY = 86400 * 1000

getUTCYMD = (time = Date.now()) ->
  [year, month, day] = moment.utc time
    .format 'YYYY-MM-DD'
    .split '-'
  [parseInt(year), parseInt(month)-1, parseInt(day)]

YMDtoString = (YMD = getUTCYMD()) ->
  moment.utc(YMD).format('YYYY-MM-DD')

YMDtoTime = (YMD) ->
  moment.utc(YMD).format('X') * 1000

tomorrow = (YMD) ->
  getUTCYMD 86400000 * 1.5 + moment.utc(YMD).format('X') * 1000

nextMonth = (YMD) ->
  d = new Date YMD[0], YMD[1] + 1, 1
  val = [d.getFullYear(), d.getMonth(), 1]
  val

dateRange = (minYMD, maxYMD) ->
  currentYMD = minYMD
  endTime = YMDtoTime maxYMD
  currentTime = YMDtoTime currentYMD
  range = []
  while currentTime < endTime and range.length < 100
    range.push currentYMD
    currentYMD = tomorrow currentYMD
    currentTime = YMDtoTime currentYMD
  range

monthRange = (minYMD, maxYMD) ->
  YMD = [minYMD[0], minYMD[1], 1]
  endTime = YMDtoTime maxYMD
  time = YMDtoTime YMD
  range = []
  while time < endTime and range.length < 100
    range.push YMD
    YMD = nextMonth YMD
    time = YMDtoTime YMD
  range

MonthPicker = React.createFactory React.createClass
  getInitialState: ->
    d = new Date()
    minYMD: @props.minYMD ? [d.getFullYear(), 0, 1]
    maxYMD: @props.maxYMD ? [d.getFullYear(), d.getMonth() + 1, 1]

  render: ->
    range = monthRange @state.minYMD, @state.maxYMD
    maxTime = moment.utc getUTCYMD()
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

module.exports = React.createFactory React.createClass
  getInitialState: ->
    minDate: new Date (new Date()).getFullYear() - 4, 0, 1
    startDate: new Date Date.parse YMDtoString([(new Date()).getFullYear(), 0, 1])
    endDate: new Date 86400000 + Date.parse YMDtoString()
    calendar: {}
    selectedDate: false

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
    if state?.startDate
      @setState state
    # console.log 'mounting with state', state
    @calendar = ReactiveData.Item
      key: 'calendar'
      Repository: @props.Repository
    @calendar.listen @, 'calendar'

    endDate = new Date Date.now() + DAY
    #startDate = new Date endDate.getFullYear() - 1, 0, 1
    minDate = @state.minDate
    from = moment.utc minDate
      .format 'YYYY-MM-DD'
    to = moment.utc endDate
      .format 'YYYY-MM-DD'

    url = '/location/get.json'
    options =
      from: from
      to: to

    # console.log url, options
    @props.request.get url, options, (err, data) =>
      return console.log err if err
      return console.log 'no data' unless data?.length > 0
      # console.log 'got data', data.length
      calendar = @props.Repository.getLatest('calendar') ? {}
      location = data[0].from_location
      index = 0
      for day in [minDate.getTime()..endDate.getTime()] by DAY
        today = new Date day
        m = moment.utc today
        formatted = m.format 'YYYY-MM-DD'
        if formatted == data[index]?.on
          index++
        location = data[index]?.from_location ? data[index - 1].to_location
        calendar[formatted] =
          location: location
          date: today
          moment: m
          time: today.getTime()
          formatted: formatted
        #console.log "Location on #{formatted}.. #{location.city}"
      @props.Repository.update 'calendar', calendar

  componentWillUnmount: ->
    @calendar.unlisten @

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
        startDate: new Date Date.parse range.substring 0, 10
        endDate: new Date Date.parse range.substring 13

  onSelectDate: (date) ->
    # console.log 'date selected', date
    @_setState
      selectedDate: date

  render: ->
    startTime = @state.startDate.getTime()
    endTime = @state.endDate.getTime()
    days = _.filter @state.calendar, (day) ->
      startTime <= day.time <= endTime
    months = _.groupBy days, (day) ->
      day.moment.format 'YYYY-MM'
    cities = _.groupBy days, (day) ->
      "#{day.location.city},#{day.location.region ? ''},#{day.location.country}"

    history = DOM.div null,
      DOM.div
        className: 'row'
      ,
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
            minYMD: [
              @state.minDate.getFullYear()
              @state.minDate.getMonth()
              @state.minDate.getDate()
            ]
            value: moment.utc(@state.startDate).format 'YYYY-MM-DD'
            onChange: @updateStartDate
        DOM.div
          className: 'col-sm-6'
        ,
          MonthPicker
            name: 'endDate'
            minYMD: [
              @state.minDate.getFullYear()
              @state.minDate.getMonth()
              @state.minDate.getDate()
            ]
            maxYMD: [
              @state.endDate.getFullYear()
              @state.endDate.getMonth() + 1
              @state.endDate.getDate()
            ]
            value: moment.utc(@state.endDate).format 'YYYY-MM-DD'
            onChange: @updateEndDate
      DOM.div
        className: 'row'
      ,
        DOM.div
          className: 'months col-sm-6'
        ,
          CalendarComponent _.extend {}, @props,
            months: months
            onSelectDate: @onSelectDate
          SummaryComponent _.extend {}, @props,
            cities: cities
            totalDays: days.length
        DOM.div
          className: 'months col-sm-6'
        ,
          LegendComponent _.extend
            cities: cities
            totalDays: days.length
            onSelectDate: @onSelectDate
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
