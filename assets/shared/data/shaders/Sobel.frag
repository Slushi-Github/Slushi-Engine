#pragma header uniform float strength;
uniform float intensity;
void main()
{
  vec2
  uv = openfl_TextureCoordv;
  vec4
  col = flixel_texture2D(bitmap, uv);
  vec2
  resFactor = (1 / openfl_TextureSize.xy) * intensity;
  if (strength <= 0)
  {
    gl_FragColor = col;
    return;
  }
  // https://en.wikipedia.org/wiki/Sobel_operator
  // adsjklalskdfjhaslkdfhaslkdfhj
  vec4
  topLeft = flixel_texture2D(bitmap, vec2(uv.x - resFactor.x, uv.y - resFactor.y));
  vec4
  topMiddle = flixel_texture2D(bitmap, vec2(uv.x, uv.y - resFactor.y));
  vec4
  topRight = flixel_texture2D(bitmap, vec2(uv.x + resFactor.x, uv.y - resFactor.y));
  vec4
  midLeft = flixel_texture2D(bitmap, vec2(uv.x - resFactor.x, uv.y));
  vec4
  midRight = flixel_texture2D(bitmap, vec2(uv.x + resFactor.x, uv.y));
  vec4
  bottomLeft = flixel_texture2D(bitmap, vec2(uv.x - resFactor.x, uv.y + resFactor.y));
  vec4
  bottomMiddle = flixel_texture2D(bitmap, vec2(uv.x, uv.y + resFactor.y));
  vec4
  bottomRight = flixel_texture2D(bitmap, vec2(uv.x + resFactor.x, uv.y + resFactor.y));
  vec4
  Gx = (topLeft) + (2 * midLeft) + (bottomLeft) - (topRight) - (2 * midRight) - (bottomRight);
  vec4
  Gy = (topLeft) + (2 * topMiddle) + (topRight) - (bottomLeft) - (2 * bottomMiddle) - (bottomRight);
  vec4
  G = sqrt((Gx * Gx) + (Gy * Gy));
  gl_FragColor = mix(col, G, strength);
}
