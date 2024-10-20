#pragma header uniform float barrel;
uniform float zoom;
uniform bool doChroma;
uniform float angle;
uniform float iTime;
uniform float x;
uniform float y;
// edited version of this
// https://www.shadertoy.com/view/td2XDz
vec2 remap(vec2 t, vec2 a, vec2 b)
{
  return clamp((t - a) / (b - a), 0.0, 1.0);
}
vec4 spectrum_offset_rgb(float t)
{
  if (!doChroma) return vec4(1.0, 1.0, 1.0, 1.0); // turn off chroma
  float
  t0 = 3.0 * t - 1.5;
  vec3
  ret = clamp(vec3(-t0, 1.0 - abs(t0), t0), 0.0, 1.0);
  return vec4(ret.r, ret.g, ret.b, 1.0);
}
vec2 brownConradyDistortion(vec2 uv, float dist)
{
  uv = uv * 2.0 - 1.0;
  float
  barrelDistortion1 = 0.1 * dist; // K1 in text books
  float
  barrelDistortion2 = -0.025 * dist; // K2 in text books
  float
  r2 = dot(uv, uv);
  uv *= 1.0 + barrelDistortion1 * r2 + barrelDistortion2 * r2 * r2;
  return uv * 0.5 + 0.5;
}
vec2 distort(vec2 uv, float t, vec2 min_distort, vec2 max_distort)
{
  vec2
  dist = mix(min_distort, max_distort, t);
  return brownConradyDistortion(uv, 75.0 * dist.x);
}
float nrand(vec2 n)
{
  return fract(sin(dot(n.xy, vec2(12.9898, 78.233))) * 43758.5453);
}
vec4 render(vec2 uv)
{
  uv.x += x;
  uv.y += y;
  // funny mirroring shit
  if ((uv.x > 1.0 || uv.x < 0.0) && abs(mod(uv.x, 2.0)) > 1.0) uv.x = (0.0 - uv.x) + 1.0;
  if ((uv.y > 1.0 || uv.y < 0.0) && abs(mod(uv.y, 2.0)) > 1.0) uv.y = (0.0 - uv.y) + 1.0;
  return flixel_texture2D(bitmap, vec2(abs(mod(uv.x, 1.0)), abs(mod(uv.y, 1.0))));
}
void main()
{
  vec2
  iResolution = vec2(1280.0, 720.0);
  // rotation bullshit
  vec2
  center = vec2(0.5, 0.5);
  vec2
  uv = openfl_TextureCoordv.xy;
  // uv = uv.xy - center; //move uv center point from center to top left
  mat2
  translation = mat2(0, 0, 0, 0);
  mat2
  scaling = mat2(zoom, 0.0, 0.0, zoom);
  // uv = uv * scaling;
  float
  angInRad = radians(angle);
  mat2
  rotation = mat2(cos(angInRad), -sin(angInRad), sin(angInRad), cos(angInRad));
  // used to stretch back into 16:9
  // 0.5625 is from 9/16
  mat2
  aspectRatioShit = mat2(0.5625, 0.0, 0.0, 1.0);
  vec2
  fragCoordShit = iResolution * openfl_TextureCoordv.xy;
  uv = (fragCoordShit - .5 * iResolution.xy) / iResolution.y;
  uv = uv * scaling;
  uv = (aspectRatioShit) * (rotation * uv);
  uv = uv.xy + center; // move back to center
  const
  float
  MAX_DIST_PX = 50.0;
  float
  max_distort_px = MAX_DIST_PX * barrel;
  vec2
  max_distort = vec2(max_distort_px) / iResolution.xy;
  vec2
  min_distort = 0.5 * max_distort;
  vec2
  oversiz = distort(vec2(1.0), 1.0, min_distort, max_distort);
  uv = mix(uv, remap(uv, 1.0 - oversiz, oversiz), 0.0);
  const
  int
  num_iter = 7;
  const
  float
  stepsiz = 1.0 / (float(num_iter) - 1.0);
  float
  rnd = nrand(uv + fract(iTime));
  float
  t = rnd * stepsiz;
  vec4
  sumcol = vec4(0.0);
  vec3
  sumw = vec3(0.0);
  for (int i = 0;
  i < num_iter;
  ++i
)
  {
    vec4
    w = spectrum_offset_rgb(t);
    sumw += w.rgb;
    vec2
    uvd = distort(uv, t, min_distort, max_distort);
    sumcol += w * render(uvd);
    t += stepsiz;
  }
  sumcol.rgb /= sumw;
  vec3
  outcol = sumcol.rgb;
  outcol = outcol;
  outcol += rnd / 255.0;
  gl_FragColor = vec4(outcol, sumcol.a / num_iter);
}
