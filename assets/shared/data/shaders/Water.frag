#pragma header
uniform float iTime;
uniform float strength;
vec2 mirror(vec2 uv)
{
  if ((uv.x > 1.0 || uv.x < 0.0) && abs(mod(uv.x, 2.0)) > 1.0) uv.x = (0.0 - uv.x) + 1.0;
  if ((uv.y > 1.0 || uv.y < 0.0) && abs(mod(uv.y, 2.0)) > 1.0) uv.y = (0.0 - uv.y) + 1.0;
  return vec2(abs(mod(uv.x, 1.0)), abs(mod(uv.y, 1.0)));
}
vec2 warp(vec2 uv)
{
  vec2
  warp = strength * (uv + iTime);
  uv = vec2(cos(warp.x - warp.y) * cos(warp.y), sin(warp.x - warp.y) * sin(warp.y));
  return uv;
}
void main()
{
  vec2
  uv = openfl_TextureCoordv.xy;
  vec4
  col = flixel_texture2D(bitmap, mirror(uv + (warp(uv) - warp(uv + 1.0)) * (0.0035)));
  gl_FragColor = col;
}
