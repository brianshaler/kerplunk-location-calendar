vertexShader = """
precision mediump float;
// const float M_PI = #{Math.PI};

attribute vec2 position;

attribute vec2 calendarPosition, legendPosition, mapPosition;
attribute float textureId, tOffset;
attribute vec3 color1, color2;

uniform vec2 canvasSize;
uniform float p, width, height, patternSize, scale, selected, z;
uniform vec3 previousState, targetState;

varying vec2 vUv;
varying float vTextureId;
varying vec3 vColor1, vColor2;

void main() {
  // vec2 pos = normalize(position);
  vec2 pos = position;
  vUv = (0.5 * (position + 1.0));
  vTextureId = textureId;
  vColor1 = color1;
  vColor2 = color2;
  float tMag = 0.5;
  float p1 = clamp(tOffset * tMag, 0.0, 1.0);
  float p2 = clamp(1.0 + tOffset * tMag, 0.0, 1.0);
  float _p = (clamp(p, p1, p2) - p1) / (p2 - p1);

  vec3 ps = vec3(
    ((1.0 - _p) * previousState[0] + _p * targetState[0]),
    ((1.0 - _p) * previousState[1] + _p * targetState[1]),
    ((1.0 - _p) * previousState[2] + _p * targetState[2])
  );

  float _x = (calendarPosition.x * ps[0] + legendPosition.x * ps[1] + mapPosition.x * ps[2]) / canvasSize.x * scale;
  float _y = (calendarPosition.y * ps[0] + legendPosition.y * ps[1] + mapPosition.y * ps[2]) / canvasSize.y * scale;

  float _width = width / canvasSize.x * scale;
  float _height = height / canvasSize.y * scale;
  gl_Position = vec4(
    -1.0 + ((_x + (0.5 + pos.x * 0.5) * _width)) * 2.0,
    1.0 - ((_y + (0.5 + pos.y * 0.5) * _height)) * 2.0,
    -0.1 + z,
    1.0
  );
}
"""

fragmentShader = """
precision mediump float;
const float M_TWOPI = #{Math.PI * 2};

uniform float patternSize, width, height, textureCount, scale, selected;
uniform sampler2D tex;

varying vec3 vColor1, vColor2;
varying vec2 vUv;
varying float vTextureId;


#define M_PI 3.14159265358979323846

uniform float time;
float rand(vec2 co){return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);}
float rand (vec2 co, float l) {return rand(vec2(rand(co), l));}
float rand (vec2 co, float l, float t) {return rand(vec2(rand(co, l), t));}

float perlin(vec2 p, float dim, float time) {
  vec2 pos = floor(p * dim);
  vec2 posx = pos + vec2(1.0, 0.0);
  vec2 posy = pos + vec2(0.0, 1.0);
  vec2 posxy = pos + vec2(1.0);

  float c = rand(pos, dim, time);
  float cx = rand(posx, dim, time);
  float cy = rand(posy, dim, time);
  float cxy = rand(posxy, dim, time);

  vec2 d = fract(p * dim);
  d = -0.5 * cos(d * M_PI) + 0.5;

  float ccx = mix(c, cx, d.x);
  float cycxy = mix(cy, cxy, d.x);
  float center = mix(ccx, cycxy, d.y);

  return center * 2.0 - 1.0;
}

mat3 rotateZ(float rad) {
    float c = cos(rad);
    float s = sin(rad);
    return mat3(
        c, s, 0.0,
        -s, c, 0.0,
        0.0, 0.0, 1.0
    );
}

mat3 rotateX(float rad) {
    float c = cos(rad);
    float s = sin(rad);
    return mat3(
        1.0, 0.0, 0.0,
        0.0, c, s,
        0.0, -s, c
    );
}

mat3 rotateY(float rad) {
    float c = cos(rad);
    float s = sin(rad);
    return mat3(
        c, 0.0, -s,
        0.0, 1.0, 0.0,
        s, 0.0, c
    );
}

void main () {
  vec3 color1 = vColor1;
  vec3 color2 = vColor2;
  vec2 vMod = patternSize / vec2(width, height);
  vec2 uv2 = (vUv - (vMod * floor(vUv / vMod))) / vMod;
  vec4 mask = texture2D(tex, uv2 * vec2(1.0 / textureCount, 1.0) + vec2(vTextureId / textureCount, 0.0));
  float alpha = selected < 0.0 ? 1.0 + selected : 1.0;
  gl_FragColor = vec4(mix(color1, color2, mask.x), alpha);
  // float t = time / 1.0 - distance(color1, color2) * 10.0;
  //
  // float dim = 3.0;
  // float interval = 0.5;
  // float seed1 = floor(t / interval);
  // float seed2 = seed1 + 1.0;
  // float seed3 = floor((t + interval * 0.5) / interval);
  // float seed4 = seed3 + 1.0;
  // float _p12 = 0.5 + 0.5 * sin(fract(t / interval) * M_PI - M_PI * 0.5);
  // float _p34 = 0.5 + 0.5 * sin(fract((t + interval * 0.5) / interval) * M_PI - M_PI * 0.5);
  // float p1 = perlin(vUv, dim, seed1);
  // float p2 = perlin(vUv, dim, seed2);
  // float p3 = perlin(vUv, dim * 0.6, seed3);
  // float p4 = perlin(vUv, dim * 0.6, seed4);
  // float v12 = mix(p1, p2, _p12);
  // float v34 = mix(p3, p4, _p34);
  // float range = 0.1;
  // float bottom = 0.1 - range * 0.5;
  // float top = bottom + range;
  // float val = (clamp(mix(v12, v34, 0.5), bottom, top) - bottom) / (top - bottom);
  // vec4 mask = vec4(
  //   val,
  //   val,
  //   val,
  //   1.0);
  // gl_FragColor = vec4(mix(color1, color2, mask.x), alpha);
}
"""

module.exports =
  vertexShader: vertexShader
  fragmentShader: fragmentShader
