#pragma header // https://www.shadertoy.com/view/Xltfzj
// https://xorshaders.weebly.com/tutorials/blur-shaders-5-part-2
uniform float strength;
uniform float loops;
uniform float quality;
float Pi = 6.28318530718; // Pi*2
void main()
{
  vec2
  uv = openfl_TextureCoordv;
  vec4
  color = flixel_texture2D(bitmap, uv);
  vec2
  resolution = vec2(1280.0, 720.0);
  vec2
  rad = strength / openfl_TextureSize;
  for (float d = 0.0;
  d < Pi;
  d += Pi / loops
)
  {
    for (float i = 1.0 / quality;
    i <= 1.0;
    i += 1.0 / quality
  )
    {
      color += flixel_texture2D(bitmap, uv + vec2(cos(d), sin(d)) * rad * i);
    }
  }
  color /= quality * loops - 15.0;
  gl_FragColor = color;
}
