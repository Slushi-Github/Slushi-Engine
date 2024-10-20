#pragma header

    // original: https://www.shadertoy.com/view/flfBW4, ported with shaderToy to Flixel

    uniform float iTime;

    vec2 iResolution = openfl_TetureSize;
    vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;

    void mainImage()
    {
      // Normalized pixel coordinates (from 0 to 1)
      vec2 uv = openfl_TextureCoordv.xy;
      vec4 texture = flixel_texture2D(bitmap, uv);

      // Time varying pixel color
      vec3 col = 0.5 + 0.5*cos(3.0 * iTime+uv.xyx+vec3(0.0,2.0,4.0))*cos(5.0 * iTime+uv.xyx+vec3(2.0,3.0,-1.0));

      texture.rgb *= col;

      // Output to screen
      gl_FragColor = vec4(texture);
    }
