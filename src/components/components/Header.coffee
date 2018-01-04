React = require 'react'

{DOM} = React

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

module.exports = Header = React.createClass
  render: ->
    {
      endDate
      hideLabels
      placeKey
      selectedMonth
      startDate
      summaryMap
    } = @props

    content = 'Header'

    placeCount = Object.values(summaryMap.mapLabels).length

    unit = (placeKey, value) ->
      if placeKey == 'city'
        return "#{value} #{if value == 1 then 'city' else 'cities'}"
      if placeKey == 'country'
        return "#{value} #{if value == 1 then 'country' else 'countries'}"
      return "#{value}"

    if selectedMonth
      content = selectedMonth.getFormattedDate()
    else
      startDateString = "#{monthNames[startDate.getMonth()]} #{startDate.getFullYear()}"
      endDateString = "#{monthNames[endDate.getMonth()]} #{endDate.getFullYear()}"
      content = "#{startDateString} - #{endDateString}" + (if hideLabels then '' else ": #{unit(placeKey, placeCount)}")
      # content = "#{monthNames[month.date.getMonth()]} #{month.date.getFullYear()}"

    DOM.header null,
      DOM.h1 null, content
