React = require 'react'

{DOM} = React

module.exports = MonthLabels = React.createClass
  render: ->
    {
      config
      months
      selectedMonth
    } = this.props

    {
      pixelRatio
      textHeight
    } = config

    if !months
      return DOM.div()

    DOM.div null,
      months.map (month) ->
        { x, y } = month.getPosition()
        fontSize = textHeight / pixelRatio * 0.9
        DOM.div
          key: month.getKey()
          className: 'calendar-month'
          style:
            fontSize: "#{fontSize}px"
            left: "#{x / pixelRatio}px"
            top: "#{(y - textHeight * 1.2) / pixelRatio}px"
            opacity: if !selectedMonth then 1 else 0
        ,
          month.getFormattedDate()
