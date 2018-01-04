primes = [11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71]

module.exports = getPlaceProps = (name) ->
  cursor = 71 % name.length
  accum = 263 + (256 + name.length) * primes[name.length % primes.length]

  getNextByte = ->
    val = 1 + name.charCodeAt(cursor % name.length)
    for i in [0...val]
      accum += primes[accum % primes.length]
    cursor++
    accum % 256

  color1 = [
    getNextByte() / 255
    getNextByte() / 255
    getNextByte() / 255
  ]

  color2 = [
    getNextByte() / 255
    getNextByte() / 255
    getNextByte() / 255
  ]

  # uuid: (getNextByte() << 16) | (getNextByte() << 8) | getNextByte()
  name: name
  total: 1
  color1: color1
  color2: color2
  textureId: Math.floor((getNextByte() / 255 * 5) % 5)
