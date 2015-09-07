_ = require 'lodash'
React = require 'react'

{DOM} = React

module.exports = React.createFactory React.createClass
  render: ->
    cities = _.sortBy @props.cities, (city) -> -city.length

    countries = _ @props.cities
      .map (city) ->
        name: city[0].location.country
        days: city.length
      .groupBy (country) -> country.name
      .map (data, name) ->
        blah = (memo, obj) ->
          memo + obj.days
        name: name
        cities: data.length
        total: _.reduce data, blah, 0
      .sortBy (country) ->
        -country.total
      .value()

    DOM.div
      className: 'months'
    ,
      DOM.h2 null, 'Summary'
      DOM.div null,
        DOM.strong null, countries.length
        DOM.span null, ' countries'
      _.map countries, (country) =>
        display = "#{country.name}:"
        percent = Math.round(country.total / @props.totalDays * 1000) / 10
        display += " #{country.total} day#{if country.total == 1 then '' else 's'} (#{percent}%)"
        DOM.div
          className: 'legend-city'
          key: "summary-#{country.name}"
        ,
          DOM.h3 null, display
      DOM.div className: 'clearfix'
