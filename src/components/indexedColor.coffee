SparkMD5 = require 'spark-md5'
md5 = SparkMD5.hash

hexdec = (hex) -> parseInt hex, 16

indexedColors = {}
indexedColor = (code, patterns = []) ->
  key = md5 code
  if indexedColors.hasOwnProperty key
    return indexedColors[key]

  c1 = getColor key
  c2 = getColor key, c1.hex
  _pattern = hexdec(key.substr(0, 2)) % patterns.length + 1

  indexedColors[key] =
    c1: c1
    c2: c2
    pattern: _pattern
  indexedColors[key]

cdist = (d) -> Math.pow Math.abs(d)/10, 2

addRGB = (c) ->
  c.r = hexdec c.hex.substr(0, 2)
  c.g = hexdec c.hex.substr(2, 2)
  c.b = hexdec c.hex.substr(4, 2)

getColor = (seed, avoid) ->
  if !avoid
    avoid = '000000'
  noise = 'x'
  offset = 1
  nope =
    hex: avoid
  addRGB nope
  c1 =
    hex: md5(seed).substr(offset, 6)
  addRGB c1
  c2 =
    hex: md5(seed+noise).substr(offset, 6)
  addRGB c2
  c3 =
    hex: md5(seed+noise).substr(offset+6, 6)
  addRGB c3

  d1 = cdist(nope.r-c1.r) + cdist(nope.g-c1.g) + cdist(nope.b-c1.b)
  d2 = cdist(nope.r-c2.r) + cdist(nope.g-c2.g) + cdist(nope.b-c2.b)
  d3 = cdist(nope.r-c3.r) + cdist(nope.g-c3.g) + cdist(nope.b-c3.b)

  if d3 > d2
    d2 = d3
    c2 = c3

  c = if d1 > d2 then c1 else c2

  highestChannel = 'r'
  highest = -1
  lowestChannel = 'b'
  lowest = -1
  channels = ['r', 'g', 'b']
  for k, channel of channels
    if highest == -1 || c[channel] > highest
      highestChannel = channel
      highest = c[channel]
    if lowest == -1 || c[channel] < lowest
      lowestChannel = channel
      lowest = c[channel]
  if highest != lowest
    c[highestChannel] = Math.round (255 + c[highestChannel]) / 2
    c[lowestChannel] = Math.round c[lowestChannel] / 2
  c

module.exports = indexedColor
