_ = require 'lodash'
React = require 'react'

Box = require './box'

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

    DOM.div
      className: 'months'
    ,
      DOM.h2 null, 'Legend'
      _.map cities, (city, cityIndex) =>
        loc = city[0].location
        displayCity = "#{loc.city}, "
        displayCity += if /^united states$/i.test loc.country
          loc.region
        else
          loc.country
        percent = Math.round(city.length / totalDays * 1000) / 10
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
                key: "legend-day-#{day.formatted}_#{cityIndex}"
                day: day
            DOM.div className: 'clearfix'

        DOM.div
          className: 'legend-city'
          key: "legend-city-#{loc.city}-#{loc.region}-#{loc.country}"
        , content
