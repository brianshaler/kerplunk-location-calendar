Totals = require './totals'
Ranked = require './ranked'

module.exports = getLegend = (days, places, config, placeKey) ->
  {
    squareSize
    squareMargin
    legendColumns
    sideLabelMax
    pageMargin
    textHeight
  } = config

  legendLabels = {}

  totals = Totals days.map (d) -> d[placeKey]
  ranked = Ranked totals
  daysByKey = days.reduce (memo, day) ->
    if !memo[day[placeKey]]
      memo[day[placeKey]] = []
    memo[day[placeKey]].push(day)
    memo
  , {}

  # console.log('make dayProps', legendColumns, squareSize)
  dayProps = days.map (day) ->
    id = day[placeKey]
    place = places.getPlaceByKey(placeKey, id)
    if !place
      throw new Error 'place not found: ' + id

    before = daysByKey[id].indexOf(day)
    legRow = Math.floor before / legendColumns
    legCol = before - legRow * legendColumns

    legX = (pageMargin[3] + (squareSize + squareMargin) * legCol)

    textRowHeight = textHeight / (squareSize + squareMargin)

    prevPlaces = ranked.slice(0, ranked.indexOf(String(id)))
    rowsBefore = prevPlaces.reduce (memo, prevId) ->
      total = totals[prevId]
      memo += Math.ceil(total / legendColumns) + 0.2
      if total > sideLabelMax
        memo += textRowHeight
      memo
    , 0
    if totals[id] > sideLabelMax
      rowsBefore += textRowHeight

    legY = pageMargin[0] + rowsBefore * (squareSize + squareMargin) + (squareSize + squareMargin) * legRow

    if !legendLabels[id]
      legendLabels[id] =
        name: place.name
        city: place.city
        country: place.country
        total: totals[id]
        percent: totals[id] / days.length

    legendLabels[id].legendX = pageMargin[3] + (totals[id] > sideLabelMax ? 0 : (squareSize + squareMargin) * (totals[id] + 0.2))
    legendLabels[id].legendY = pageMargin[0] + (rowsBefore + (totals[id] > sideLabelMax ? 0 : 1)) * (squareSize + squareMargin) - textHeight * 1.1

    key: day.key,
    legendPosition: [legX, legY],
    color1: place.color1,
    color2: place.color2,
    textureId: place.textureId,

  dayProps: dayProps
  legendLabels: legendLabels
