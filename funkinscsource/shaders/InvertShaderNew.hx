package shaders;

class InvertShaderNew extends FlxFixedShader
{
  @:glFragmentSource('
	#pragma header

	void main()
	{
		vec4 texture = flixel_texture2D(bitmap, openfl_TextureCoordv.xy) / openfl_Alphav;
		float alpha = texture.a * openfl_Alphav;

		gl_FragColor = vec4((vec3(1.0, 1.0, 1.0) - texture.rgb) * alpha, alpha);
	}
	')
  public function new()
  {
    super();
  }
}
