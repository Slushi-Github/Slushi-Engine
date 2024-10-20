  #pragma header

  uniform float multi;

  void main()
  {
    vec2 uv = openfl_TextureCoordv*openfl_TextureSize/openfl_TextureSize.xy;
        uv.x *= multi;
        uv.y *= multi;
          uv = fract(uv);
    vec3 duplicate = vec3(mod(floor(uv.x) + floor(uv.y),1.0));
    vec3 color1 = vec3(flixel_texture2D(bitmap,uv));
    vec3 color;
          color = color1 * (1.0 - duplicate);

    gl_FragColor = vec4(color,flixel_texture2D(bitmap, uv).a);
  }
