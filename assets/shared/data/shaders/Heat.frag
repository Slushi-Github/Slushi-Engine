#pragma header uniform float strength;
uniform float iTime;
float rand(vec2 n)
{
  return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}
float noise(vec2 n)
{
  const
  vec2
  d = vec2(0.0, 1.0);
  vec2
  b = floor(n),
  f = smoothstep(vec2(0.0), vec2(1.0), fract(n));
  return mix(mix(rand(b), rand(b + d.yx), f.x), mix(rand(b + d.xy), rand(b + d.yy), f.x), f.y);
}
// https://www.shadertoy.com/view/XsVSRd
// edited version of this
// partially using a version in the comments that doesnt use a texture and uses noise instead
void main()
{
  vec2
  uv = openfl_TextureCoordv.xy;
  vec2
  offsetUV = vec4(noise(vec2(uv.x, uv.y + (iTime * 0.1)) * vec2(50))).xy;
  offsetUV -= vec2(.5, .5);
  offsetUV *= 2.;
  offsetUV *= 0.01 * 0.1 * strength;
  offsetUV *= (1. + uv.y);
  gl_FragColor = flixel_texture2D(bitmap, uv + offsetUV);
}
