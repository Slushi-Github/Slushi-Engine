#pragma header
uniform float strength;
float nrand(vec2 n)
{
  return fract(sin(dot(n.xy, vec2(12.9898, 78.233))) * 43758.5453);
}
void main()
{
  vec2
  uv = openfl_TextureCoordv.xy;
  vec4
  col = flixel_texture2D(bitmap, uv);
  float
  rnd = sin(uv.y * 1000.0) * strength;
  rnd += nrand(uv) * strength;
  col = flixel_texture2D(bitmap, vec2(uv.x - rnd, uv.y));
  gl_FragColor = col;
}
