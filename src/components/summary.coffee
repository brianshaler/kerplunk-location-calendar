_ = require 'lodash'
React = require 'react'

{DOM} = React

DAY = 86400 * 1000

module.exports = React.createFactory React.createClass
  getInitialState: ->
    cities: @groupData @props.store.getFromList 'calendar', (item) =>
      @props.start <= item.time < @props.end

  componentDidMount: ->
    @props.store.addFilterListener @handleUpdate, (item) =>
      @props.start <= item.time < @props.end

  componentWillUnmount: ->
    @props.store.removeListener @handleUpdate

  componentWillReceiveProps: (newProps) ->
    return unless newProps.start != @props.start or newProps.end != @props.end
    @setState
      cities: @groupData @props.store.getFromList 'calendar', (item) =>
        newProps.start <= item.time < newProps.end

  groupData: (data) ->
    _.groupBy data, (day) ->
      "#{day.location.city},#{day.location.region ? ''},#{day.location.country}"

  handleUpdate: (data) ->
    @setState
      cities: @groupData data

  render: ->
    cities = _.sortBy @state.cities, (city) -> -city.length
    totalDays = Math.floor (@props.end - @props.start) / DAY

    countries = _ @state.cities
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
        percent = Math.round(country.total / totalDays * 1000) / 10
        display += " #{country.total} day#{if country.total == 1 then '' else 's'} (#{percent}%)"
        DOM.div
          className: 'legend-city'
          key: "summary-#{country.name}"
        ,
          DOM.h3 null, display
      DOM.div className: 'clearfix'
