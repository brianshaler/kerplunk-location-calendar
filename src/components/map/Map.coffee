Square = require '../webgl/square'

module.exports = Map = (regl) ->
  square = Square(1)

  draw = regl
    vert: """
      precision mediump float;

      attribute vec2 position;
      uniform float vScale;

      varying vec2 vUv;

      void main() {
      	vUv = (0.5 * (position + 1.0));
      	gl_Position = vec4(
      		-1.0 + (0.5 + position.x * 0.5) * 2.0,
      		1.0 - (0.5 + position.y * 0.5) * 2.0 * vScale,
          -0.9999,
          0.9999
      	);
      }
    """
    frag: """
      precision mediump float;

      uniform sampler2D tex;
      uniform vec4 crop;
      uniform float p;
      uniform float vScale;

      varying vec2 vUv;

      void main () {
        vec2 pos = vec2(
          crop[0] + (crop[2] - crop[0]) * vUv.x,
          crop[1] + (crop[3] - crop[1]) * vUv.y
          // vUv.y
        );
      	vec4 color = vec4(texture2D(tex, pos).rgb, p);
        if (pos.y > 1.0) {
          color.a = 0.0;
        }
        gl_FragColor = color;
      }
    """
		elements: square.elements
		count: square.count
		attributes:
			position: square.position
    uniforms:
      p: regl.prop('p')
      crop: regl.prop('crop')
      tex: regl.prop('tex')
      vScale: regl.prop('vScale')

  bg = null

  img = new Image()
  img.onload = ->
    # console.log('image loaded')
    bg = regl.texture
      data: img
      wrapS: 'repeat'
      # wrapT: 'repeat'
  img.src = './earth.png'

  draw: draw
  bgTexture: () => bg
