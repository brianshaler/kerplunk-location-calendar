{ fragmentShader, vertexShader } = require './shaders'
Days = require './days'
Square = require '../webgl/square'

dayCols = 7
# squareSize = 24
# squareMargin = 5

maxDays = 31
monthNames = [
  'January'
  'February'
  'March'
  'April'
  'May'
  'June'
  'July'
  'August'
  'September'
  'October'
  'November'
  'December'
]

positionDays = (month) ->
  {
    squareMargin,
    squareSize,
  } = month.config

  month.days.forEach (day) ->
    calDaysBefore = month.date.getDay()
    calIndex = day.d.getDate() + calDaysBefore - 1

    calRow = Math.floor(calIndex / dayCols)
    calCol = calIndex - calRow * dayCols

    calX = (squareSize + squareMargin) * calCol
    calY = (squareSize + squareMargin) * calRow

    day.calX = calX
    day.calY = calY

setMonth = (month, date) ->
  startDate = date
  endDate = new Date(Math.min(new Date(), new Date(date.getFullYear(), date.getMonth() + 1, 0)))
  days = Days(startDate, endDate)
  key = "#{date.getFullYear()}-#{date.getMonth()}"

  month.key = key
  month.date = date
  month.days = days

updateCalendarPosition = (month, x=month.x, y=month.y) ->
  calendarPosition = new Array(maxDays).fill([-10000, -10000])
  month.x = x
  month.y = y
  positionDays(month)
  month.days.forEach (day, index) ->
    calendarPosition[index] = [month.x + day.calX, month.y + day.calY]
  month.updateBuffer('calendarPosition', calendarPosition)

updateLegendPosition = (month, days) ->
  legendPosition = new Array(maxDays).fill([-10000, -10000])
  month.days.forEach (day, index) =>
    newDay = days.find (d) => d.key == day.key
    return [0, 0] unless newDay
    legendPosition[index] = newDay.legendPosition
  month.updateBuffer('legendPosition', legendPosition)

updateMapPosition = (month, days) ->
  mapPosition = new Array(maxDays).fill([-10000, -10000])
  month.days.forEach (day, index) ->
    newDay = days.find (d) => d.key == day.key
    return [0, 0] unless newDay
    mapPosition[index] = newDay.mapPosition
  # console.log('month.updateBuffer mapPosition', mapPosition)
  month.updateBuffer('mapPosition', mapPosition)

updateColors = (month, days) ->
  color1 = []
  color2 = []
  textureId = []

  month.days.forEach (day, index) ->
    newDay = days.find (d) -> d.key == day.key
    unless newDay
      color1[index] = [1, 1, 1]
      color2[index] = [1, 1, 1]
      textureId[index] = 0
      return

    color1[index] = newDay.color1
    color2[index] = newDay.color2
    textureId[index] = newDay.textureId

  month.updateBuffer('color1', color1)
  month.updateBuffer('color2', color2)
  month.updateBuffer('textureId', textureId)

destroy = (month) -> null

square = Square 1
# console.log('square', square)

module.exports = Month = (regl, date, config) ->
  month =
    config: config
    regl: regl
    x: 0
    y: 0
    buffers: {}

  month.updateBuffer = (name, data) ->
    month.buffers[name].subdata(data)

  setMonth month, date

  addBuffer = (name, type, bytes) ->
    month.buffers[name] = regl.buffer
      length: maxDays * bytes
      type: type
      usage: 'dynamic'

  addBuffer 'color1', 'float', 12
  addBuffer 'color2', 'float', 12
  addBuffer 'calendarPosition', 'float', 8
  addBuffer 'legendPosition', 'float', 8
  addBuffer 'mapPosition', 'float', 8
  addBuffer 'textureId', 'uint8', 1
  addBuffer 'tOffset', 'float', 4

  tOffset = new Array(maxDays).fill().map -> Math.random() - 0.5
  month.updateBuffer 'tOffset', tOffset

  draw = regl
		frag: fragmentShader
		vert: vertexShader
		elements: square.elements
		count: square.count
		attributes:
			position: square.position
      color1:
        buffer: month.buffers.color1
        divisor: 1
      color2:
        buffer: month.buffers.color2
        divisor: 1
      calendarPosition:
        buffer: month.buffers.calendarPosition
        divisor: 1
      legendPosition:
        buffer: month.buffers.legendPosition
        divisor: 1
      mapPosition:
        buffer: month.buffers.mapPosition
        divisor: 1
      textureId:
        buffer: month.buffers.textureId
        divisor: 1
      tOffset:
        buffer: month.buffers.tOffset
        divisor: 1
    uniforms:
      selected: regl.prop('selected')
      scale: regl.prop('scale')
    instances: maxDays

  destroy: () -> destroy(month)
  draw: draw
  getFormattedDate: () -> "#{monthNames[month.date.getMonth()]} #{month.date.getFullYear()}"
  getDate: () -> month.date
  getDays: () -> month.days
  getKey: () -> month.key
  getPosition: () -> ({x: month.x, y: month.y})
  # positionDays: () -> positionDays(month)
  setConfig: (config) -> month.config = config
  setMonth: (date) -> setMonth(month, date)
  updateCalendarPosition: (x=month.x, y=month.y) -> updateCalendarPosition(month, x, y)
  updateColors: (allDays) -> updateColors(month, allDays)
  updateLegendPosition: (allDays) -> updateLegendPosition(month, allDays)
  updateMapPosition: (allDays) -> updateMapPosition(month, allDays)
