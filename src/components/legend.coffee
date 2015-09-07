_ = require 'lodash'
React = require 'react'

Box = require './box'

{DOM} = React

module.exports = React.createFactory React.createClass
  render: ->
    cities = _.sortBy @props.cities, (city) -> -city.length

    DOM.div
      className: 'months'
    ,
      DOM.h2 null, 'Legend'
      _.map cities, (city) =>
        loc = city[0].location
        displayCity = "#{loc.city}, "
        displayCity += if /^united states$/i.test loc.country
          loc.region
        else
          loc.country
        percent = Math.round(city.length / @props.totalDays * 1000) / 10
        displayCity += " #{city.length} day#{if city.length == 1 then '' else 's'} (#{percent}%)"

        content = if city.length < 4
          DOM.div
            className: 'legend-inline'
          ,
            _.map city, (day) =>
              Box _.extend {}, @props,
                key: "legend-#{day.formatted}"
                day: day
            DOM.span null, displayCity
        else
          DOM.div null,
            DOM.h3 null, displayCity
            DOM.div
              style:
                maxWidth: 13 * 20
            , _.map city, (day) =>
              Box _.extend {}, @props,
                key: "legend-day-#{day.formatted}"
                day: day
            DOM.div className: 'clearfix'

        DOM.div
          className: 'legend-city'
          key: "legend-city-#{loc.city}-#{loc.region}-#{loc.country}"
        , content
