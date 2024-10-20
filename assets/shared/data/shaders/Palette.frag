#pragma header uniform float strength;
uniform float paletteSize;
float palette(float val, float size)
{
  float
  f = floor(val * (size - 1.0) + 0.5);
  return f / (size - 1.0);
}
void main()
{
  vec2
  uv = openfl_TextureCoordv;
  vec4
  col = flixel_texture2D(bitmap, uv);
  vec4
  reducedCol = vec4(col.r, col.g, col.b, col.a);
  reducedCol.r = palette(reducedCol.r, 8.0);
  reducedCol.g = palette(reducedCol.g, 8.0);
  reducedCol.b = palette(reducedCol.b, 8.0);
  gl_FragColor = mix(col, reducedCol, strength);
}
