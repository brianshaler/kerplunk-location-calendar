React = require 'react'

{DOM} = React

module.exports = Legend = React.createClass
  render: ->
    {
      config
      legendShowing
      monthLegend
      placeKey
      selectedMonth
      summaryLegend
    } = @props

    {
      pixelRatio
      textHeight
    } = config

    DOM.div
      style:
        # display: 'none'
        position: 'absolute'
        left: (legendShowing || selectedMonth) ? '0px' : '-10000px',
    ,
      Object.values(if selectedMonth then monthLegend.legendLabels else summaryLegend.legendLabels).map (place, index) ->
        if !place
          return DOM.div null, '???'
        percent = if place.percent >= 0.1 then Math.round(place.percent * 1000) / 10 else Math.round(place.percent * 10000) / 100
        DOM.div
          key: place[placeKey]
          className: 'legend-city'
          style:
            fontSize: "#{textHeight / pixelRatio * 0.9}px"
            textShadow: '1px 1px 1px #000'
            left: "#{place.legendX / pixelRatio}px"
            top: "#{(place.legendY + 1) / pixelRatio}px"
            opacity: if legendShowing || selectedMonth then 1 else 0
        ,
          "#{place[placeKey]} - #{place.total} #{if place.total == 1 then 'day' else 'days'} (#{percent}%)"
