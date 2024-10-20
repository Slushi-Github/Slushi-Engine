 #pragma header

        const float PI = 3.14159265358;
        uniform float percent;

        vec2 rotate(vec2 v, float a) {
            float s = sin(a);
            float c = cos(a);
            mat2 m = mat2(c, -s, s, c);
            return m * v;
        }

        void main()
        {
            vec2 uv = openfl_TextureCoordv;
            vec4 spritecolor = flixel_texture2D(bitmap, openfl_TextureCoordv);

            //rotate uv so circle matches properly
            uv -= vec2(0.5, 0.5);
            uv = rotate(uv, PI*0.5);
            uv += vec2(0.5, 0.5);

            float percentAngle = (percent*360.0) / (180.0/PI);

            vec2 center = vec2(0.5, 0.5);
            float radius = 0.5;
            float angle = atan(uv.y - center.y, uv.x - center.x);
            float distance = length(uv - center);

            if ((angle + (PI)) > percentAngle)
            {
                spritecolor = vec4(0.0,0.0,0.0,0.0);
            }

            gl_FragColor = spritecolor;
        }
