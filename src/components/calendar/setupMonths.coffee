Month = require './month'

module.exports = setupMonths = (regl, months, startDate, endDate, config) ->
  {
    monthColumns
    pageMargin
    squareSize
    squareMargin
    textHeight
    width
  } = config

  d = new Date(startDate)
  while d < endDate
    key = "#{d.getFullYear()}-#{d.getMonth()}"
    found = months.find (m) => m.getKey() == key
    if !found
      months.push(Month(regl, new Date(d), config))
    d.setMonth(d.getMonth() + 1)

  months.sort (a, b) -> if a.getDate() > b.getDate() then 1 else -1
  # console.log('setupMonths', monthColumns, startDate, endDate)

  months
  .filter (m) => m.getDate() >= startDate and m.getDate() < endDate
  .forEach (month, index) ->
    calMonthRow = Math.floor(index / monthColumns)
    calMonthCol = index - calMonthRow * monthColumns

    colWidth = Math.floor(width / monthColumns)
    calMonthX = pageMargin[3] + calMonthCol * colWidth
    calMonthY = pageMargin[0] + calMonthRow * (squareSize + squareMargin) * 7.5 + textHeight

    month.setConfig(config)
    month.updateCalendarPosition(calMonthX, calMonthY)
