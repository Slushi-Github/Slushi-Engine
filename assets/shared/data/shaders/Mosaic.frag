#pragma header uniform float strength;
void main()
{
  if (strength == 0.0)
  {
    gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
    return;
  }
  vec2
  blocks = openfl_TextureSize / vec2(strength, strength);
  gl_FragColor = flixel_texture2D(bitmap, floor(openfl_TextureCoordv * blocks) / blocks);
}
