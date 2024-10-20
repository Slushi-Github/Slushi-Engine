#pragma header // written by TheZoroForce240
uniform float zoom;
uniform float angle;
uniform float iTime;
uniform float x;
uniform float y;
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
  iResolution = vec2(1280, 720);
  // rotation bullshit
  vec2
  center = vec2(0.5, 0.5);
  vec2
  uv = openfl_TextureCoordv.xy;
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
  uv = (fragCoordShit - .5 * iResolution.xy) / iResolution.y; // this helped a little, specifically the guy in the comments: https://www.shadertoy.com/view/tsSXzt
  uv = uv * scaling;
  uv = (aspectRatioShit) * (rotation * uv);
  uv = uv.xy + center; // move back to center
  gl_FragColor = render(uv);
}
