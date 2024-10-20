    #pragma header
    vec2 uv = openfl_TextureCoordv.xy;
    vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
    vec2 iResolution = openfl_TextureSize;
    uniform float iTime;
    #define iChannel0 bitmap
    #define texture flixel_texture2D
    #define fragColor gl_FragColor
    #define mainImage main

    float NoiseSeed;
    float randomFloat(){
      NoiseSeed = sin(NoiseSeed) * 5;
      return fract(NoiseSeed);
    }

    float SCurve (float value, float amount, float correction) {

        float curve = 1.0;

        if (value < 0.5)
        {

            curve = pow(value, amount) * pow(2.0, amount) * 0.2;
        }

        else
        {
            curve = 1.0 - pow(1.0 - value, amount) * pow(2.0, amount) * 0.5;
        }

        return pow(curve, correction);
    }




    //ACES tonemapping from: https://www.shadertoy.com/view/wl2SDt
    vec3 ACESFilm(vec3 x)
    {
        float a = 2.51;
        float b = 0.03;
        float c = 2.43;
        float d = 0.59;
        float e = 0.14;
        return (x*(a*x+b))/(x*(c*x+d)+e);
    }




    //Chromatic Abberation from: https://www.shadertoy.com/view/XlKczz
    vec3 chromaticAbberation(sampler2D tex, vec2 uv, float amount)
    {
        float aberrationAmount = amount/5.0;
           vec2 distFromCenter = uv - 0.5;

        // stronger aberration near the edges by raising to power 3
        vec2 aberrated = aberrationAmount * pow(distFromCenter, vec2(3.0, 3.0));

        vec3 color = vec3(0.0);

        for (int i = 1; i <= 8; i++)
        {
            float weight = 1.0 / pow(2.0, float(i));
            color.r += texture(tex, uv - float(i) * aberrated).r * weight;
            color.b += texture(tex, uv + float(i) * aberrated).b * weight;
        }

        color.g = texture(tex, uv).g * 0.9961; // 0.9961 = weight(1)+weight(2)+...+weight(8);

        return color;
    }




    //film grain from: https://www.shadertoy.com/view/wl2SDt
    vec3 filmGrain()
    {
        return vec3(0.9 + randomFloat()*0.15);
    }




    //Sigmoid Contrast from: https://www.shadertoy.com/view/MlXGRf
    vec3 contrast(vec3 color)
    {
        return vec3(SCurve(color.r, 3.0, 1.0),
                    SCurve(color.g, 4.0, 0.7),
                    SCurve(color.b, 2.6, 0.6)
                   );
    }




    //anamorphic-ish flares from: https://www.shadertoy.com/view/MlsfRl
    vec3 flares(sampler2D tex, vec2 uv, float threshold, float intensity, float stretch, float brightness)
    {
        threshold = 1.0 - threshold;

        vec3 hdr = texture(tex, uv).rgb;
        hdr = vec3(floor(threshold+pow(hdr.r, 1.0)));

        float d = intensity; //50.;
        float c = intensity*stretch; //10.;


        //horizontal
        for (float i=c; i>-1.0; i--)
        {
            float texL = texture(tex, uv+vec2(i/d, 0.0)).r;
            float texR = texture(tex, uv-vec2(i/d, 0.0)).r;
            hdr += floor(threshold+pow(max(texL,texR), 4.0))*(1.0-i/c);
        }

        //vertical
        for (float i=c/2.0; i>-1.0; i--)
        {
            float texU = texture(tex, uv+vec2(0.0, i/d)).r;
            float texD = texture(tex, uv-vec2(0.0, i/d)).r;
            hdr += floor(threshold+pow(max(texU,texD), 10.0))*(0.5-i/c) * 0.25;
        }

        hdr *= vec3(0.5,0.4,1.0); //tint

        return hdr*brightness;
    }




    //glow from: https://www.shadertoy.com/view/XslGDr (unused but useful)
    vec3 samplef(vec2 tc, vec3 color)
    {
        return pow(color, vec3(1.0, 1.0, 1.0));
    }

    vec3 highlights(vec3 pixel, float thres)
    {
        float val = (pixel.x + pixel.y + pixel.z) / 3.0;
        return pixel * smoothstep(thres - 0.1, thres + 0.1, val);
    }

    vec3 hsample(vec3 color, vec2 tc)
    {
        return highlights(samplef(tc, color), 0.6);
    }

    vec3 blur(vec3 col, vec2 tc, float offs)
    {
        vec4 xoffs = offs * vec4(-2.0, -1.0, 1.0, 2.0) / iResolution.x;
        vec4 yoffs = offs * vec4(-2.0, -1.0, 1.0, 2.0) / iResolution.y;

        vec3 color = vec3(0.0, 0.0, 0.0);
        color += hsample(col, tc + vec2(xoffs.x, yoffs.x)) * 0.00366;
        color += hsample(col, tc + vec2(xoffs.y, yoffs.x)) * 0.01465;
        color += hsample(col, tc + vec2(    0.0, yoffs.x)) * 0.02564;
        color += hsample(col, tc + vec2(xoffs.z, yoffs.x)) * 0.01465;
        color += hsample(col, tc + vec2(xoffs.w, yoffs.x)) * 0.00366;

        color += hsample(col, tc + vec2(xoffs.x, yoffs.y)) * 0.01465;
        color += hsample(col, tc + vec2(xoffs.y, yoffs.y)) * 0.05861;
        color += hsample(col, tc + vec2(    0.0, yoffs.y)) * 0.09524;
        color += hsample(col, tc + vec2(xoffs.z, yoffs.y)) * 0.05861;
        color += hsample(col, tc + vec2(xoffs.w, yoffs.y)) * 0.01465;

        color += hsample(col, tc + vec2(xoffs.x, 0.0)) * 0;
        color += hsample(col, tc + vec2(xoffs.y, 0.0)) * 0;
        color += hsample(col, tc + vec2(    0.0, 0.0)) * 0;
        color += hsample(col, tc + vec2(xoffs.z, 0.0)) * 0;
        color += hsample(col, tc + vec2(xoffs.w, 0.0)) * 0;

        color += hsample(col, tc + vec2(xoffs.x, yoffs.z)) * 0.01465;
        color += hsample(col, tc + vec2(xoffs.y, yoffs.z)) * 0.05861;
        color += hsample(col, tc + vec2(    0.0, yoffs.z)) * 0.09524;
        color += hsample(col, tc + vec2(xoffs.z, yoffs.z)) * 0.05861;
        color += hsample(col, tc + vec2(xoffs.w, yoffs.z)) * 0.01465;

        color += hsample(col, tc + vec2(xoffs.x, yoffs.w)) * 0;
        color += hsample(col, tc + vec2(xoffs.y, yoffs.w)) * 0;
        color += hsample(col, tc + vec2(    0.0, yoffs.w)) * 0;
        color += hsample(col, tc + vec2(xoffs.z, yoffs.w)) * 0;
        color += hsample(col, tc + vec2(xoffs.w, yoffs.w)) * 0;

        return color;
    }

    vec3 glow(vec3 col, vec2 uv)
    {
        vec3 color = blur(col, uv, 1.0);
        color += blur(col, uv, 1.0);
        color += blur(col, uv, 1.0);
        color += blur(col, uv, 1.0);
        color /= 1.0;

        color += samplef(uv, col);

        return color;
    }




    //margins from: https://www.shadertoy.com/view/wl2SDt
    vec3 margins(vec3 color, vec2 uv, float marginSize)
    {
        if(uv.y < marginSize || uv.y > 1.0-marginSize)
        {
            return vec3(0.0);
        }else{
            return color;
        }
    }




    void mainImage() {

        vec2 uv = fragCoord.xy/iResolution.xy;

        vec3 color = texture(iChannel0, uv).xyz;


        //chromatic abberation
        color = chromaticAbberation(iChannel0, uv, 0.5);


        //film grain
        color *= filmGrain();


        //ACES Tonemapping
          color = ACESFilm(color);


        //contrast
        color = contrast(color) * 0.5;


        //flare
        color += flares(iChannel0, uv, 0.5, 50.0, 0.2, 0.06);


        //margins
        color = margins(color, uv, 0.1);


        //output
        fragColor = vec4(color,texture(iChannel0,uv).a);
    }
