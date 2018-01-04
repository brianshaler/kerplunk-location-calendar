React = require 'react'

{DOM} = React

module.exports = MonthLabels = React.createClass
  render: ->
    {
      config
      months
      onSelect
    } = @props

    {
      pixelRatio
      squareMargin
      squareSize
      textHeight
    } = config

    if !months
      return DOM.div()

    DOM.div null,
      months.map (month) ->
        { x, y } = month.getPosition()
        DOM.a
          key: month.getKey()
          className: 'calendar-month'
          href: '#'
          onClick: (e) ->
            e.preventDefault()
            onSelect(month)
          style:
            display: 'block'
            left: "#{x / pixelRatio}px"
            top: "#{(y - textHeight * 1.2) / pixelRatio}px"
            width: "#{(squareSize + squareMargin) * 7 / pixelRatio}px"
            height: "#{(textHeight + (squareSize + squareMargin) * 6) / pixelRatio}px"
            # backgroundColor: 'rgba(0, 255, 255, 0.3)'
      months.map (month) ->
        { x, y } = month.getPosition()
        DOM.div
          key: month.getKey()
          className: 'calendar-month'
          style:
            left: "#{x / pixelRatio}px"
            top: "#{(y - textHeight * 1.2) / pixelRatio}px"
