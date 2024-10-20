#pragma header
    vec2 uv = openfl_TextureCoordv.xy;
    vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
    vec2 iResolution = openfl_TextureSize;
    #define iChannel0 bitmap
    #define texture flixel_texture2D
    #define fragColor gl_FragColor
    #define mainImage main

    uniform float texAlpha;
    uniform float saturation;

    uniform sampler2D iChannel1;
    uniform float iTime;

    //Overlay
    vec3 overlay (vec3 target, vec3 blend){
        vec3 temp;
        temp.x = ((target.x > 0.5) ? (1.0-(1.0-2.0*(target.x-0.5))*(1.0-blend.x)) : (2.0*target.x)*blend.x);
        temp.y = ((target.y > 0.5) ? (1.0-(1.0-2.0*(target.y-0.5))*(1.0-blend.y)) : (2.0*target.y)*blend.y);
        temp.z = ((target.z > 0.5) ? (1.0-(1.0-2.0*(target.z-0.5))*(1.0-blend.z)) : (2.0*target.z)*blend.z);

        return temp;
    }

    uniform float threshold;
    uniform float rVal;
    uniform float gVal;
    uniform float bVal;

    void mainImage()
    {
        vec4 tex = texture(bitmap, uv);
        vec4 tex_color = texture(bitmap, uv);


        tex_color.rgb = vec3(dot(tex_color.rgb, vec3(0.299, 0.587, 0.114)));

        if (tex_color.r > threshold){
            tex_color.r = rVal/255.0;
        }

        if (tex_color.g > threshold){
            tex_color.g = gVal/255.0;
        }

        if (tex_color.b > threshold){
            tex_color.b = bVal/255.0;
        }

        //set the color
        fragColor = vec4(tex_color.rgb, tex.a);
    }
