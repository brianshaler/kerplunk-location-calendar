getPlaceProps = require './getPlaceProps'

module.exports = class Places
  constructor: ->
    @placesByCity = {}
    @placesByCountry = {}

  getPlaceByKey: (key, val) ->
    if key == 'city'
      return @placesByCity[val]
    else if key == 'country'
      return @placesByCountry[val]
    throw new Error "key '#{key}' (for #{val}) not a valid key"

  getPlace: (placeProps) ->
    { city } = placeProps
    if @placesByCity[city]
      return @placesByCity[city]

    placeCity = Object.assign({}, placeProps, getPlaceProps(placeProps.name))
    placeCountry = Object.assign({}, placeProps, getPlaceProps(placeProps.country))
    @placesByCountry[placeProps.country] = placeCountry
    @placesByCity[placeProps.city] = placeCity

    placeCity
