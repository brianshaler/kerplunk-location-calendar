React = require 'react'

{DOM} = React

module.exports = MapOverlay = React.createClass
  render: ->
    {
      config
      mapShowing
      placeKey
      selectedMonth
      summaryMap
    } = @props

    {
      pixelRatio
      textHeight
    } = config

    sortedLabels = Object.values(summaryMap.mapLabels)
    sortedLabels.sort (a, b) -> if a.total < b.total then -1 else 1

    DOM.div
      style:
        # display: 'none'
        position: 'absolute'
        left: if mapShowing then '0px' else '-10000px'
    ,
      sortedLabels.map (place, index) ->
        if !place
          return DOM.div null, '???'
        # percent = if place.percent >= 0.1 then Math.round(place.percent * 1000) / 10 else Math.round(place.percent * 10000) / 100
        DOM.div
          key: place[placeKey]
          className: 'legend-city'
          style:
            backgroundColor: 'rgba(0, 0, 0, 0.6)'
            fontSize: "#{0.6 * textHeight / pixelRatio * 0.9}px"
            textShadow: '1px 1px 1px #000'
            left: "#{place.mapX / pixelRatio}px"
            top: "#{(place.mapY + 1) / pixelRatio}px"
            opacity: if mapShowing or selectedMonth then 1 else 0
            padding: '0 0.5em'
        ,
          place[placeKey]
