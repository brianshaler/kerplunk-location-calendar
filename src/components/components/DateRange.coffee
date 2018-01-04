React = require 'react'

{DOM} = React

module.exports = DateRange = React.createClass
  render: ->
    {
      startDate
      endDate
      selectionStart
      selectionEnd
      onSelect
      label
    } = this.props

    DOM.a
      className: if selectionStart.toString() == startDate.toString() and selectionEnd.toString() == endDate.toString() then 'selected' else null
      href: '#'
      onClick: (e) ->
        e.preventDefault()
        onSelect(selectionStart, selectionEnd)
    , label
