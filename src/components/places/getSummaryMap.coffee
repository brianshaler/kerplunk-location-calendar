module.exports = getSummaryMap = (state) ->
  {
    allDays
    config
    placeKey
    places
  } = state

  {
    pixelRatio
    squareSize
  } = config
  # console.log('getSummaryMap', allDays.length, places)

  mapLabels = {}

  minLng = Infinity
  maxLng = -Infinity
  minLat = Infinity
  maxLat = -Infinity

  keys = {}
  allDays.forEach (day) ->
    keys[day['city']] = 1
  _places = Object.keys(keys).map (key) -> places.getPlaceByKey('city', key)

  biggestLngGap = 0
  biggestLngGapFrom = 180
  biggestLngGapTo = 180

  _places.forEach (place) ->
    gaps = _places.map (p) ->
      gap = p.lng - place.lng
      if p.lng <= place.lng
        gap += 360

      lng: p.lng
      gap: gap

    gaps.sort (a, b) -> if a.gap < b.gap then -1 else 1
    if gaps[0].gap > biggestLngGap
      biggestLngGap = gaps[0].gap
      biggestLngGapFrom = place.lng
      biggestLngGapTo = gaps[0].lng

    if place.lat < minLat
      minLat = place.lat
    if place.lat > maxLat
      maxLat = place.lat

    # if place.lng < minLng
    #   minLng = place.lng
    # if place.lng > maxLng
    #   maxLng = place.lng

  minLng = biggestLngGapTo
  maxLng = biggestLngGapFrom
  while maxLng < minLng
    maxLng += 360

  latDiff = maxLat - minLat
  lngDiff = maxLng - minLng

  aspect = window.innerWidth / window.innerHeight
  if aspect > lngDiff / latDiff
    lngMid = minLng + lngDiff / 2
    lngDiff = latDiff * aspect
    minLng = lngMid - lngDiff / 2
    maxLng = lngMid + lngDiff / 2
  else
    latMid = minLat + latDiff / 2
    latDiff = lngDiff / aspect
    minLat = latMid - latDiff / 2
    maxLat = latMid + latDiff / 2

  padding = 0.1
  minLat -= latDiff * padding
  maxLat += latDiff * padding
  minLng -= lngDiff * padding
  maxLng += lngDiff * padding

  # console.log({minLat, maxLat, minLng, maxLng})
  if maxLat > 90
    minLat -= maxLat - 90
    maxLat = 90

  # console.log('biggestLngGap', biggestLngGap, 'biggestLngGapFrom', biggestLngGapFrom, 'biggestLngGapTo', biggestLngGapTo)

  dayProps = allDays.map (day) ->
    key = day[placeKey]
    place = places.getPlaceByKey('city', day.city)

    # console.log('key', key)
    # console.log('place', place)
    #
    #
    # throw new Error('wait')

    if !mapLabels[key]
      mapLabels[key] =
        name: place.name
        city: place.city
        country: place.country
        total: 0
        percent: 1
    mapLabels[key].total++

    _lng = place.lng
    while _lng > maxLng
      _lng -= 360
    while _lng < minLng
      _lng += 360

    _width = state.width * pixelRatio
    _height = window.innerHeight * pixelRatio

    mapX = _width * (_lng - minLng) / (maxLng - minLng) - squareSize * 0.5
    mapY = _height * (1 - (place.lat - minLat) / (maxLat - minLat)) - squareSize * 0.5
    mapX = Math.round(mapX / squareSize * 3) * squareSize / 3
    mapY = Math.round(mapY / squareSize * 3) * squareSize / 3

    mapLabels[key].mapX = mapX + squareSize * 1.2
    mapLabels[key].mapY = mapY

    key: day.key,
    mapPosition: [mapX, mapY],
    color1: place.color1,
    color2: place.color2,
    textureId: place.textureId,

  summaryMap =
    dayProps: dayProps
    mapLabels: mapLabels
    minLat: minLat
    maxLat: maxLat
    minLng: minLng
    maxLng: maxLng

  # console.log('summaryMap', summaryMap)

  summaryMap
