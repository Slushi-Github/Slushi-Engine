#pragma header uniform float red;
uniform float green;
uniform float blue;
void main()
{
  vec4
  spritecolor = flixel_texture2D(bitmap, openfl_TextureCoordv);
  spritecolor.r *= red;
  spritecolor.g *= green;
  spritecolor.b *= blue;
  gl_FragColor = spritecolor;
}
