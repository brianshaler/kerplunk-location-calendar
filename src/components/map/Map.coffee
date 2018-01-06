World2 = require './world2'

vertexShader = """
precision mediump float;
attribute vec2 position;
attribute float dur, start, uv;
uniform vec4 crop;
uniform float uAlpha, vScale;
varying float a, p, vUv;
varying float _dur, _start, _v;

void main() {
  _dur = dur;
  _start = start;
  a = uAlpha;
  vUv = uv;
  float _x = position.x; // + step(crop[0], position.x) * 360.0;
  _x = ((_x + 180.0) / 360.0 - (crop[0] + 180.0) / 360.0) * (360.0 / (crop[2] - crop[0]));
  gl_Position = vec4(
    -1.0 + _x * 2.0,
    1.0 - ((90.0 - position.y) / 180.0 - (90.0 - crop[3]) / 180.0) * (180.0 / (crop[3] - crop[1])) * 2.0 * vScale,
    -0.99998,
    0.99998);
}
"""

fragmentShader = """
precision mediump float;
uniform float time;
varying float _dur;
varying float _start;
varying float vUv;
varying float a;
float PI = #{Math.PI};

void main () {
  float dur = _dur;
  float start = _start;
  float alpha;
  float uv = vUv;
  float br = step(uv, (time - start) / dur);
  gl_FragColor = vec4(0, 1, 0, br * a);
}
"""

positions = Array.prototype.concat.apply [], World2.countries.map (country) -> country.position

elements = Array(positions.length).fill().map((z, i) -> [i * 2, i * 2 + 1])

durations = Array.prototype.concat.apply [], World2.countries.map (country) -> country.d.map (d) -> [d, d]

times = Array.prototype.concat.apply [], World2.countries.map (country) -> country.t.map (t) -> [t, t]

module.exports = Map = (regl) ->
  draw = regl({
    blend: {
      enable: true,
      func: {
        src: 'src alpha',
        dst: 'one minus src alpha'
      },
      color: [0, 0, 0, 0],
    },
    frag: fragmentShader,
    vert: vertexShader,
    elements: elements,
    primitive: 'lines',
    attributes: {
      dur: durations
      start: times
      position: positions,
      uv: Array(positions.length).fill().map () -> [0, 1]
    },
    uniforms: {
      uAlpha: regl.prop('uAlpha'),
      crop: regl.prop('crop'),
      time: regl.prop('time'),
      vScale: regl.prop('vScale'),
    },
  });

  draw: (obj) ->
    draw([{
      uAlpha: 1
      time: obj.p
      crop: obj.crop
      vScale: obj.vScale
    },
    {
      uAlpha: 1
      time: obj.p
      crop: [
        obj.crop[0] - 360
        obj.crop[1]
        obj.crop[2] - 360
        obj.crop[3]
      ]
      vScale: obj.vScale
    },
    {
      uAlpha: 1
      time: obj.p
      crop: [
        obj.crop[0] + 360
        obj.crop[1]
        obj.crop[2] + 360
        obj.crop[3]
      ]
      vScale: obj.vScale
    }])
