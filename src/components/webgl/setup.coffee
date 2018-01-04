Regl = require 'regl'

module.exports = setup = (canvas) ->
  gl = canvas.getContext 'webgl',
    preserveDrawingBuffer: true
  # console.log('gl', gl, canvas)
  regl = Regl
    gl: gl
    extensions: ['angle_instanced_arrays']

  setup = regl
    blend:
      enable: true
      func:
        src: 'src alpha'
        dst: 'one minus src alpha'
      color: [0, 0, 0, 0]
    uniforms:
      p: regl.prop('p')
      time: regl.prop('time')
      z: regl.prop('z')
      # colors: regl.prop('colors')
      canvasSize: regl.prop('canvasSize')
      patternSize: regl.prop('patternSize')
      previousState: regl.prop('previousState')
      targetState: regl.prop('targetState')
      width: regl.prop('width')
      height: regl.prop('height')
      tex: regl.prop('tex')
      textureCount: regl.prop('textureCount')
    depth:
      enable: true
      mask: true
      func: 'always'
      range: [0, 1]

  regl: regl
  setup: setup
