    #pragma header
    vec2 uv = openfl_TextureCoordv.xy;
    vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
    vec2 iResolution = openfl_TextureSize;
    #define iChannel0 bitmap
    #define texture flixel_texture2D
    #define fragColor gl_FragColor
    #define mainImage main

    uniform float iTime;

    uniform float amount;

    void main(){
        vec4 textureColor = flixel_texture2D(bitmap, openfl_TextureCoordv);

        textureColor.rgb = textureColor.rgb + vec3(amount);

        gl_FragColor = vec4(textureColor.rgb * textureColor.a, textureColor.a);
    }
