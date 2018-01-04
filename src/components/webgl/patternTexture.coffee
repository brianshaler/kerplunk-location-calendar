module.exports = patternTexture = (regl) ->
  textureSize = 100

  c1 = document.createElement('canvas')
  c1.width = c1.height = textureSize
  ctx = c1.getContext('2d')
  ctx.fillStyle = '#000'
  ctx.fillRect(0, 0, c1.width, c1.height)

  # ctx.fillStyle = '#fff'
  # ctx.fillRect(0, 0, 50, 50)
  # ctx.fillStyle = '#fff'
  # ctx.fillRect(50, 50, 50, 50)

  # ctx.lineWidth = 2
  # ctx.strokeStyle = '#fff'
  # ctx.strokeRect(1, 1, 98, 98)

  ctx.save()
  sqSize = Math.sqrt(Math.pow(textureSize / 2, 2) * 2) - 0.5
  ctx.translate(textureSize / 2, textureSize / 2)
  ctx.rotate(Math.PI / 4)
  ctx.fillStyle = '#fff'
  ctx.fillRect(-sqSize / 2, -sqSize / 2, sqSize, sqSize)
  ctx.restore()


  c2 = document.createElement('canvas')
  c2.width = c2.height = textureSize
  ctx = c2.getContext('2d')
  ctx.fillStyle = '#000'
  ctx.fillRect(0, 0, c2.width, c2.height)

  ctx.fillStyle = '#fff'
  ctx.fillRect(0, 0, textureSize / 2, textureSize / 2)
  ctx.fillStyle = '#fff'
  ctx.fillRect(textureSize / 2, textureSize / 2, textureSize / 2, textureSize / 2)

  c3 = document.createElement('canvas')
  c3.width = c3.height = textureSize
  ctx = c3.getContext('2d')
  ctx.fillStyle = '#000'
  ctx.fillRect(0, 0, c3.width, c3.height)

  ctx.fillStyle = '#fff'
  ctx.fillRect(0, 0, textureSize, textureSize / 2)

  c4 = document.createElement('canvas')
  c4.width = c4.height = textureSize
  ctx = c4.getContext('2d')
  ctx.fillStyle = '#000'
  ctx.fillRect(0, 0, c4.width, c4.height)

  ctx.fillStyle = '#fff'
  ctx.beginPath()
  ctx.moveTo(textureSize / 2, 0)
  ctx.lineTo(0, textureSize / 2)
  ctx.lineTo(0, textureSize)
  ctx.lineTo(textureSize, 0)
  ctx.closePath()
  ctx.fill()

  ctx.beginPath()
  ctx.moveTo(textureSize, textureSize / 2)
  ctx.lineTo(textureSize / 2, textureSize)
  ctx.lineTo(textureSize, textureSize)
  ctx.closePath()
  ctx.fill()


  c5 = document.createElement('canvas')
  c5.width = c5.height = textureSize
  ctx = c5.getContext('2d')
  ctx.fillStyle = '#000'
  ctx.fillRect(0, 0, c5.width, c5.height)

  ctx.fillStyle = '#fff'
  ctx.beginPath()
  ctx.moveTo(textureSize / 2, 0)
  ctx.lineTo(textureSize, textureSize / 2)
  ctx.lineTo(textureSize, textureSize)
  ctx.lineTo(0, 0)
  ctx.closePath()
  ctx.fill()

  ctx.beginPath()
  ctx.moveTo(0, textureSize / 2)
  ctx.lineTo(textureSize / 2, textureSize)
  ctx.lineTo(0, textureSize)
  ctx.closePath()
  ctx.fill()


  canvases = [c1, c2, c3, c4, c5]
  tx = document.createElement('canvas')
  tx.width = textureSize * canvases.length
  tx.height = textureSize
  txctx = tx.getContext('2d')
  canvases.forEach (cvs, idx) ->
    txctx.drawImage(cvs,
      0,
      0,
      textureSize,
      textureSize,
      textureSize * idx,
      0,
      textureSize,
      textureSize)

  texture = regl.texture
    min: 'linear'
    mag: 'linear'
    data: tx
  textureCount = canvases.length

  texture: texture
  textureCount: textureCount
