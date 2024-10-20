    #pragma header

    /*
        Transverse Chromatic Aberration

        Based on https://github.com/FlexMonkey/Filterpedia/blob/7a0d4a7070894eb77b9d1831f689f9d8765c12ca/Filterpedia/customFilters/TransverseChromaticAberration.swift

        Simon Gladman | http://flexmonkey.blogspot.co.uk | September 2017
    */

    int sampleCount = 10;
    float blur = 0.10;
    float falloff = 3.0;

    // use iChannel0 for video, iChannel1 for test grid
    #define INPUT bitmap

    void main(void)
    {
        vec2 destCoord = openfl_TextureCoordv.xy;

        vec2 direction = normalize(destCoord - 0.5);
        vec2 velocity = direction * blur * pow(length(destCoord - 0.5), falloff);
        float inverseSampleCount = 1.0 / float(sampleCount);

        mat3x2 increments = mat3x2(velocity * 1.0 * inverseSampleCount,
                                   velocity * 2.0 * inverseSampleCount,
                                   velocity * 4.0 * inverseSampleCount);

        vec4 accumulator = vec4(0.0);
        mat3x2 offsets = mat3x2(0);

        for (int i = 0; i < sampleCount; i++) {
            accumulator.r += texture2D(INPUT, destCoord + offsets[0]).r;
            accumulator.g += texture2D(INPUT, destCoord + offsets[1]).g;
            accumulator.b += texture2D(INPUT, destCoord + offsets[2]).b;
            accumulator.a += (texture2D(INPUT, destCoord + offsets[0]).a + texture2D(INPUT, destCoord + offsets[1]).a + texture2D(INPUT, destCoord + offsets[2]).a)/3.0;

            offsets -= increments;
        }

        gl_FragColor = vec4(accumulator / float(sampleCount));
    }
