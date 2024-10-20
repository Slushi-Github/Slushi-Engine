#pragma header

    uniform float amount;
    uniform float distortionFactor;

    vec2 uv = openfl_TextureCoordv.xy;
    vec2 center = vec2(0.5, 0.5);

    void main(void) {
        vec2 distortedUV = uv - center;
        float dist = length(distortedUV);
        float distortion = pow(dist, 3.0) * distortionFactor;
        vec4 col;
        col.r = texture2D(bitmap, vec2(uv.x + amount * distortedUV.x + distortion / openfl_TextureSize.x, uv.y + amount * distortedUV.y + distortion / openfl_TextureSize.y)).r;
        col.g = texture2D(bitmap, uv).g;
        col.b = texture2D(bitmap, vec2(uv.x - amount * distortedUV.x - distortion / openfl_TextureSize.x, uv.y - amount * distortedUV.y - distortion / openfl_TextureSize.y)).b;
        col.a = texture2D(bitmap, uv).a;
        gl_FragColor = col;
    }
