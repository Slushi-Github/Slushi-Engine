#pragma header uniform float strength;
void main()
{
  vec2
  uv = openfl_TextureCoordv;
  vec4
  col = flixel_texture2D(bitmap, uv);
  float
  grey = dot(col.rgb, vec3(0.299, 0.587, 0.114)); // https://en.wikipedia.org/wiki/Grayscale
  gl_FragColor = mix(col, vec4(grey, grey, grey, col.a), strength);
}
