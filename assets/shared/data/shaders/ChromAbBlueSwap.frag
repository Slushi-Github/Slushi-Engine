#pragma header uniform float strength;
void main()
{
  vec2
  uv = openfl_TextureCoordv;
  vec4
  col = flixel_texture2D(bitmap, uv);
  col.r = flixel_texture2D(bitmap, vec2(uv.x + strength, uv.y)).r;
  col.g = flixel_texture2D(bitmap, vec2(uv.x - strength, uv.y)).g;
  col = col * (1.0 - strength * 0.5);
  gl_FragColor = col;
}
