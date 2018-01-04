React = require 'react'

DateRange = require './components/DateRange'
Header = require './components/Header'
Legend = require './components/Legend'
MapOverlay = require './components/MapOverlay'
MonthButtons = require './components/MonthButtons'
MonthLabels = require './components/MonthLabels'

dayStrToDate = require './calendar/dayStrToDate'
dateToDayStr = require './calendar/dateToDayStr'
Days = require './calendar/days'
Month = require './calendar/month'
setupMonths = require './calendar/setupMonths'
Map = require './map/Map'
Places = require './places'
cleanPlaceName = require './places/cleanPlaceName'
getLegend = require './places/getLegend'
getSummaryMap = require './places/getSummaryMap'
setupWebGL = require './webgl/setup'
renderGL = require './webgl/render'
patternTexture = require './webgl/patternTexture'

DateRange = React.createFactory DateRange
Header = React.createFactory Header
Legend = React.createFactory Legend
MapOverlay = React.createFactory MapOverlay
MonthButtons = React.createFactory MonthButtons
MonthLabels = React.createFactory MonthLabels

animate = false
# slowAnimate = true

# animate = true
slowAnimate = false

today = new Date()

{DOM} = React

module.exports = React.createFactory React.createClass
  getInitialState: ->
    startDate = new Date(new Date().getFullYear(), 0, 1)
    # startDate = new Date(2017, 11, 1)
    # startDate = new Date(2011, 0, 1)
    endDate = new Date(Math.min(today, new Date(2017, 12, 0)))

    initialViewState = [1, 0, 0]

    allDays: []
    animationStart: 0
    canvasHeight: 200
    canvasWidth: 200
    config:
      height: 1
      lastActivity: Date.now()
      legendColumns: 40
      monthColumns: 6
      pageMargin: [70, 50, 50, 50]
      patternSize: 8
      pixelRatio: window.devicePixelRatio
      sideLabelMax: 20
      squareMargin: 5
      squareSize: 24
      textHeight: 32
      width: 1
    endDate: endDate
    height: 100
    placeKey: 'city'
    movements: []
    places: new Places()
    previousState: initialViewState
    startDate: startDate
    # store: Store
    #   name: 'calendar'
    #   request: @props.request
    #   endpoint: '/location/get.json'
    #   # fetch: @onFetch
    #   lists: [{key: 'time', name: 'calendar'}]
    summaryMap:
      dayProps: []
      mapLabels: {}
    summaryLegend:
      dayProps: []
      legendLabels: {}
    targetState: initialViewState
    width: 100

  componentDidMount: ->
    { config, endDate, startDate } = @state

    @_resize = =>
      @resize()

    window.addEventListener 'resize', @_resize

    viz = setupWebGL @refs.canvas
    @viz = viz

    map = Map viz.regl
    viz.drawBG = map.draw
    viz.bgTexture = map.bgTexture

    viz.months = []
    setupMonths viz.regl, viz.months, startDate, endDate, config

    viz.monthLegend = Month viz.regl, new Date(), config

    {texture, textureCount} = patternTexture viz.regl
    viz.texture = texture
    viz.textureCount = textureCount

    @resize()
    @draw()

    @updateDateRange(new Date(today.getFullYear(), 0, 1), today)

    # @updateData travel2017.slice(0, 1)

    # setTimeout =>
    #   @resize()
    #   @updateData travel2017
    #   # @updateData([].concat(travel2017, travel2016, travel2015, travel2014, travel2013, travel2012, travel2011))
    # , 1

    # setTimeout () =>
    #   @updateDateRange(new Date(2016, 0, 1), @state.endDate)
    #   @updateData(travel2016)
    # , 2500
    #
    # setTimeout () =>
    #   @updateDateRange(new Date(2017, 0, 1), @state.endDate)
    # , 4000

    if slowAnimate
      setInterval =>
        @setState
          time: Date.now()
      , 400

  componentWillUnmount: ->
    window.removeEventListener 'resize', @_resize

  componentDidUpdate: ->
    @draw()

  updateConfig: (newConfig, state=@state) ->
    { allDays, endDate, places, startDate } = state
    viz = @viz

    config = Object.assign({}, @state.config, newConfig)

    summaryLegend = getLegend allDays, places, config, state.placeKey

    # console.log('updateConfig getSummaryMap')
    summaryMap = getSummaryMap Object.assign({}, state, {config})

    setupMonths(viz.regl, viz.months, startDate, endDate, config)
    viz.months.forEach (month) ->
      month.updateLegendPosition summaryLegend.dayProps
      month.updateMapPosition summaryMap.dayProps
      month.updateColors summaryLegend.dayProps

    @viz.monthLegend.setConfig config
    @viz.monthLegend.updateLegendPosition summaryLegend.dayProps
    @viz.monthLegend.updateColors summaryLegend.dayProps

    @setState {
      config: config
      summaryLegend: summaryLegend
      summaryMap: summaryMap
    }

    Object.assign({}, state, {
      config,
      summaryLegend,
      summaryMap,
    })

  updateDateRange: (startDate, endDate) ->
    { config } = @state
    viz = @viz

    setupMonths viz.regl, viz.months, startDate, endDate, config
    @viz.monthLegend.setConfig config

    if !@everLoaded
      @everLoaded = {}

    startYear = startDate.getFullYear()

    data = []
    if !@everLoaded[startYear] && startYear == endDate.getFullYear()
      # partial year?
      @everLoaded[startYear] = true
      @fetchData startYear, endDate
    if !@everLoaded[startYear] && startYear + 1 == endDate.getFullYear()
      # one year
      @everLoaded[startYear] = true
      @fetchData new Date(startYear, 0, 1), new Date(startYear + 1, 0, 1)
    else
      # multiple years
      for year in [startYear...endDate.getFullYear()]
        if !@everLoaded[year]
          @everLoaded[year] = true
          @fetchData new Date(year, 0, 1), new Date(year + 1, 0, 1)

    # newState = @updateData data, startDate, endDate
    # @resize Object.assign({}, @state, newState)

  fetchData: (startDate, endDate) ->
    url = '/location/get.json'
    options =
      from: dateToDayStr startDate
      to: dateToDayStr endDate
    @props.request.get url, options, (err, data) =>
      newState = @updateData data

  updateData: (data, startDate=@state.startDate, endDate=@state.endDate) ->
    newMovements = data.map (movement) ->
      on: dayStrToDate(movement.on),
      from: Object.assign({}, movement.from_location, {name: cleanPlaceName(movement.from)}),
      to: Object.assign({}, movement.to_location, {name: cleanPlaceName(movement.to)}),

    movements = @state.movements.concat newMovements
    movements.sort (a, b) -> if a.on > b.on then 1 else -1

    lastMovement = movements[0]
    allDays = Days startDate, endDate

    allDays.forEach (day) ->
      # if day.d < firstDate
      #   day.placeName = lastMovement.to
      #   return
      movement = lastMovement
      movements.find (m) ->
        if m.on <= day.d
          movement = m
        m.on > day.d

      lastMovement = movement

      placeProps
      placeProps = if movement.on > day.d
        movement.from
      else
        movement.to

      place = @state.places.getPlace placeProps
      day.city = place.city
      day.country = place.country

    newState =
      allDays: allDays
      endDate: endDate
      lastActivity: Date.now()
      movements: movements
      startDate: startDate

    summaryLegend = getLegend(allDays, @state.places, @state.config, @state.placeKey)

    # console.log('updateData getSummaryMap')
    summaryMap = getSummaryMap(Object.assign({}, @state, newState))

    newState.summaryLegend = summaryLegend
    newState.summaryMap = summaryMap

    @viz.months.forEach (month) ->
      month.updateLegendPosition summaryLegend.dayProps
      month.updateMapPosition summaryMap.dayProps
      month.updateColors summaryLegend.dayProps

    @viz.monthLegend.setConfig(@state.config)
    @viz.monthLegend.updateLegendPosition(summaryLegend.dayProps)
    @viz.monthLegend.updateColors(summaryLegend.dayProps)

    @setState(newState)
    @deselectMonth(true)
    @resize(Object.assign({}, @state, newState))
    return newState

  selectMonth: (month) ->
    {
      config,
      endDate,
      startDate,
    } = @state

    {
      monthColumns,
      pageMargin,
      squareMargin,
      squareSize,
      textHeight,
    } = config

    currentMonths = ((@viz?.months) || []).filter (m) -> m.getDate() >= startDate && m.getDate() < endDate
    vizMonth = @viz.monthLegend
    _monthDays = month.getDays()
    monthDays = @state.allDays.filter (day) ->
      _monthDays.find (d) -> d.key == day.key
    monthLegend = getLegend(monthDays, @state.places, @state.config, @state.placeKey)
    vizMonth.setMonth(month.getDate())

    index = currentMonths.findIndex (m) -> m == month
    calMonthRow = Math.floor(index / monthColumns)
    calMonthCol = index - calMonthRow * monthColumns

    calMonthX = pageMargin[1] + calMonthCol * (squareSize + squareMargin) * 8
    calMonthY = pageMargin[0] + calMonthRow * (squareSize + squareMargin) * 7.5 + textHeight

    vizMonth.updateCalendarPosition(calMonthX, calMonthY)

    vizMonth.setConfig(@state.config)
    vizMonth.updateLegendPosition(monthLegend.dayProps)
    vizMonth.updateColors(monthLegend.dayProps)

    @setState({
      lastActivity: Date.now(),
      deselectedMonthAt: 0,
      deselectedMonth: null,
      selectedMonthAt: Date.now(),
      selectedMonth: month,
      monthLegend,
    })

  deselectMonth: (force=false) ->
    if force or !@state.selectedMonth
      @setState
        deselectedMonth: null
        deselectedMonthAt: 0
        lastActivity: Date.now()
        selectedMonth: null
        selectedMonthAt: 0
      return

    @setState
      deselectedMonth: @state.selectedMonth
      deselectedMonthAt: Date.now()
      lastActivity: Date.now()
      selectedMonth: null
      selectedMonthAt: 0

  resize: (state=@state) ->
    {
      endDate,
      startDate,
    } = state

    {
      pageMargin,
      pixelRatio,
    } = state.config

    scaledWidth = (window.innerWidth - 15) * pixelRatio
    onscreenHeight = (window.innerHeight - 56) * pixelRatio - pageMargin[0] - pageMargin[2]
    availableWidth = scaledWidth - pageMargin[1] - pageMargin[3]
    # height = window.innerHeight - 40

    currentMonths = ((@viz && @viz.months) || []).filter((m) -> m.getDate() >= startDate && m.getDate() < endDate)
    xSplits = 1
    ySplits = 1
    calAspect = 7 / 8.5

    while xSplits * ySplits < currentMonths.length
      cellWidth = availableWidth / xSplits
      cellHeight = onscreenHeight / ySplits
      cellAspect = cellWidth / cellHeight
      if cellAspect > calAspect
        xSplits++
      else
        ySplits++
    # console.log('resize', xSplits, 'columns,', ySplits, 'rows')

    monthColumns = Math.min(12, xSplits, Math.ceil(availableWidth / 240))
    dayColumns = monthColumns * 7 + (monthColumns - 1)
    squareAvailableSize = Math.floor(availableWidth / dayColumns)
    squareSize = Math.floor(squareAvailableSize * 6 / 7 / 2) * 2
    squareMargin = squareAvailableSize - squareSize
    patternSize = squareSize / 3
    legendColumns = Math.floor(availableWidth / squareAvailableSize)

    newState = @updateConfig({
      height: onscreenHeight,
      legendColumns,
      monthColumns,
      patternSize,
      sideLabelMax: legendColumns - 14,
      squareMargin,
      squareSize,
      textHeight: squareSize,
      width: availableWidth,
    }, state)

    maxLegendY = 0
    newState.summaryLegend.dayProps.forEach ({legendPosition}) ->
      if maxLegendY < legendPosition[1]
        maxLegendY = legendPosition[1]
    maxLegendY += squareSize + pageMargin[2]

    # console.log('resizing', window.innerHeight, maxLegendY / pixelRatio)
    height = Math.max(onscreenHeight, maxLegendY) / pixelRatio

    @setState({
      width: window.innerWidth,
      height: height,
      canvasWidth: window.innerWidth * pixelRatio,
      canvasHeight: height * pixelRatio,
    })

    requestAnimationFrame () =>
      @viz.regl._refresh()
      @draw()

  draw: ->
    cancelAnimationFrame(@raf)

    renderGL(@viz, @state, (newState) => @setState(newState))

    if animate or @state.lastActivity > Date.now() - 2000
      @raf = requestAnimationFrame(@draw.bind(this))

  showView: (viewId) ->
    targetState = [0, 0, 0]
    targetState[viewId] = 1
    @setState
      lastActivity: Date.now(),
      previousState: @state.targetState
      targetState: targetState
      animationStart: Date.now()
    @deselectMonth true

  changePlaceKey: (placeKey) ->
    @setState({
      hideLabels: true,
    })
    setTimeout =>
      @setState
        placeKey: placeKey
      setTimeout =>
        @updateData []
        setTimeout =>
          @setState
            hideLabels: false
        , 1
      , 1
    , 1

  render: ->
    {
      endDate,
      startDate,
    } = @state

    currentMonths = ((@viz && @viz.months) || []).filter(m => m.getDate() >= startDate && m.getDate() < endDate)

    DOM.div null,
      DOM.div
        className: 'view-nav'
      ,
        DOM.div
          className: "main-nav #{if @state.showDatePicker then 'hidden' else 'showing'}"
        ,
          DOM.div
            className: 'nav-content'
          ,
            DOM.a
              href: '#'
              className: if @state.targetState[0] == 1 then 'selected' else ''
              onClick: (e) =>
                e.preventDefault()
                @showView(0)
            , 'Calendar'
            DOM.span null, ' '
            DOM.a
              href: '#'
              className: if @state.targetState[1] == 1 then 'selected' else ''
              onClick: (e) =>
                e.preventDefault()
                @showView(1)
            , 'Legend'
            DOM.span null, ' '
            DOM.a
              href: '#'
              className: if @state.targetState[2] == 1 then 'selected' else ''
              onClick: (e) =>
                e.preventDefault()
                @showView(2)
            , 'Map'
            DOM.span
              style:
                display: if @state.placeKey == 'city' then 'none' else null
            ,
              DOM.span null, ' '
              DOM.a
                href: '#'
                onClick: (e) =>
                  e.preventDefault()
                  @changePlaceKey('city')
              , 'By City'
            DOM.span
              style:
                display: if @state.placeKey == 'country' then 'none' else null
            ,
              DOM.span null, ' '
              DOM.a
                href: '#'
                onClick: (e) =>
                  e.preventDefault()
                  @changePlaceKey('country')
              , 'By Country'
            DOM.span null, ' '
            DOM.a
              href: '#'
              onClick: (e) =>
                e.preventDefault()
                @setState
                  showDatePicker: true
            , 'Date Range'
        DOM.div
          className: "date-picker #{if @state.showDatePicker then 'showing' else 'hidden'}"
        ,
          DOM.div
            className: 'nav-content'
          ,
            DOM.div
              className: 'content-left'
            ,
              DateRangeFactory
                endDate: endDate
                label: 'All Time'
                onSelect: @updateDateRange.bind(this)
                selectionEnd: new Date(Math.min(today, new Date(2017, 12, 0)))
                selectionStart: new Date(2011, 0, 1)
                startDate: startDate
              DOM.span null, ' '
              DateRangeFactory
                endDate: endDate
                label: 'This Year'
                onSelect: @updateDateRange.bind(this)
                selectionEnd: new Date(new Date().getFullYear(), 12, 0)
                selectionStart: new Date(new Date().getFullYear(), 0, 1)
                startDate: startDate
              DOM.span null, ' '
              DateRangeFactory
                endDate: endDate
                label: 'Last Year'
                onSelect: @updateDateRange.bind(this)
                selectionEnd: new Date(new Date().getFullYear() - 1, 12, 0)
                selectionStart: new Date(new Date().getFullYear() - 1, 0, 1)
                startDate: startDate
              DOM.div
                style:
                  display: 'inline'
              ,
                Array(3).fill().map (_, i) =>
                  thisYear = new Date().getFullYear()
                  year = thisYear - 2 - i
                  selectionStart = new Date(year, 0, 1)
                  selectionEnd = new Date(year, 12, 0)
                  DOM.span
                    key: i
                  ,
                    DOM.span null, ' '
                    DateRangeFactory
                      endDate: endDate
                      label: year
                      onSelect: @updateDateRange.bind(this)
                      selectionEnd: selectionEnd
                      selectionStart: selectionStart
                      startDate: startDate
            DOM.div
              className: 'content-right'
            ,
              DOM.a
                href: '#'
                onClick: (e) =>
                  e.preventDefault()
                  @setState
                    showDatePicker: false
              , 'X'
      DOM.div
        style:
          position: 'absolute'
          # marginTop: '-10px'
          width: "#{@state.width}px"
          height: "#{@state.height}px"
      ,
        DOM.canvas
          ref: 'canvas'
          width: @state.canvasWidth
          height: @state.canvasHeight
          style:
            position: 'absolute'
            width: "#{@state.width}px"
            height: "#{@state.height}px"
        HeaderFactory
          endDate: @state.endDate
          hideLabels: @state.hideLabels
          placeKey: @state.placeKey
          selectedMonth: @state.selectedMonth
          startDate: @state.startDate
          summaryMap: @state.summaryMap
        if @state.hideLabels != true
          DOM.div null,
            LegendFactory
              config: @state.config
              legendShowing: @state.targetState[1] > 0
              monthLegend: @state.monthLegend
              placeKey: @state.placeKey
              selectedMonth: @state.selectedMonth
              summaryLegend: @state.summaryLegend
            MapOverlayFactory
              config: @state.config
              mapShowing: @state.targetState[2] > 0
              monthLegend: @state.monthLegend
              placeKey: @state.placeKey
              selectedMonth: @state.selectedMonth
              summaryMap: @state.summaryMap
        else
          null
        DOM.div
          style:
            # display: 'none',
            position: 'absolute'
            left: if @state.targetState[0] == 1 then '0px' else '-10000px'
        ,
          MonthLabelsFactory
            config: @state.config
            months: currentMonths
            selectedMonth: @state.selectedMonth
          MonthButtonsFactory
            config: @state.config
            months: currentMonths
            onSelect: (month) =>
              # if @state.selectedMonth and @state.selectedMonth != month
              #   return
              if @state.selectedMonth
                @deselectMonth()
                return
              @selectMonth month
            selectedMonth: @state.selectedMonth
