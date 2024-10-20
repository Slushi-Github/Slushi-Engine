   #pragma header

    uniform float flip;

    void main()
    {
        vec2 uv = openfl_TextureCoordv.xy;

        uv.x = abs(uv.x + flip);

        gl_FragColor = texture2D(bitmap, uv);
    }
