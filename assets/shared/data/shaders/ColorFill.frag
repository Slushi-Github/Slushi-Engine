  #pragma header
  uniform float red;
uniform float green;
uniform float blue;
uniform float fade;
void main()
{
  vec4
  spritecolor = flixel_texture2D(bitmap, openfl_TextureCoordv);
  vec4
  col = vec4(red / 255, green / 255, blue / 255, spritecolor.a);
  vec3
  finalCol = mix(col.rgb * spritecolor.a, spritecolor.rgb, fade);
  gl_FragColor = vec4(finalCol.r, finalCol.g, finalCol.b, spritecolor.a);
}
