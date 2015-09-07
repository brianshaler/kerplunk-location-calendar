SparkMD5 = require 'spark-md5'
md5 = SparkMD5.hash

indexedColor = require './indexedColor'

CHECKER = "checker"
STRIPE_NWSE = "stripe_nwse"
STRIPE_NESW = "stripe_nesw"
THIN_STRIPE_WE = "thin_stripe_we"
THIN_STRIPE_NS = "thin_stripe_ns"
THICK_STRIPE_WE = "thick_stripe_we"
THICK_STRIPE_NS = "thick_stripe_ns"
DOTS = "dots"
WIGGLE_WE = "wiggle_we"
WIGGLE_NS = "wiggle_ns"

patterns = [
  CHECKER
  STRIPE_NWSE
  STRIPE_NESW
  THIN_STRIPE_WE
  THIN_STRIPE_NS
  THICK_STRIPE_WE
  THICK_STRIPE_NS
  DOTS
  WIGGLE_WE
  WIGGLE_NS
]

drawPixels = (pixels, ctx, c) ->
  for pixel in pixels
    ctx.fillStyle = "rgb(#{c.r},#{c.g},#{c.b})"
    #ctx.fillStyle = "rgb(0, 255, 0)"
    ctx.fillRect pixel[0], pixel[1], 1, 1

savedPatterns = {}
getPattern = (str) ->
  # str = md5 str
  # key = c1.hex+"_"+c2.hex+"_"+pattern
  if savedPatterns.hasOwnProperty str
    return savedPatterns[str]

  {c1, c2, pattern} = indexedColor str, patterns
  if !pattern or pattern < 1
      pattern = 1
  pattern -= 1
  pattern = pattern % patterns.length


  canvas = document.createElement 'canvas'
  canvas.width = 4
  canvas.height = 4
  ctx = canvas.getContext '2d'

  ctx.fillStyle = "rgb(#{c2.r},#{c2.g},#{c2.b})"
  ctx.fillRect 0, 0, 4, 4

  x = 0
  y = 0
  coords = if patterns[pattern] == CHECKER
    [
      [0, 0]
      [1, 0]
      [0, 1]
      [1, 1]
      [2, 2]
      [3, 2]
      [2, 3]
      [3, 3]
    ]
  else if patterns[pattern] == STRIPE_NWSE
    [
      [0, 0]
      [1, 0]
      [1, 1]
      [2, 1]
      [2, 2]
      [3, 2]
      [3, 3]
      [0, 3]
    ]
  else if patterns[pattern] == STRIPE_NESW
    [
      [2, 0]
      [3, 0]
      [1, 1]
      [2, 1]
      [0, 2]
      [1, 2]
      [3, 3]
      [0, 3]
    ]
  else if patterns[pattern] == THIN_STRIPE_WE
    [
      [0, 0]
      [1, 0]
      [2, 0]
      [3, 0]
      [0, 2]
      [1, 2]
      [2, 2]
      [3, 2]
    ]
  else if patterns[pattern] == THIN_STRIPE_NS
    [
      [0, 0]
      [0, 1]
      [0, 2]
      [0, 3]
      [2, 0]
      [2, 1]
      [2, 2]
      [2, 3]
    ]
  else if patterns[pattern] == THICK_STRIPE_WE
    [
      [0, 0]
      [1, 0]
      [2, 0]
      [3, 0]
      [0, 1]
      [1, 1]
      [2, 1]
      [3, 1]
    ]
  else if patterns[pattern] == THICK_STRIPE_NS
    [
      [0, 0]
      [0, 1]
      [0, 2]
      [0, 3]
      [1, 0]
      [1, 1]
      [1, 2]
      [1, 3]
    ]
  else if patterns[pattern] == WIGGLE_WE
    [
      [0, 0]
      [1, 1]
      [2, 0]
      [3, 1]
    ]
  else if patterns[pattern] == WIGGLE_NS
    [
      [0, 0]
      [1, 1]
      [0, 2]
      [1, 3]
    ]
  else if patterns[pattern] == DOTS
    [
      [1, 1]
      [3, 1]
      [1, 3]
      [3, 3]
    ]
  else
    []

  drawPixels coords, ctx, c1
  savedPatterns[str] = canvas
  return canvas
  # png = canvas.toDataURL()
  # savedPatterns[key] = png

module.exports = getPattern
