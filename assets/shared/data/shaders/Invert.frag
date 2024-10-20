 #pragma header

    vec2 uv = openfl_TextureCoordv.xy;

    void main(void)
    {
        vec4 tex = texture2D(bitmap, uv);
        tex.r = 1.0-tex.r;
        tex.g = 1.0-tex.g;
        tex.b = 1.0-tex.b;

        gl_FragColor = vec4(tex.r, tex.g, tex.b, tex.a);
    }
