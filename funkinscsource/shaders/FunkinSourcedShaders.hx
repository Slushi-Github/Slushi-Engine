package shaders;

// STOLEN FROM HAXEFLIXEL DEMO LOL
// Am I even allowed to use this?
// Blantados code! Thanks!!
import flixel.graphics.tile.FlxGraphicsShader;
import flixel.math.FlxAngle;
#if (!flash && sys)
import flixel.addons.display.FlxRuntimeShader;
#end
import openfl.display.GraphicsShader;
import openfl.display.Shader;
import openfl.utils.Assets;
import openfl.Lib;
import haxe.Json;
import codenameengine.shaders.FunkinShader;

// For stoping crashes when a shader can't compile
import slushi.slushiUtils.shaders.SLEFlxShaderUtil;

class ShaderBase
{
  public var id:String = null;
  public var tweens:Array<FlxTween> = [];

  public function canUpdate():Bool
    return true;

  public function update(elapsed:Float) {}

  public function getShader() {}

  public function clear() {}

  public function destroy() {}
}

  // Slushi Shaders:
class Chessboard3DEffect extends ShaderBase
{
	public var shader:Chessboard3DShader = new Chessboard3DShader();

	public var xRot:Float = 0;
	public var yRot:Float = 0;
  public var zRot:Float = 0;
  public var color1:Array<Int> = [255, 255, 255];
  public var color2:Array<Int> = [0, 0, 0];
  var time:Float;

	public function new():Void
	{
    shader.xRot.value = [xRot];
    shader.yRot.value = [yRot];
    shader.zRot.value = [zRot];
    shader.color1.value = [color1[0], color1[1], color1[2]];
    shader.color2.value = [color2[0], color2[1], color2[2]];
    time = 0;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

    shader.xRot.value = [xRot];
    shader.yRot.value = [yRot];
    shader.zRot.value = [zRot];
    shader.color1.value = [color1[0], color1[1], color1[2]];
    shader.color2.value = [color2[0], color2[1], color2[2]];
    time += elapsed;
    shader.iTime.value = [time];
	}
}

class Chessboard3DShader extends SLEFlxShaderUtil
{
	@:glFragmentSource('
    #pragma header
    vec2 uv = openfl_TextureCoordv.xy;
    vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
    vec2 iResolution = openfl_TextureSize;
    uniform float iTime;
    #define iChannel0 bitmap
    #define texture flixel_texture2D
    #define fragColor gl_FragColor
    #define mainImage main
    //****MAKE SURE TO remove the parameters from mainImage.
    //SHADERTOY PORT FIXin vec2 TexCoord;

    uniform float xRot;
    uniform float yRot;
    uniform float zRot;
    uniform vec3 color1; // Color for the first part of the pattern
    uniform vec3 color2; // Color for the second part of the pattern

    mat3 rotX(float angle) {
        float s = sin(angle); 
        float c = cos(angle);
        return mat3(1., 0., 0., 0., c, s, 0., -s, c);
    }

    mat3 rotY(float angle) {
        float s = sin(angle); 
        float c = cos(angle);
        return mat3(c, 0., -s, 0., 1., 0., s, 0.0, c);
    }

    mat3 rotZ(float angle) {
        float s = sin(angle); 
        float c = cos(angle);
        return mat3(c, s, 0., -s, c, 0., 0., 0., 1.);
    }

  void mainImage()
  {
      vec2 uv = 2. * fragCoord / iResolution.xy - 1.;
      vec3 ray = vec3(uv.x, uv.y * iResolution.y / iResolution.x, 1.);
      ray = ray * rotX(xRot) * rotY(yRot) * rotZ(zRot);
      float z = abs(1. / ray.y);    
      vec2 chess = fract(ray.xz * z) - .5;    
      vec2 offset = 3. * vec2(cos(iTime), sin(iTime));
      chess += offset;
      vec3 patternColor = mix(color1, color2, sign(chess.x * chess.y) * 0.5 + 0.5);
      fragColor = vec4(patternColor, 1.0) * smoothstep(10., 1., z);
  }

  ')
	public function new()
	{
		super();
	}
}

class MatrixEffect extends ShaderBase
{
    public var shader:MatrixShader = new MatrixShader();

    public var iterations:Int = 0;
    public var speed:Float = 0;
    var time:Float = 0;

    public function new()
    {
        shader.iTime.value = [0.0];

        shader.ITERATIONS.value = [iterations];
        shader.SPEED.value = [speed];
    }

    override public function update(elapsed:Float)
    {
        time += elapsed;
        shader.iTime.value = [time];

        shader.ITERATIONS.value = [iterations];
        shader.SPEED.value = [speed];
    }
}

class MatrixShader extends SLEFlxShaderUtil
{
    @:glFragmentSource('
    #pragma header
    vec2 uv = openfl_TextureCoordv.xy;
    vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
    vec2 iResolution = openfl_TextureSize;
    uniform float iTime;
    #define iChannel0 bitmap
    #define texture flixel_texture2D
    #define fragColor gl_FragColor
    #define mainImage main
    //****MAKE SURE TO remove the parameters from mainImage.
    //SHADERTOY PORT FIXin vec2 TexCoord;
    struct TextureData {
        vec2 scaledCoord;
        float scale;
    };

            /*
        Feel free to do anything you want with this code.
        This shader uses "runes" code by FabriceNeyret2 (https://www.shadertoy.com/view/4ltyDM)
        which is based on "runes" by otaviogood (https://shadertoy.com/view/MsXSRn).
        These random runes look good as matrix symbols and have acceptable performance.
        */

        uniform int ITERATIONS;   //use less value if you need more performance
        uniform float SPEED;

        const float STRIP_CHARS_MIN =  7.;
        const float STRIP_CHARS_MAX = 40.;
        const float STRIP_CHAR_HEIGHT = 0.15;
        const float STRIP_CHAR_WIDTH = 0.10;
        const float ZCELL_SIZE = 1. * (STRIP_CHAR_HEIGHT * STRIP_CHARS_MAX);  
        const float XYCELL_SIZE = 12. * STRIP_CHAR_WIDTH;

        const int BLOCK_SIZE = 10;  //in cells
        const int BLOCK_GAP = 2;    //in cells

        const float WALK_SPEED = 1. * XYCELL_SIZE;
        const float BLOCKS_BEFORE_TURN = 3.;


        const float PI = 3.14159265359;


        //        ----  random  ----

        float hash(float v) {
            return fract(sin(v)*43758.5453123);
        }

        float hash(vec2 v) {
            return hash(dot(v, vec2(5.3983, 5.4427)));
        }

        vec2 hash2(vec2 v)
        {
            v = vec2(v * mat2(127.1, 311.7,  269.5, 183.3));
            return fract(sin(v)*43758.5453123);
        }

        vec4 hash4(vec2 v)
        {
            vec4 p = vec4(v * mat4x2( 127.1, 311.7,
                                    269.5, 183.3,
                                    113.5, 271.9,
                                    246.1, 124.6 ));
            return fract(sin(p)*43758.5453123);
        }

        vec4 hash4(vec3 v)
        {
            vec4 p = vec4(v * mat4x3( 127.1, 311.7, 74.7,
                                    269.5, 183.3, 246.1,
                                    113.5, 271.9, 124.6,
                                    271.9, 269.5, 311.7 ) );
            return fract(sin(p)*43758.5453123);
        }


        //        ----  symbols  ----
        //  Slightly modified version of "runes" by FabriceNeyret2 -  https://www.shadertoy.com/view/4ltyDM
        //  Which is based on "runes" by otaviogood -  https://shadertoy.com/view/MsXSRn

        float rune_line(vec2 p, vec2 a, vec2 b) {   // from https://www.shadertoy.com/view/4dcfW8
            p -= a, b -= a;
            float h = clamp(dot(p, b) / dot(b, b), 0., 1.);   // proj coord on line
            return length(p - b * h);                         // dist to segment
        }

        float rune(vec2 U, vec2 seed, float highlight)
        {
            float d = 1e5;
            for (int i = 0; i < 4; i++)	// number of strokes
            {
                vec4 pos = hash4(seed);
                seed += 1.;

                // each rune touches the edge of its box on all 4 sides
                if (i == 0) pos.y = .0;
                if (i == 1) pos.x = .999;
                if (i == 2) pos.x = .0;
                if (i == 3) pos.y = .999;
                // snap the random line endpoints to a grid 2x3
                vec4 snaps = vec4(2, 3, 2, 3);
                pos = ( floor(pos * snaps) + .5) / snaps;

                if (pos.xy != pos.zw)  //filter out single points (when start and end are the same)
                    d = min(d, rune_line(U, pos.xy, pos.zw + .001) ); // closest line
            }
            return smoothstep(0.1, 0., d) + highlight*smoothstep(0.4, 0., d);
        }

        float random_char(vec2 outer, vec2 inner, float highlight) {
            vec2 seed = vec2(dot(outer, vec2(269.5, 183.3)), dot(outer, vec2(113.5, 271.9)));
            return rune(inner, seed, highlight);
        }


        //        ----  digital rain  ----

        // xy - horizontal, z - vertical
        vec3 rain(vec3 ro3, vec3 rd3, float time) {
            vec4 result = vec4(0.);

            // normalized 2d projection
            vec2 ro2 = vec2(ro3);
            vec2 rd2 = normalize(vec2(rd3));

            // we use formulas `ro3 + rd3 * t3` and `ro2 + rd2 * t2`, `t3_to_t2` is a multiplier to convert t3 to t2
            bool prefer_dx = abs(rd2.x) > abs(rd2.y);
            float t3_to_t2 = prefer_dx ? rd3.x / rd2.x : rd3.y / rd2.y;

            // at first, horizontal space (xy) is divided into cells (which are columns in 3D)
            // then each xy-cell is divided into vertical cells (along z) - each of these cells contains one raindrop

            ivec3 cell_side = ivec3(step(0., rd3));      //for positive rd.x use cell side with higher x (1) as the next side, for negative - with lower x (0), the same for y and z
            ivec3 cell_shift = ivec3(sign(rd3));         //shift to move to the next cell

            //  move through xy-cells in the ray direction
            float t2 = 0.;  // the ray formula is: ro2 + rd2 * t2, where t2 is positive as the ray has a direction.
            ivec2 next_cell = ivec2(floor(ro2/XYCELL_SIZE));  //first cell index where ray origin is located
            for (int i=0; i<ITERATIONS; i++) {
                ivec2 cell = next_cell;  //save cell value before changing
                float t2s = t2;          //and t

                //  find the intersection with the nearest side of the current xy-cell (since we know the direction, we only need to check one vertical side and one horizontal side)
                vec2 side = vec2(next_cell + cell_side.xy) * XYCELL_SIZE;  //side.x is x coord of the y-axis side, side.y - y of the x-axis side
                vec2 t2_side = (side - ro2) / rd2;  // t2_side.x and t2_side.y are two candidates for the next value of t2, we need the nearest
                if (t2_side.x < t2_side.y) {
                    t2 = t2_side.x;
                    next_cell.x += cell_shift.x;  //cross through the y-axis side
                } else {
                    t2 = t2_side.y;
                    next_cell.y += cell_shift.y;  //cross through the x-axis side
                }
                //now t2 is the value of the end point in the current cell (and the same point is the start value in the next cell)

                //  gap cells
                vec2 cell_in_block = fract(vec2(cell) / float(BLOCK_SIZE));
                float gap = float(BLOCK_GAP) / float(BLOCK_SIZE);
                if (cell_in_block.x < gap || cell_in_block.y < gap || (cell_in_block.x < (gap+0.1) && cell_in_block.y < (gap+0.1))) {
                    continue;
                }

                //  return to 3d - we have start and end points of the ray segment inside the column (t3s and t3e)
                float t3s = t2s / t3_to_t2;
                float pos_z = ro3.z + rd3.z * t3s;
                float xycell_hash = hash(vec2(cell));
                float z_shift = xycell_hash*11. - time * (0.5 + xycell_hash * 1.0 + xycell_hash * xycell_hash * 1.0 + pow(xycell_hash, 16.) * 3.0);  //a different z shift for each xy column
                float char_z_shift = floor(z_shift / STRIP_CHAR_HEIGHT);
                z_shift = char_z_shift * STRIP_CHAR_HEIGHT;
                int zcell = int(floor((pos_z - z_shift)/ZCELL_SIZE));  //z-cell index
                for (int j=0; j<2; j++) {  
                    //  calcaulate coordinates of the target (raindrop)
                    vec4 cell_hash = hash4(vec3(ivec3(cell, zcell)));
                    vec4 cell_hash2 = fract(cell_hash * vec4(127.1, 311.7, 271.9, 124.6));

                    float chars_count = cell_hash.w * (STRIP_CHARS_MAX - STRIP_CHARS_MIN) + STRIP_CHARS_MIN;
                    float target_length = chars_count * STRIP_CHAR_HEIGHT;
                    float target_rad = STRIP_CHAR_WIDTH / 2.;
                    float target_z = (float(zcell)*ZCELL_SIZE + z_shift) + cell_hash.z * (ZCELL_SIZE - target_length);
                    vec2 target = vec2(cell) * XYCELL_SIZE + target_rad + cell_hash.xy * (XYCELL_SIZE - target_rad*2.);

                    //  We have a line segment (t0,t). Now calculate the distance between line segment and cell target 
                    vec2 s = target - ro2;
                    float tmin = dot(s, rd2);  //tmin - point with minimal distance to target
                    if (tmin >= t2s && tmin <= t2) {
                        float u = s.x * rd2.y - s.y * rd2.x;  //horizontal coord in the matrix strip
                        if (abs(u) < target_rad) {
                            u = (u/target_rad + 1.) / 2.;
                            float z = ro3.z + rd3.z * tmin/t3_to_t2;
                            float v = (z - target_z) / target_length;  //vertical coord in the matrix strip
                            if (v >= 0.0 && v < 1.0) {
                                float c = floor(v * chars_count);  //symbol index relative to the start of the strip, with addition of char_z_shift it becomes an index relative to the whole cell
                                float q = fract(v * chars_count);
                                vec2 char_hash = hash2(vec2(c+char_z_shift, cell_hash2.x));
                                if (char_hash.x >= 0.1 || c == 0.) {  //10% of missed symbols
                                    float time_factor = floor(c == 0. ? time*5.0 :  //first symbol is changed fast
                                            time*(1.0*cell_hash2.z +   //strips are changed sometime with different speed
                                                    cell_hash2.w*cell_hash2.w*4.*pow(char_hash.y, 4.)));  //some symbols in some strips are changed relatively often
                                    float a = random_char(vec2(char_hash.x, time_factor), vec2(u,q), max(1., 3. - c/2.)*0.2);  //alpha
                                    a *= clamp((chars_count - 0.5 - c) / 2., 0., 1.);  //tail fade
                                    if (a > 0.) {
                                        float attenuation = 1. + pow(0.06*tmin/t3_to_t2, 2.);
                                        vec3 col = (c == 0. ? vec3(0.67, 1.0, 0.82) : vec3(0.25, 0.80, 0.40)) / attenuation;
                                        float a1 = result.a;
                                        result.a = a1 + (1. - a1) * a;
                                        result.xyz = (result.xyz * a1 + col * (1. - a1) * a) / result.a;
                                        if (result.a > 0.98)  return result.xyz;
                                    }
                                }
                            }
                        }
                    }
                    // not found in this cell - go to next vertical cell
                    zcell += cell_shift.z;
                }
                // go to next horizontal cell
            }

            return result.xyz * result.a;
        }


        //        ----  main, camera  ----

        vec2 rotate(vec2 v, float a) {
            float s = sin(a);
            float c = cos(a);
            mat2 m = mat2(c, -s, s, c);
            return m * v;
        }

        vec3 rotateX(vec3 v, float a) {
            float s = sin(a);
            float c = cos(a);
            return mat3(1.,0.,0.,0.,c,-s,0.,s,c) * v;
        }

        vec3 rotateY(vec3 v, float a) {
            float s = sin(a);
            float c = cos(a);
            return mat3(c,0.,-s,0.,1.,0.,s,0.,c) * v;
        }

        vec3 rotateZ(vec3 v, float a) {
            float s = sin(a);
            float c = cos(a);
            return mat3(c,-s,0.,s,c,0.,0.,0.,1.) * v;
        }

        float smoothstep1(float x) {
            return smoothstep(0., 1., x);
        }

        void mainImage()
        {
            if (STRIP_CHAR_WIDTH > XYCELL_SIZE || STRIP_CHAR_HEIGHT * STRIP_CHARS_MAX > ZCELL_SIZE) {
                // error
                fragColor = vec4(1., 0., 0., 1.);
                return;
            }

            vec2 uv = (fragCoord.xy * 2. - iResolution.xy) / iResolution.y;

            float time = iTime * SPEED;

            const float turn_rad = 0.25 / BLOCKS_BEFORE_TURN;   //0 .. 0.5
            const float turn_abs_time = (PI/2.*turn_rad) * 1.5;  //multiplier different than 1 means a slow down on turns
            const float turn_time = turn_abs_time / (1. - 2.*turn_rad + turn_abs_time);  //0..1, but should be <= 0.5

            float level1_size = float(BLOCK_SIZE) * BLOCKS_BEFORE_TURN * XYCELL_SIZE;
            float level2_size = 4. * level1_size;
            float gap_size = float(BLOCK_GAP) * XYCELL_SIZE;

            vec3 ro = vec3(gap_size/2., gap_size/2., 0.);
            vec3 rd = vec3(uv.x, 2.0, uv.y);

            float tq = fract(time / (level2_size*4.) * WALK_SPEED);  //the whole cycle time counter
            float t8 = fract(tq*4.);  //time counter while walking on one of the four big sides
            float t1 = fract(t8*8.);  //time counter while walking on one of the eight sides of the big side

            vec2 prev;
            vec2 dir;
            if (tq < 0.25) {
                prev = vec2(0.,0.);
                dir = vec2(0.,1.);
            } else if (tq < 0.5) {
                prev = vec2(0.,1.);
                dir = vec2(1.,0.);
            } else if (tq < 0.75) {
                prev = vec2(1.,1.);
                dir = vec2(0.,-1.);
            } else {
                prev = vec2(1.,0.);
                dir = vec2(-1.,0.);
            }
            float angle = floor(tq * 4.);  //0..4 wich means 0..2*PI

            prev *= 4.;

            const float first_turn_look_angle = 0.4;
            const float second_turn_drift_angle = 0.5;
            const float fifth_turn_drift_angle = 0.25;

            vec2 turn;
            float turn_sign = 0.;
            vec2 dirL = rotate(dir, -PI/2.);
            vec2 dirR = -dirL;
            float up_down = 0.;
            float rotate_on_turns = 1.;
            float roll_on_turns = 1.;
            float add_angel = 0.;
            if (t8 < 0.125) {
                turn = dirL;
                //dir = dir;
                turn_sign = -1.;
                angle -= first_turn_look_angle * (max(0., t1 - (1. - turn_time*2.)) / turn_time - max(0., t1 - (1. - turn_time)) / turn_time * 2.5);
                roll_on_turns = 0.;
            } else if (t8 < 0.250) {
                prev += dir;
                turn = dir;
                dir = dirL;
                angle -= 1.;
                turn_sign = 1.;
                add_angel += first_turn_look_angle*0.5 + (-first_turn_look_angle*0.5+1.0+second_turn_drift_angle)*t1;
                rotate_on_turns = 0.;
                roll_on_turns = 0.;
            } else if (t8 < 0.375) {
                prev += dir + dirL;
                turn = dirR;
                //dir = dir;
                turn_sign = 1.;
                add_angel += second_turn_drift_angle*sqrt(1.-t1);
                //roll_on_turns = 0.;
            } else if (t8 < 0.5) {
                prev += dir + dir + dirL;
                turn = dirR;
                dir = dirR;
                angle += 1.;
                turn_sign = 0.;
                up_down = sin(t1*PI) * 0.37;
            } else if (t8 < 0.625) {
                prev += dir + dir;
                turn = dir;
                dir = dirR;
                angle += 1.;
                turn_sign = -1.;
                up_down = sin(-min(1., t1/(1.-turn_time))*PI) * 0.37;
            } else if (t8 < 0.750) {
                prev += dir + dir + dirR;
                turn = dirL;
                //dir = dir;
                turn_sign = -1.;
                add_angel -= (fifth_turn_drift_angle + 1.) * smoothstep1(t1);
                rotate_on_turns = 0.;
                roll_on_turns = 0.;
            } else if (t8 < 0.875) {
                prev += dir + dir + dir + dirR;
                turn = dir;
                dir = dirL;
                angle -= 1.;
                turn_sign = 1.;
                add_angel -= fifth_turn_drift_angle - smoothstep1(t1) * (fifth_turn_drift_angle * 2. + 1.);
                rotate_on_turns = 0.;
                roll_on_turns = 0.;
            } else {
                prev += dir + dir + dir;
                turn = dirR;
                //dir = dir;
                turn_sign = 1.;-
                angle += fifth_turn_drift_angle * (1.5*min(1., (1.-t1)/turn_time) - 0.5*smoothstep1(1. - min(1.,t1/(1.-turn_time))));
            }

        
            angle += add_angel;
            
            rd = rotateX(rd, up_down);

            vec2 p;
            if (turn_sign == 0.) {
                //  move forward
                p = prev + dir * (turn_rad + 1. * t1);
            }
            else if (t1 > (1. - turn_time)) {
                //  turn
                float tr = (t1 - (1. - turn_time)) / turn_time;
                vec2 c = prev + dir * (1. - turn_rad) + turn * turn_rad;
                p = c + turn_rad * rotate(dir, (tr - 1.) * turn_sign * PI/2.);
                angle += tr * turn_sign * rotate_on_turns;
                rd = rotateY(rd, sin(tr*turn_sign*PI) * 0.2 * roll_on_turns);  //roll
            }  else  {
                //  move forward
                t1 /= (1. - turn_time);
                p = prev + dir * (turn_rad + (1. - turn_rad*2.) * t1);
            }

            rd = rotateZ(rd, angle * PI/2.);

            ro.xy += level1_size * p;

            ro += rd * 0.2;
            rd = normalize(rd);

            vec3 col = rain(ro, rd, time);

            fragColor = vec4(col, 1.);
        }
    ')

    public function new()
    {
        super();
    }
}

class TunnelFractEffect extends ShaderBase
{
    public var shader:TunnelFractShader = new TunnelFractShader();

    public var valuemult:Float = 0;
    var iTime:Float = 0;

    public function new()
    {
        shader.iTime.value = [0.0];
        shader.valuemult.value = [valuemult];
    }

    override public function update(elapsed:Float)
    {
        iTime += elapsed;
        shader.iTime.value = [iTime];
        shader.valuemult.value = [valuemult];
    }
}

class TunnelFractShader extends SLEFlxShaderUtil
{
    @:glFragmentSource('
    //SHADERTOY PORT FIX
    #pragma header
    vec2 uv = openfl_TextureCoordv.xy;
    vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
    vec2 iResolution = openfl_TextureSize;
    uniform float iTime;
    #define iChannel0 bitmap
    #define texture flixel_texture2D
    #define fragColor gl_FragColor
    #define mainImage main
    //****MAKE SURE TO remove the parameters from mainImage.
    //SHADERTOY PORT FIXin vec2 TexCoord;
    struct TextureData {
        vec2 scaledCoord;
        float scale;
    };
    
    vec2 rotateUV(vec2 uv, float angle) {
        float s = sin(angle);
        float c = cos(angle);
        mat2 rotationMatrix = mat2(c, -s, s, c);
        return rotationMatrix * uv;
    }
    
    uniform float valuemult;
    
    void main()
    {
        int numDuplicates = 5; // Number of times to duplicate the texture
        if (numDuplicates == 0 || valuemult == 0){
            fragColor = texture(bitmap,uv);
            return;
        }
    
        TextureData textures[5]; // Array to hold texture data
        for (int i = 0; i < numDuplicates; ++i) {
            float mult = -2 * valuemult; // Scale factor for each iteration
            float scale = 1.0 - float(i) * mult;
            
            float period = -mult*numDuplicates;
            
            // Adjust the 0.1 factor to control the speed of the tunnelling effect
            float scaletunnel = mod(scale - iTime*4*valuemult, period);
            
            // Reset back to the 4th iteration scale (0.7) once it reaches the period
            if (scaletunnel >= period) {
                scaletunnel = 0.7;
            }
            
            textures[i].scale = scaletunnel;
            
            // Calculate offset based on scale to keep textures centered
            vec2 offset = vec2((1.0 - (scaletunnel-valuemult)) * 0.5);
            float angle = sin(scaletunnel/4 + iTime) * 0.15;
            vec2 rotatedUV = rotateUV(uv, angle);
    
            textures[i].scaledCoord = uv - 0.5 + rotatedUV * (scaletunnel-valuemult) + offset;
        }
    
        // Sort the textures array based on scale (from smallest to largest scale)
        for (int i = 0; i < numDuplicates; ++i) {
            for (int j = i + 1; j < numDuplicates; ++j) {
                if (textures[i].scale < textures[j].scale) {
                    TextureData temp = textures[i];
                    textures[i] = textures[j];
                    textures[j] = temp;
                }
            }
        }
    
        vec4 finalColor = vec4(0.0);
    
        for (int i = 0; i < numDuplicates; ++i) {
            // Check if the current sampling coordinate is within the valid UV range (0.0 to 1.0)
            if (textures[i].scaledCoord.x >= 0.0 && textures[i].scaledCoord.x <= 1.0 &&
                textures[i].scaledCoord.y >= 0.0 && textures[i].scaledCoord.y <= 1.0) {
                // Sample the texture
                vec4 texColor = texture2D(bitmap, textures[i].scaledCoord);
                // Apply alpha blending
                finalColor = texColor + (1.0 - texColor.a) * finalColor;
            }
        }
    
        fragColor = finalColor;
    }
    ')

    public function new()
    {
        super();
    }
}

class ScrollWarpEffect extends ShaderBase
{
    public var shader:ScrollShader = new ScrollShader();
    public var timeMulti(default, set):Float = 0.2;
    public var xSpeed(default, set):Float = 0.5;
    public var ySpeed(default, set):Float = 0.0;
    var iTime:Float = 0;

    public function new()
    {
        shader.iTime.value = [iTime];
        shader.timeMulti.value = [timeMulti];
        shader.xSpeed.value = [xSpeed];
        shader.ySpeed.value = [ySpeed];
    }

    override public function update(elapsed:Float)
    {
        iTime += elapsed;
        shader.iTime.value = [iTime];
        shader.timeMulti.value = [timeMulti];
        shader.xSpeed.value = [xSpeed];
        shader.ySpeed.value = [ySpeed];
    }

    function set_timeMulti(value:Float)
    {
        timeMulti = value;
        shader.timeMulti.value = [timeMulti];
        return value;
    }
    function set_xSpeed(value:Float)
    {
        xSpeed = value;
        shader.xSpeed.value = [xSpeed];
        return value;
    }
    function set_ySpeed(value:Float)
    {
        ySpeed = value;
        shader.ySpeed.value = [ySpeed];
        return value;
    }
}

class ScrollShader extends SLEFlxShaderUtil
{
    @:glFragmentSource('
    //SHADERTOY PORT FIX
    #pragma header
    vec2 uv = openfl_TextureCoordv.xy;
    vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
    vec2 iResolution = openfl_TextureSize;
    uniform float iTime;
    uniform float timeMulti;
    uniform float xSpeed;
    uniform float ySpeed;
    #define iChannel0 bitmap
    #define texture flixel_texture2D
    #define fragColor gl_FragColor
    #define mainImage main
    #define time iTime
    //SHADERTOY PORT FIX
    
    // https://www.shadertoy.com/view/WtGGRt
    
    void mainImage()
    {
        // Normalized pixel coordinates (from 0 to 1)
        //vec2 uv = fragCoord/iResolution.xy;
        
        float time = iTime * timeMulti;
        
        // no floor makes it squiqqly
        float xCoord = floor(fragCoord.x + time * xSpeed * iResolution.x);
        float yCoord = floor(fragCoord.y + time * ySpeed * iResolution.y);
        
        vec2 coord = vec2(xCoord, yCoord);
        coord = mod(coord, iResolution.xy);

        vec2 uv = coord/iResolution.xy;
        // Time varying pixel color
        //vec3 col = 0.5 + 0.5*cos(iTime+uv.xyx+vec3(0,2,4));
        vec4 color = texture(iChannel0, uv);
        
        // Output to screen
        fragColor = color;
    }
    ')

    public function new()
    {
        super();
    }
}

class GlitchBlurMistEffect extends ShaderBase
{
  public var shader:GlitchBlurMistShader = new GlitchBlurMistShader();
  public var intensity:Float = 0.0;
  var time:Float = 0.0;

  public function new():Void {
    shader.intensity.value = [intensity];
    shader.iTime.value = [time];
  }

  override public function update(elapsed:Float):Void {

    super.update(elapsed);

    shader.intensity.value = [intensity];
    time += elapsed;
    shader.iTime.value = [time];
  }
}

// https://www.shadertoy.com/view/wdjSzt
class GlitchBlurMistShader extends SLEFlxShaderUtil
{
  @:glFragmentSource('
    #pragma header

    vec2 fragCoord = openfl_TextureCoordv * openfl_TextureSize;
    vec2 iResolution = openfl_TextureSize.xy;
    uniform float iTime;
    #define iChannel0 bitmap
    #define texture flixel_texture2D
    #define fragColor gl_FragColor
    #define mainImage main

    uniform float intensity;

    float random(vec2 st) { // borrowed from Book of Shaders
        return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
    }

    float movement(vec2 coord) {
        return sin(coord.y + 1.5) * sin(iTime * random(coord)) * 0.025 * intensity;
    }

    void main()
    {
        vec2 coord = fragCoord/iResolution.xy;
        coord.x -= movement(coord);
        coord.x += 0.1;
        vec4 redVal = texture(iChannel0, coord) * vec4(1.0, 0.0, 0.0, 1.0);
        coord.x -= movement(coord);
        vec4 greenVal = texture(iChannel0, coord) * vec4(0.0, 0.0, 1.0, 1.0);
        coord.x -= movement(coord);
        vec4 blueVal = texture(iChannel0, coord) * vec4(0.0, 1.0, 0.0, 1.0);

        vec4 c = redVal + blueVal + greenVal;

        fragColor = c;
    }

  ')
  public function new()
  {
    super();
  }
}


class RhythmGlitchEffect extends ShaderBase
{
  public var shader:RhythmGlitchShader = new RhythmGlitchShader();
  public var bpm:Float = 0.0;
  var time:Float = 0.0;

  public function new():Void {
    shader.BPM.value = [bpm];
    shader.iTime.value = [time];
  }

  override public function update(elapsed:Float):Void {

    super.update(elapsed);

    shader.BPM.value = [bpm];
    time += elapsed;
    shader.iTime.value = [time];
  }
}

class RhythmGlitchShader extends SLEFlxShaderUtil
{
  @:glFragmentSource('
    #pragma header
    vec2 uv = openfl_TextureCoordv.xy;
    vec2 fragCoord = openfl_TextureCoordv * openfl_TextureSize;
    vec2 iResolution = openfl_TextureSize;
    uniform float iTime;
    #define iChannel0 bitmap
    #define texture flixel_texture2D
    #define fragColor gl_FragColor
    #define mainImage main

    uniform float BPM;

    vec2 uvp(vec2 uv) {
        return clamp(uv, 0.0, 1.0);
    }

    float outCirc(float t) {
        return sqrt(-t * t + 2.0 * t);
    }

    float rand(vec2 co) {
        return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
    }

    void mainImage() {
        vec3 col;
        float amp;
        
        if (BPM > 0.0) {
            amp = (1.0 - outCirc(fract(iTime / 60.0 * BPM)));
            
            for (int i = 0; i < 3; i++) {
                vec2 uv = fragCoord / iResolution.xy;
                uv += vec2(sin(iTime + float(i) + amp), cos(iTime + float(i) + amp)) * amp * 0.2;
                vec3 texOrig = texture(iChannel0, uvp(uv)).rgb;
                
                uv.x += (rand(vec2(uv.y + float(i), iTime)) * 2.0 - 1.0) * amp * 0.8 * (texOrig[i] + 0.2);
                uv.y += (rand(vec2(uv.x, iTime + float(i))) * 2.0 - 1.0) * amp * 0.1 * (texOrig[i] + 0.2);
                
                vec3 tex = texture(iChannel0, uvp(uv)).rgb;
                
                tex += abs(tex[i] - texOrig[i]);
                
                tex *= rand(uv) * amp + 1.0;
                
                tex = fract(tex);
                
                col[i] = tex[i];
            }
        } else {

            col = texture(iChannel0, uvp(fragCoord / iResolution.xy)).rgb;
        }
        
        fragColor = vec4(col, 1.0);
    }
  ')
  public function new()
  {
    super();
  }
}

class RepeatEffect extends ShaderBase
{
  public var shader(default, null):RepeatShader = new RepeatShader();
  public var zoom:Float = 1.0;

  var iTime:Float = 0.0;

  public var angle:Float = 0.0;

  public var x:Float = 0.0;
  public var y:Float = 0.0;

  public function new():Void
  {
    shader.zoom.value = [zoom];
    shader.angle.value = [angle];
    shader.iTime.value = [0.0];
    shader.x.value = [x];
    shader.y.value = [y];
  }

  override public function update(elapsed:Float):Void
  {
    shader.zoom.value = [zoom];
    shader.angle.value = [angle];
    iTime += elapsed;
    shader.iTime.value = [iTime];
    shader.x.value = [x];
    shader.y.value = [y];
  }
}

// MirrorRepeatEffect, but without mirror part
class RepeatShader extends SLEFlxShaderUtil
{
  @:glFragmentSource('
    #pragma header
    uniform float zoom;
    uniform float angle;
    uniform float iTime;
    uniform float x;
    uniform float y;

    vec4 render(vec2 uv)
    {
        uv.x += x;
        uv.y += y;

        // Sin efecto espejo
        return flixel_texture2D(bitmap, vec2(mod(uv.x, 1.0), mod(uv.y, 1.0)));
    }

    void main()
    {
        vec2 iResolution = vec2(1280, 720);

        vec2 center = vec2(0.5, 0.5);
        vec2 uv = openfl_TextureCoordv.xy;
        mat2 scaling = mat2(zoom, 0.0, 0.0, zoom);

        float angInRad = radians(angle);
        mat2 rotation = mat2(cos(angInRad), -sin(angInRad), sin(angInRad), cos(angInRad));

        // Ajuste de aspecto
        mat2 aspectRatioShit = mat2(0.5625, 0.0, 0.0, 1.0);
        vec2 fragCoordShit = iResolution * openfl_TextureCoordv.xy;
        
        uv = (fragCoordShit - 0.5 * iResolution.xy) / iResolution.y;
        uv = uv * scaling;
        uv = (aspectRatioShit) * (rotation * uv);
        uv = uv.xy + center;

        gl_FragColor = render(uv);
    }
')
  public function new()
  {
    super();
  }
}

// Effects A-Z WITH SHADERS -glow
class BarrelBlurEffect extends ShaderBase
{
  public var shader(default, null):BarrelBlurShader = new BarrelBlurShader();
  public var barrel:Float = 2.0;
  public var zoom:Float = 5.0;
  public var doChroma:Bool = false;

  var iTime:Float = 0.0;

  public var angle:Float = 0.0;

  public var x:Float = 0.0;
  public var y:Float = 0.0;

  public function new():Void
  {
    shader.barrel.value = [barrel];
    shader.zoom.value = [zoom];
    shader.doChroma.value = [doChroma];
    shader.angle.value = [angle];
    shader.iTime.value = [0.0];
    shader.x.value = [x];
    shader.y.value = [y];
  }

  override public function update(elapsed:Float):Void
  {
    shader.barrel.value = [barrel];
    shader.zoom.value = [zoom];
    shader.doChroma.value = [doChroma];
    shader.angle.value = [angle];
    iTime += elapsed;
    shader.iTime.value = [iTime];
    shader.x.value = [x];
    shader.y.value = [y];
  }
}

class BarrelBlurShader extends FlxFixedShader
{
  @:glFragmentSource('#pragma header uniform float barrel;
uniform float zoom;
uniform bool doChroma;
uniform float angle;
uniform float iTime;
uniform float x;
uniform float y;
// edited version of this
// https://www.shadertoy.com/view/td2XDz
vec2 remap(vec2 t, vec2 a, vec2 b)
{
  return clamp((t - a) / (b - a), 0.0, 1.0);
}
vec4 spectrum_offset_rgb(float t)
{
  if (!doChroma) return vec4(1.0, 1.0, 1.0, 1.0); // turn off chroma
  float
  t0 = 3.0 * t - 1.5;
  vec3
  ret = clamp(vec3(-t0, 1.0 - abs(t0), t0), 0.0, 1.0);
  return vec4(ret.r, ret.g, ret.b, 1.0);
}
vec2 brownConradyDistortion(vec2 uv, float dist)
{
  uv = uv * 2.0 - 1.0;
  float
  barrelDistortion1 = 0.1 * dist; // K1 in text books
  float
  barrelDistortion2 = -0.025 * dist; // K2 in text books
  float
  r2 = dot(uv, uv);
  uv *= 1.0 + barrelDistortion1 * r2 + barrelDistortion2 * r2 * r2;
  return uv * 0.5 + 0.5;
}
vec2 distort(vec2 uv, float t, vec2 min_distort, vec2 max_distort)
{
  vec2
  dist = mix(min_distort, max_distort, t);
  return brownConradyDistortion(uv, 75.0 * dist.x);
}
float nrand(vec2 n)
{
  return fract(sin(dot(n.xy, vec2(12.9898, 78.233))) * 43758.5453);
}
vec4 render(vec2 uv)
{
  uv.x += x;
  uv.y += y;
  // funny mirroring shit
  if ((uv.x > 1.0 || uv.x < 0.0) && abs(mod(uv.x, 2.0)) > 1.0) uv.x = (0.0 - uv.x) + 1.0;
  if ((uv.y > 1.0 || uv.y < 0.0) && abs(mod(uv.y, 2.0)) > 1.0) uv.y = (0.0 - uv.y) + 1.0;
  return flixel_texture2D(bitmap, vec2(abs(mod(uv.x, 1.0)), abs(mod(uv.y, 1.0))));
}
void main()
{
  vec2
  iResolution = vec2(1280.0, 720.0);
  // rotation bullshit
  vec2
  center = vec2(0.5, 0.5);
  vec2
  uv = openfl_TextureCoordv.xy;
  // uv = uv.xy - center; //move uv center point from center to top left
  mat2
  translation = mat2(0, 0, 0, 0);
  mat2
  scaling = mat2(zoom, 0.0, 0.0, zoom);
  // uv = uv * scaling;
  float
  angInRad = radians(angle);
  mat2
  rotation = mat2(cos(angInRad), -sin(angInRad), sin(angInRad), cos(angInRad));
  // used to stretch back into 16:9
  // 0.5625 is from 9/16
  mat2
  aspectRatioShit = mat2(0.5625, 0.0, 0.0, 1.0);
  vec2
  fragCoordShit = iResolution * openfl_TextureCoordv.xy;
  uv = (fragCoordShit - .5 * iResolution.xy) / iResolution.y;
  uv = uv * scaling;
  uv = (aspectRatioShit) * (rotation * uv);
  uv = uv.xy + center; // move back to center
  const
  float
  MAX_DIST_PX = 50.0;
  float
  max_distort_px = MAX_DIST_PX * barrel;
  vec2
  max_distort = vec2(max_distort_px) / iResolution.xy;
  vec2
  min_distort = 0.5 * max_distort;
  vec2
  oversiz = distort(vec2(1.0), 1.0, min_distort, max_distort);
  uv = mix(uv, remap(uv, 1.0 - oversiz, oversiz), 0.0);
  const
  int
  num_iter = 7;
  const
  float
  stepsiz = 1.0 / (float(num_iter) - 1.0);
  float
  rnd = nrand(uv + fract(iTime));
  float
  t = rnd * stepsiz;
  vec4
  sumcol = vec4(0.0);
  vec3
  sumw = vec3(0.0);
  for (int i = 0;
  i < num_iter;
  ++i
)
  {
    vec4
    w = spectrum_offset_rgb(t);
    sumw += w.rgb;
    vec2
    uvd = distort(uv, t, min_distort, max_distort);
    sumcol += w * render(uvd);
    t += stepsiz;
  }
  sumcol.rgb /= sumw;
  vec3
  outcol = sumcol.rgb;
  outcol = outcol;
  outcol += rnd / 255.0;
  gl_FragColor = vec4(outcol, sumcol.a / num_iter);
}
')
  public function new()
  {
    super();
  }
}

class BetterBlurEffect extends ShaderBase
{
  public var shader(default, null):BetterBlurShader = new BetterBlurShader();
  public var loops:Float = 16.0;
  public var quality:Float = 5.0;
  public var strength:Float = 0.0;

  public function new():Void
  {
    shader.loops.value = [0];
    shader.quality.value = [0];
    shader.strength.value = [0];
  }

  override public function update(elapsed:Float):Void
  {
    shader.loops.value[0] = loops;
    shader.quality.value[0] = quality;
    shader.strength.value[0] = strength;
    // shader.vertical.value = [vertical];
  }
}

class BetterBlurShader extends FlxFixedShader
{
  @:glFragmentSource('#pragma header // https://www.shadertoy.com/view/Xltfzj
// https://xorshaders.weebly.com/tutorials/blur-shaders-5-part-2
uniform float strength;
uniform float loops;
uniform float quality;
float Pi = 6.28318530718; // Pi*2
void main()
{
  vec2
  uv = openfl_TextureCoordv;
  vec4
  color = flixel_texture2D(bitmap, uv);
  vec2
  resolution = vec2(1280.0, 720.0);
  vec2
  rad = strength / openfl_TextureSize;
  for (float d = 0.0;
  d < Pi;
  d += Pi / loops
)
  {
    for (float i = 1.0 / quality;
    i <= 1.0;
    i += 1.0 / quality
  )
    {
      color += flixel_texture2D(bitmap, uv + vec2(cos(d), sin(d)) * rad * i);
    }
  }
  color /= quality * loops - 15.0;
  gl_FragColor = color;
}
')
  public function new()
  {
    super();
  }
}

class BloomBetterEffect extends ShaderBase
{
  public var shader:BloomBetterShader = new BloomBetterShader();
  public var effect:Float = 5;
  public var strength:Float = 0.2;
  public var contrast:Float = 1.0;
  public var brightness:Float = 0.0;

  public function new()
  {
    shader.effect.value = [effect];
    shader.strength.value = [strength];
    shader.iResolution.value = [FlxG.width, FlxG.height];
    shader.contrast.value = [contrast];
    shader.brightness.value = [brightness];
  }

  override public function update(elapsed:Float)
  {
    shader.effect.value = [effect];
    shader.strength.value = [strength];
    shader.iResolution.value = [FlxG.width, FlxG.height];
    shader.contrast.value = [contrast];
    shader.brightness.value = [brightness];
  }
}

class BloomBetterShader extends FlxFixedShader
{
  @:glFragmentSource('#pragma header uniform float effect;
uniform float strength;
uniform float contrast;
uniform float brightness;
uniform vec2 iResolution;
void main()
{
  vec2
  uv = openfl_TextureCoordv;
  vec4
  color = flixel_texture2D(bitmap, uv);
  // float brightness = dot(color.rgb, vec3(0.2126, 0.7152, 0.0722));
  // vec4 newColor = vec4(color.rgb * brightness * strength * color.a, color.a);
  // got some stuff from here: https://github.com/amilajack/gaussian-blur/blob/master/src/9.glsl
  // this also helped to understand: https://learnopengl.com/Advanced-Lighting/Bloom
  color.rgb *= contrast;
  color.rgb += vec3(brightness, brightness, brightness);
  if (effect <= 0)
  {
    gl_FragColor = color;
    return;
  }
  vec2
  off1 = vec2(1.3846153846) * effect;
  vec2
  off2 = vec2(3.2307692308) * effect;
  color += flixel_texture2D(bitmap, uv) * 0.2270270270 * strength;
  color += flixel_texture2D(bitmap, uv + (off1 / iResolution)) * 0.3162162162 * strength;
  color += flixel_texture2D(bitmap, uv - (off1 / iResolution)) * 0.3162162162 * strength;
  color += flixel_texture2D(bitmap, uv + (off2 / iResolution)) * 0.0702702703 * strength;
  color += flixel_texture2D(bitmap, uv - (off2 / iResolution)) * 0.0702702703 * strength;
  gl_FragColor = color;
}
')
  public function new()
  {
    super();
  }
}

class BlurEffect extends ShaderBase
{
  public var shader(default, null):BlurShader = new BlurShader();
  public var strength:Float = 0.0;
  public var strengthY:Float = 0.0;
  public var vertical:Bool = false;

  public function new():Void
  {
    shader.strength.value = [0];
    shader.strengthY.value = [0];
    // shader.vertical.value[0] = vertical;
  }

  override public function update(elapsed:Float):Void
  {
    shader.strength.value[0] = strength;
    shader.strengthY.value[0] = strengthY;
    // shader.vertical.value = [vertical];
  }
}

class BlurShader extends FlxFixedShader
{
  @:glFragmentSource('#pragma header uniform float strength;
uniform float strengthY;
// uniform bool vertical;
void main()
{
  // https://github.com/Jam3/glsl-fast-gaussian-blur/blob/master/5.glsl
  vec4
  color = vec4(0.0, 0.0, 0.0, 0.0);
  vec2
  uv = openfl_TextureCoordv;
  vec2
  resolution = vec2(1280.0, 720.0);
  vec2
  direction = vec2(strength, strengthY);
  // if (vertical)
  // {
  //    direction = vec2(0.0, 1.0);
  // }
  vec2
  off1 = vec2(1.3333333333333333, 1.3333333333333333) * direction;
  color += flixel_texture2D(bitmap, uv) * 0.29411764705882354;
  color += flixel_texture2D(bitmap, uv + (off1 / resolution)) * 0.35294117647058826;
  color += flixel_texture2D(bitmap, uv - (off1 / resolution)) * 0.35294117647058826;
  gl_FragColor = color;
}
')
  public function new()
  {
    super();
  }
}

class ChromAbEffect extends ShaderBase
{
  public var shader(default, null):ChromAbShader = new ChromAbShader();
  public var strength:Float = 0.0;

  public function new():Void
  {
    shader.strength.value = [0];
  }

  override public function update(elapsed:Float):Void
  {
    shader.strength.value[0] = strength;
  }
}

class ChromAbShader extends FlxFixedShader
{
  @:glFragmentSource('#pragma header uniform float strength;
void main()
{
  vec2
  uv = openfl_TextureCoordv;
  vec4
  col = flixel_texture2D(bitmap, uv);
  col.r = flixel_texture2D(bitmap, vec2(uv.x + strength, uv.y)).r;
  col.b = flixel_texture2D(bitmap, vec2(uv.x - strength, uv.y)).b;
  col = col * (1.0 - strength * 0.5);
  gl_FragColor = col;
}
')
  public function new()
  {
    super();
  }
}

class ChromAbBlueSwapEffect extends ShaderBase
{
  public var shader(default, null):ChromAbBlueSwapShader = new ChromAbBlueSwapShader();
  public var strength:Float = 0.0;

  public function new():Void
  {
    shader.strength.value = [0];
  }

  override public function update(elapsed:Float):Void
  {
    shader.strength.value[0] = strength;
  }
}

class ChromAbBlueSwapShader extends FlxFixedShader
{
  @:glFragmentSource('#pragma header uniform float strength;
void main()
{
  vec2
  uv = openfl_TextureCoordv;
  vec4
  col = flixel_texture2D(bitmap, uv);
  col.r = flixel_texture2D(bitmap, vec2(uv.x + strength, uv.y)).r;
  col.g = flixel_texture2D(bitmap, vec2(uv.x - strength, uv.y)).g;
  col = col * (1.0 - strength * 0.5);
  gl_FragColor = col;
}
')
  public function new()
  {
    super();
  }
}

class ChromaticAberrationEffect extends ShaderBase
{
  public var shader:ChromaticAberrationShader;

  public var rOffset(default, set):Float = 0.00;
  public var gOffset(default, set):Float = 0.00;
  public var bOffset(default, set):Float = 0.00;

  public function new()
  {
    shader.rOffset.value = [rOffset];
    shader.gOffset.value = [gOffset * -1];
    shader.bOffset.value = [bOffset];
  }

  override public function update(elpased:Float)
  {
    shader.rOffset.value = [rOffset];
    shader.gOffset.value = [gOffset * -1];
    shader.bOffset.value = [bOffset];
  }

  public function set_rOffset(roff:Float):Float
  {
    rOffset = roff;
    shader.rOffset.value = [rOffset];
    return roff;
  }

  public function set_gOffset(goff:Float):Float // RECOMMAND TO NOT USE CHANGE VALUE!
  {
    gOffset = goff;
    shader.gOffset.value = [gOffset * -1];
    return goff;
  }

  public function set_bOffset(boff:Float):Float
  {
    bOffset = boff;
    shader.bOffset.value = [bOffset];
    return boff;
  }

  public function setChrome(chromeOffset:Float):Void
  {
    shader.rOffset.value = [chromeOffset];
    shader.gOffset.value = [0.0];
    shader.bOffset.value = [chromeOffset * -1];
  }
}

class ChromaticAberrationShader extends FlxFixedShader
{
  @:glFragmentSource('#pragma header uniform float rOffset;
uniform float gOffset;
uniform float bOffset;
void main()
{
  vec4
  col1 = texture2D(bitmap, openfl_TextureCoordv.st - vec2(rOffset, 0.0));
  vec4
  col2 = texture2D(bitmap, openfl_TextureCoordv.st - vec2(gOffset, 0.0));
  vec4
  col3 = texture2D(bitmap, openfl_TextureCoordv.st - vec2(bOffset, 0.0));
  vec4
  toUse = texture2D(bitmap, openfl_TextureCoordv);
  toUse.r = col1.r;
  toUse.g = col2.g;
  toUse.b = col3.b;
  // float someshit = col4.r + col4.g + col4.b;
  gl_FragColor = toUse;
}
')
  public function new()
  {
    super();
  }
}

// More changed shaders added!
class ChromaticPincushEffect extends ShaderBase // No Vars Used!
{
  public var shader:ChromaticPincushShader = new ChromaticPincushShader();
}

class ChromaticPincushShader extends SLEFlxShaderUtil
{
  @:glFragmentSource('
    #pragma header
    // Thanks to NickWest and gonz84 for the shaders I combined together!
    // Those shaders being "Chromatic Abberation" and "pincushion single axis"

    vec2 uv = openfl_TextureCoordv.xy;

    void main(void)
    {
            vec2 st = uv - 0.5;
            float theta = atan(st.x, st.y);
             float radius = sqrt(dot(st, st));
            radius *= 1.0 + -0.5 * pow(radius, 2.0);


            vec4 col;
            col.r = texture2D(bitmap, vec2(0.5 + sin(theta) * radius+((uv.x+0.5)/500),uv.y)).r;
            col.g = texture2D(bitmap, vec2(0.5 + sin(theta) * radius,uv.y)).g;
            col.b = texture2D(bitmap, vec2(0.5 + sin(theta) * radius-((uv.x+0.5)/500),uv.y)).b;
            col.a = texture2D(bitmap, vec2(0.5 + sin(theta) * radius-((uv.x+0.5)/500),uv.y)).a;

        gl_FragColor = col;
    }
    ')
  public function new()
  {
    super();
  }
}

class ChromaticRadialBlurEffect extends ShaderBase
{
  public var shader:ChromaticRadialBlurShader = new ChromaticRadialBlurShader();
}

class ChromaticRadialBlurShader extends SLEFlxShaderUtil
{
  @:glFragmentSource('
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
    ')
  public function new()
  {
    super();
  }
}

class ColorFillEffect extends ShaderBase
{
  public var shader(default, null):ColorFillShader = new ColorFillShader();
  public var red:Float = 0.0;
  public var green:Float = 0.0;
  public var blue:Float = 0.0;
  public var fade:Float = 1.0;

  public function new():Void
  {
    shader.red.value = [red];
    shader.green.value = [green];
    shader.blue.value = [blue];
    shader.fade.value = [fade];
  }

  override public function update(elapsed:Float):Void
  {
    super.update(elapsed);

    shader.red.value = [red];
    shader.green.value = [green];
    shader.blue.value = [blue];
    shader.fade.value = [fade];
  }
}

class ColorFillShader extends FlxFixedShader
{
  @:glFragmentSource('
  #pragma header
  uniform float red;
uniform float green;
uniform float blue;
uniform float fade;
void main()
{
  vec4
  spritecolor = flixel_texture2D(bitmap, openfl_TextureCoordv);
  vec4
  col = vec4(red / 255, green / 255, blue / 255, spritecolor.a);
  vec3
  finalCol = mix(col.rgb * spritecolor.a, spritecolor.rgb, fade);
  gl_FragColor = vec4(finalCol.r, finalCol.g, finalCol.b, spritecolor.a);
}
')
  public function new()
  {
    super();
  }
}

class ColorOverrideEffect extends ShaderBase
{
  public var shader(default, null):ColorOverrideShader = new ColorOverrideShader();
  public var red:Float = 0.0;
  public var green:Float = 0.0;
  public var blue:Float = 0.0;

  public function new():Void
  {
    shader.red.value = [red];
    shader.green.value = [green];
    shader.blue.value = [blue];
  }

  override public function update(elapsed:Float):Void
  {
    super.update(elapsed);

    shader.red.value = [red];
    shader.green.value = [green];
    shader.blue.value = [blue];
  }
}

class ColorOverrideShader extends FlxFixedShader
{
  @:glFragmentSource('#pragma header uniform float red;
uniform float green;
uniform float blue;
void main()
{
  vec4
  spritecolor = flixel_texture2D(bitmap, openfl_TextureCoordv);
  spritecolor.r *= red;
  spritecolor.g *= green;
  spritecolor.b *= blue;
  gl_FragColor = spritecolor;
}
')
  public function new()
  {
    super();
  }
}

// same thingy just copied so i can use it in scripts

/**
 * Cool Shader by ShadowMario that changes RGB based on HSV.
 */
class ColorSwapEffect extends ShaderBase
{
  public var shader(default, null):ColorSwap.ColorSwapShader = new ColorSwap.ColorSwapShader();
  public var hue(default, set):Float = 0;
  public var saturation(default, set):Float = 0;
  public var brightness(default, set):Float = 0;
  public var awesomeOutline(default, set):Bool = false;

  private function set_hue(value:Float)
  {
    hue = value;
    shader.uTime.value[0] = hue;
    return hue;
  }

  private function set_saturation(value:Float)
  {
    saturation = value;
    shader.uTime.value[1] = saturation;
    return saturation;
  }

  private function set_brightness(value:Float)
  {
    brightness = value;
    shader.uTime.value[2] = brightness;
    return brightness;
  }

  private function set_awesomeOutline(value:Bool)
  {
    awesomeOutline = value;
    shader.awesomeOutline.value = [awesomeOutline];
    return awesomeOutline;
  }

  public function new()
  {
    shader.uTime.value = [0, 0, 0];
    shader.awesomeOutline.value = [false];
  }
}

class ColorWhiteFrameEffect extends ShaderBase
{
  public var shader:ColorWhiteFrameShader = new ColorWhiteFrameShader();

  public var amount(default, set):Float = 0.0;

  public function new()
  {
    shader.amount.value = [amount];
  }

  override public function update(elapsed:Float)
  {
    shader.amount.value = [amount];
  }

  function set_amount(a:Float):Float
  {
    amount = a;
    shader.amount.value = [amount];
    return a;
  }
}

class ColorWhiteFrameShader extends SLEFlxShaderUtil
{
  @:glFragmentSource('
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
    ')
  public function new()
  {
    super();
  }
}

class DesaturateEffect extends ShaderBase
{
  public var shader:DesaturateShader = new DesaturateShader();

  var iTime:Float = 0.0;

  public function new()
  {
    shader.iTime.value = [0];
  }

  override public function update(elapsed:Float)
  {
    iTime += elapsed;
    shader.iTime.value = [iTime];
  }
}

class DesaturateShader extends SLEFlxShaderUtil
{
  @:glFragmentSource('
    #pragma header
    vec2 uv = openfl_TextureCoordv.xy;
    vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
    vec2 iResolution = openfl_TextureSize;
    uniform float iTime;
    #define iChannel0 bitmap
    #define texture flixel_texture2D
    #define fragColor gl_FragColor
    #define mainImage main

    void mainImage()
    {
        vec2 p = fragCoord.xy/iResolution.xy;

        vec4 col = texture(iChannel0, p);

        col = vec4( (col.r+col.g+col.b)/3. );

        fragColor = col;
    }

    // https://www.shadertoy.com/view/dssXRl
    ')
  public function new()
  {
    super();
  }
}

class DesaturationRGBEffect extends ShaderBase
{
  public var shader:DesaturationRGBShader = new DesaturationRGBShader();

  public var desaturationAmount(default, set):Float = 0.0;
  public var distortionTime(default, set):Float = 0.0;
  public var amplitude(default, set):Float = -0.1;
  public var frequency(default, set):Float = 8.0;

  public function new()
  {
    shader.desaturationAmount.value = [desaturationAmount];
    shader.distortionTime.value = [distortionTime];
    shader.amplitude.value = [amplitude];
    shader.frequency.value = [frequency];
  }

  override public function update(elapsed:Float)
  {
    shader.desaturationAmount.value = [desaturationAmount];
    shader.distortionTime.value = [distortionTime];
    shader.amplitude.value = [amplitude];
    shader.frequency.value = [frequency];
  }

  public function set_desaturationAmount(da:Float):Float
  {
    desaturationAmount = da;
    shader.desaturationAmount.value = [desaturationAmount];
    return da;
  }

  public function set_distortionTime(dt:Float):Float
  {
    distortionTime = dt;
    shader.distortionTime.value = [distortionTime];
    return dt;
  }

  public function set_amplitude(a:Float):Float
  {
    amplitude = a;
    shader.amplitude.value = [amplitude];
    return a;
  }

  public function set_frequency(f:Float):Float
  {
    frequency = f;
    shader.frequency.value = [frequency];
    return f;
  }
}

class DesaturationRGBShader extends SLEFlxShaderUtil
{
  @:glFragmentSource('
    #pragma header

    uniform float desaturationAmount;
    uniform float distortionTime;
    uniform float amplitude;
    uniform float frequency;

    void main() {
        vec4 desatTexture = texture2D(bitmap, vec2(openfl_TextureCoordv.x + sin((openfl_TextureCoordv.y * frequency) + distortionTime) * amplitude, openfl_TextureCoordv.y));
        gl_FragColor = vec4(mix(vec3(dot(desatTexture.xyz, vec3(.2126, .7152, .0722))), desatTexture.xyz, desaturationAmount), desatTexture.a);
    }
    ')
  public function new()
  {
    super();
  }
}

class DropShadow extends ShaderBase
{
  public var shader:DropShadowShader = new DropShadowShader();

  public var alpha(default, set):Float = 0;
  public var disx(default, set):Float = 0;
  public var disy(default, set):Float = 0;

  public var inner(default, set):Bool = false;
  public var inverted(default, set):Bool = false;

  public function new()
  {
    shader._alpha.value = [alpha];
    shader._disx.value = [disx];
    shader._disy.value = [disy];
    shader.inner.value = [inner];
    shader.inverted.value = [inverted];
  }

  override public function update(elapsed:Float)
  {
    shader._alpha.value = [alpha];
    shader._disx.value = [disx];
    shader._disy.value = [disy];
    shader.inner.value = [inner];
    shader.inverted.value = [inverted];
  }

  function set_alpha(value:Float)
  {
    alpha = value;
    shader._alpha.value = [alpha];
    return value;
  }

  function set_disx(value:Float)
  {
    disx = value;
    shader._disx.value = [disx];
    return value;
  }

  function set_disy(value:Float)
  {
    disy = value;
    shader._disy.value = [disy];
    return value;
  }

  function set_inner(value:Bool)
  {
    inner = value;
    shader.inner.value = [inner];
    return value;
  }

  function set_inverted(value:Bool)
  {
    inverted = value;
    shader.inverted.value = [inverted];
    return value;
  }
}

class DropShadowShader extends SLEFlxShaderUtil
{
  @:glFragmentSource('
    #pragma header
    //its important to have this bit here. it inits all the importan OpenFL shader shits like the images coordinates and size.

    uniform float _alpha; //transparancy of the drop shadow
    uniform float _disx; // x distance
    uniform float _disy; // y distance
    uniform bool inner; // an inside shadow
    uniform bool inverted; // inverted inner shadow

    vec2 uv = openfl_TextureCoordv.xy;
    // uv: coordinate of a pixel. usually replaces fragCoord.xy / iResolution.xy;
    vec2 size = openfl_TextureSize.xy;
    // size: size of the full image. usually replaces iResolution.xy;

    void main(void){

    vec4 color = texture2D( bitmap, uv);
    // so i dont have to type out texture2d(bla bla bla ) and shit

    vec2 distance = vec2(_disx,_disy)/size;
    //distance vector

    if(inner){
        vec4 shadow = flixel_texture2D( bitmap, uv-distance);
        shadow.rgb = vec3(0.0);
        shadow.a = 1-shadow.a;
        shadow.a *= color.a;
        vec3 result;
        if(inverted){
            result = color.rgb * (shadow.a+color.a*_alpha); // for that cool lighting
        }else{
            result = color.rgb * ((1-shadow.a )+shadow.a*_alpha);
        }
        gl_FragColor =  vec4(result,color.a);
    }else{

        vec4 shadow = flixel_texture2D( bitmap, uv-distance);
        shadow.rgb = vec3(0.0);
        shadow.a *= _alpha;
        gl_FragColor = shadow + color;

    }
        //bitmap: the original graphic of the camera or sprite. usually replaces iChannel0
        //texture2D: a 4type Vector that returns the image. replaces texture
        //gl_FragColor: the result. usually replaces fragColor
    }
    ')
  public function new()
  {
    super();
  }
}

class FlipEffect extends ShaderBase
{
  public var shader:FlipShader = new FlipShader();
  public var flip(default, set):Float = 0.0;

  public function new()
  {
    shader.flip.value = [0];
  }

  override public function update(elapsed:Float)
  {
    shader.flip.value = [flip];
  }

  function set_flip(value:Float)
  {
    flip = value;
    shader.flip.value = [flip];
    return value;
  }
}

class FlipShader extends SLEFlxShaderUtil
{
  @:glFragmentSource('
    #pragma header

    uniform float flip;

    void main()
    {
        vec2 uv = openfl_TextureCoordv.xy;

        uv.x = abs(uv.x + flip);

        gl_FragColor = texture2D(bitmap, uv);
    }
    ')
  public function new()
  {
    super();
  }
}

class GameBoyEffect extends ShaderBase
{
  public var shader:GameBoyShader = new GameBoyShader();
  public var intensity(default, set):Float = 0.0;

  public function new()
  {
    shader.intensity.value = [intensity];
  }

  override public function update(elapsed:Float)
  {
    shader.intensity.value = [intensity];
  }

  function set_intensity(i:Float):Float
  {
    intensity = i;
    shader.intensity.value = [intensity];
    return i;
  }
}

class GameBoyShader extends GraphicsShader
{
  @:glFragmentSource('
    #pragma header

    float threshold = 0.125; // Threshold for dithering (0.0045 found to be optimal)
    uniform float intensity;
    mat2 dither_2 = mat2(0.,1.,1.,0.);

    struct dither_tile {
        float height;
    };

    vec3[4] gb_colors() {
        vec3 gb_colors[4];
        gb_colors[0] = vec3(8., 24., 32.) / 255.;
        gb_colors[1] = vec3(52., 104., 86.) / 255.;
        gb_colors[2] = vec3(136., 192., 112.) / 255.;
        gb_colors[3] = vec3(224., 248., 208.) / 255.;
        return gb_colors;
    }

    float[4] gb_colors_distance(vec3 color) {
        float distances[4];
        distances[0] = distance(color, gb_colors()[0]);
        distances[1] = distance(color, gb_colors()[1]);
        distances[2] = distance(color, gb_colors()[2]);
        distances[3] = distance(color, gb_colors()[3]);
        return distances;
    }

    vec3 closest_gb(vec3 color) {
        int best_i = 0;
        float best_d = 2.;

        vec3 gb_colors[4] = gb_colors();
        for (int i = 0; i < 4; i++) {
            float dis = distance(gb_colors[i], color);
            if (dis < best_d) {
                best_d = dis;
                best_i = i;
            }
        }
        return gb_colors[best_i];
    }

    vec3[2] gb_2_closest(vec3 color) {
         float distances[4] = gb_colors_distance(color);

        int first_i = 0;
        float first_d = 2.;

        int second_i = 0;
        float second_d = 2.;

        for (int i = 0; i < distances.length(); i++) {
            float d = distances[i];
            if (distances[i] <= first_d) {
                second_i = first_i;
                second_d = first_d;
                first_i = i;
                first_d = d;
            } else if (distances[i] <= second_d) {
                second_i = i;
                second_d = d;
            }
        }
        vec3 colors[4] = gb_colors();
        vec3 result[2];
        if (first_i < second_i)
            result = vec3[2](colors[first_i], colors[second_i]);
        else
             result = vec3[2](colors[second_i], colors[first_i]);
        return result;
    }

    bool needs_dither(vec3 color) {
        float distances[4] = gb_colors_distance(color);

        int first_i = 0;
        float first_d = 2.;

        int second_i = 0;
        float second_d = 2.;

        for (int i = 0; i < distances.length(); i++) {
            float d = distances[i];
            if (d <= first_d) {
                second_i = first_i;
                second_d = first_d;
                first_i = i;
                first_d = d;
            } else if (d <= second_d) {
                second_i = i;
                second_d = d;
            }
        }
        return abs(first_d - second_d) <= threshold;
    }

    vec3 return_gbColor(vec3 sampleColor) {
        vec3 endColor;
        if (needs_dither(sampleColor)) {
            endColor = vec3(gb_2_closest(sampleColor)[int(dither_2[int(openfl_TextureCoordv.x)][int(openfl_TextureCoordv.y)])]);
        } else
            endColor = vec3(closest_gb(texture2D(bitmap, openfl_TextureCoordv).rgb));
        return endColor;
    }

    vec3 buried_eye_color = vec3(255.0, 0.0, 0.0) / 255.0;
    vec3 buried_grave_color = vec3(121.0, 133.0, 142.0) / 255.0;
    vec3 buried_wall_color = vec3(107., 130., 149.) / 255.0;

    void main() {
        vec4 sampleColor = texture2D(bitmap, openfl_TextureCoordv);
        vec3 colors[4] = gb_colors();
        if (sampleColor.a != 0.0) {
            vec3 colorB = return_gbColor(sampleColor.rgb);
            vec4 newColor;
            if (sampleColor.rgb == buried_eye_color)
                colorB = colors[2];
            if (sampleColor.rgb == buried_grave_color)
                colorB = colors[2];
            if (sampleColor.rgb == buried_wall_color)
                colorB = colors[2];
            newColor = vec4(mix(sampleColor.rgb * sampleColor.a, colorB.rgb, intensity), sampleColor.a);
            gl_FragColor = newColor;
        } else
            gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);

        /*
        vec3 gbColor = vec3(closest_gb(texture(bitmap, openfl_TextureCoordv).rgb));
        // Output to screen
        gl_FragColor = vec4(
            mix(texture2D(bitmap, openfl_TextureCoordv).rgb * texture2D(bitmap, openfl_TextureCoordv).a, gbColor.rgb, intensity),
            texture2D(bitmap, openfl_TextureCoordv).a
        );
        */
    }
    ')
  public function new()
  {
    super();
  }
}

class GlitchedEffect extends ShaderBase
{
  public var shader:GlitchedShader = new GlitchedShader();
  public var time(default, set):Float = 0.0;
  public var prob(default, set):Float = 0.0;
  public var intensityChromatic(default, set):Float = 0.0;

  public function new()
  {
    shader.time.value = [time];
    shader.prob.value = [prob];
    shader.intensityChromatic.value = [intensityChromatic];
  }

  override public function update(elapsed:Float)
  {
    shader.time.value = [time];
    shader.prob.value = [prob];
    shader.intensityChromatic.value = [intensityChromatic];
  }

  public function set_time(t:Float):Float
  {
    time = t;
    shader.time.value = [time];
    return t;
  }

  public function set_prob(p:Float):Float
  {
    prob = p;
    shader.prob.value = [prob];
    return p;
  }

  public function set_intensityChromatic(ic:Float):Float
  {
    intensityChromatic = ic;
    shader.intensityChromatic.value = [intensityChromatic];
    return ic;
  }
}

class GlitchedShader extends GraphicsShader
{
  @:glFragmentSource('
      // https://www.shadertoy.com/view/XtyXzW

      #pragma header
      #extension GL_ARB_gpu_shader5 : enable

      uniform float time;
      uniform float prob;
      uniform float intensityChromatic;
      const int sampleCount = 50;

      float _round(float n) {
          return floor(n + .5);
      }

      vec2 _round(vec2 n) {
          return floor(n + .5);
      }

      vec3 tex2D(sampler2D _tex,vec2 _p)
      {
          vec3 col=texture(_tex,_p).xyz;
          if(.5<abs(_p.x-.5)){
              col=vec3(.1);
          }
          return col;
      }

      const float PI = 3.14159265359;
      const float PHI = (1.618033988749895);

      // --------------------------------------------------------
      // Glitch core
      // --------------------------------------------------------

      float rand(vec2 co){
          return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
      }

      const float glitchScale = .4;

      vec2 glitchCoord(vec2 p, vec2 gridSize) {
          vec2 coord = floor(p / gridSize) * gridSize;;
          coord += (gridSize / 2.);
          return coord;
      }

      struct GlitchSeed {
          vec2 seed;
          float prob;
      };

      float fBox2d(vec2 p, vec2 b) {
        vec2 d = abs(p) - b;
        return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
      }

      GlitchSeed glitchSeed(vec2 p, float speed) {
          float seedTime = floor(time * speed);
          vec2 seed = vec2(
              1. + mod(seedTime / 100., 100.),
              1. + mod(seedTime, 100.)
          ) / 100.;
          seed += p;
          return GlitchSeed(seed, prob);
      }

      float shouldApply(GlitchSeed seed) {
          return round(
              mix(
                  mix(rand(seed.seed), 1., seed.prob - .5),
                  0.,
                  (1. - seed.prob) * .5
              )
          );
      }

      // gamma again
      const float GAMMA = 1;

      vec3 gamma(vec3 color, float g) {
          return pow(color, vec3(g));
      }

      vec3 linearToScreen(vec3 linearRGB) {
          return gamma(linearRGB, 1.0 / GAMMA);
      }

      // --------------------------------------------------------
      // Glitch effects
      // --------------------------------------------------------

      // Swap

      vec4 swapCoords(vec2 seed, vec2 groupSize, vec2 subGrid, vec2 blockSize) {
          vec2 rand2 = vec2(rand(seed), rand(seed+.1));
          vec2 range = subGrid - (blockSize - 1.);
          vec2 coord = floor(rand2 * range) / subGrid;
          vec2 bottomLeft = coord * groupSize;
          vec2 realBlockSize = (groupSize / subGrid) * blockSize;
          vec2 topRight = bottomLeft + realBlockSize;
          topRight -= groupSize / 2.;
          bottomLeft -= groupSize / 2.;
          return vec4(bottomLeft, topRight);
      }

      float isInBlock(vec2 pos, vec4 block) {
          vec2 a = sign(pos - block.xy);
          vec2 b = sign(block.zw - pos);
          return min(sign(a.x + a.y + b.x + b.y - 3.), 0.);
      }

      vec2 moveDiff(vec2 pos, vec4 swapA, vec4 swapB) {
          vec2 diff = swapB.xy - swapA.xy;
          return diff * isInBlock(pos, swapA);
      }

      void swapBlocks(inout vec2 xy, vec2 groupSize, vec2 subGrid, vec2 blockSize, vec2 seed, float apply) {

          vec2 groupOffset = glitchCoord(xy, groupSize);
          vec2 pos = xy - groupOffset;

          vec2 seedA = seed * groupOffset;
          vec2 seedB = seed * (groupOffset + .1);

          vec4 swapA = swapCoords(seedA, groupSize, subGrid, blockSize);
          vec4 swapB = swapCoords(seedB, groupSize, subGrid, blockSize);

          vec2 newPos = pos;
          newPos += moveDiff(pos, swapA, swapB) * apply;
          newPos += moveDiff(pos, swapB, swapA) * apply;
          pos = newPos;

          xy = pos + groupOffset;
      }


      // Static

      void staticNoise(inout vec2 p, vec2 groupSize, float grainSize, float contrast) {
          GlitchSeed seedA = glitchSeed(glitchCoord(p, groupSize), 5.);
          seedA.prob *= .5;
          if (shouldApply(seedA) == 1.) {
              GlitchSeed seedB = glitchSeed(glitchCoord(p, vec2(grainSize)), 5.);
              vec2 offset = vec2(rand(seedB.seed), rand(seedB.seed + .1));
              offset = round(offset * 2. - 1.);
              offset *= contrast;
              p += offset;
          }
      }


      // Freeze time

      void freezeTime(vec2 p, inout float time, vec2 groupSize, float speed) {
          GlitchSeed seed = glitchSeed(glitchCoord(p, groupSize), speed);
          //seed.prob *= .5;
          if (shouldApply(seed) == 1.) {
              float frozenTime = floor(time * speed) / speed;
              time = frozenTime;
          }
      }


      // --------------------------------------------------------
      // Glitch compositions
      // --------------------------------------------------------

      void glitchSwap(inout vec2 p) {

          vec2 pp = p;

          float scale = glitchScale;
          float speed = 5.;

          vec2 groupSize;
          vec2 subGrid;
          vec2 blockSize;
          GlitchSeed seed;
          float apply;

          groupSize = vec2(.6) * scale;
          subGrid = vec2(2.0);
          blockSize = vec2(1.0);

          seed = glitchSeed(glitchCoord(p, groupSize), speed);
          apply = shouldApply(seed);
          swapBlocks(p, groupSize, subGrid, blockSize, seed.seed, apply);

          groupSize = vec2(.8) * scale;
          subGrid = vec2(3.0);
          blockSize = vec2(1.0);

          seed = glitchSeed(glitchCoord(p, groupSize), speed);
          apply = shouldApply(seed);
          swapBlocks(p, groupSize, subGrid, blockSize, seed.seed, apply);

          groupSize = vec2(.2) * scale;
          subGrid = vec2(6.0);
          blockSize = vec2(1.0);

          seed = glitchSeed(glitchCoord(p, groupSize), speed);
          float apply2 = shouldApply(seed);
          swapBlocks(p, groupSize, subGrid, blockSize, (seed.seed + 1.), apply * apply2);
          swapBlocks(p, groupSize, subGrid, blockSize, (seed.seed + 2.), apply * apply2);
          swapBlocks(p, groupSize, subGrid, blockSize, (seed.seed + 3.), apply * apply2);
          swapBlocks(p, groupSize, subGrid, blockSize, (seed.seed + 4.), apply * apply2);
          swapBlocks(p, groupSize, subGrid, blockSize, (seed.seed + 5.), apply * apply2);

          groupSize = vec2(1.2, .2) * scale;
          subGrid = vec2(9.0,2.0);
          blockSize = vec2(3.0,1.0);

          seed = glitchSeed(glitchCoord(p, groupSize), speed);
          apply = shouldApply(seed);
          swapBlocks(p, groupSize, subGrid, blockSize, seed.seed, apply);
      }

      void glitchStatic(inout vec2 p) {
          staticNoise(p, vec2(.5, .25/2.) * glitchScale, .2 * glitchScale, 2.);
      }

      void glitchTime(vec2 p, inout float time) {
         freezeTime(p, time, vec2(.5) * glitchScale, 2.);
      }

      void glitchColor(vec2 p, inout vec3 color) {
          vec2 groupSize = vec2(.75,.125) * glitchScale;
          vec2 subGrid = vec2(0,6);
          float speed = 5.;
          GlitchSeed seed = glitchSeed(glitchCoord(p, groupSize), speed);
          seed.prob *= .3;
          if (shouldApply(seed) == 1.)
              color = vec3(0.0, 0.0, 0.0);
      }

      vec4 transverseChromatic(vec2 p) {
          vec2 destCoord = p;
          vec2 direction = normalize(destCoord - 0.5);
          vec2 velocity = direction * intensityChromatic * pow(length(destCoord - 0.5), 3.0);
          float inverseSampleCount = 1.0 / float(sampleCount);

          mat3x2 increments = mat3x2(velocity * 1.0 * inverseSampleCount, velocity * 2.0 * inverseSampleCount, velocity * 4.0 * inverseSampleCount);

          vec3 accumulator = vec3(0);
          mat3x2 offsets = mat3x2(0);
          for (int i = 0; i < sampleCount; i++) {
              accumulator.r += texture(bitmap, destCoord + offsets[0]).r;
              accumulator.g += texture(bitmap, destCoord + offsets[1]).g;
              accumulator.b += texture(bitmap, destCoord + offsets[2]).b;
              offsets -= increments;
          }
          vec4 newColor = vec4(accumulator / float(sampleCount), 1.0);
          return newColor;
      }

      void main() {
          // time = mod(time, 1.);
          float alpha = openfl_Alphav;
          vec2 p = openfl_TextureCoordv.xy;
          vec3 color = texture2D(bitmap, p).rgb;

          glitchSwap(p);
          // glitchTime(p, time);
          glitchStatic(p);

          color = transverseChromatic(p).rgb;
          glitchColor(p, color);
          // color = linearToScreen(color);

          gl_FragColor = vec4(color.r * alpha, color.g * alpha, color.b * alpha, alpha);
      }
  ')
  public function new()
  {
    super();
  }
}

class GlitchNewEffect extends ShaderBase
{
  public var shader:GlitchNewShader = new GlitchNewShader();

  public var prob(default, set):Float = 0;
  public var intensityChromatic(default, set):Float = 0;

  public function new()
  {
    shader.time.value = [0];
  }

  override public function update(elapsed:Float)
  {
    shader.prob.value = [prob];
    shader.intensityChromatic.value = [intensityChromatic];
  }

  function set_prob(value:Float):Float
  {
    prob = value;
    shader.prob.value = [prob];
    return value;
  }

  function set_intensityChromatic(value:Float):Float
  {
    intensityChromatic = value;
    shader.intensityChromatic.value = [intensityChromatic];
    return value;
  }
}

class GlitchNewShader extends SLEFlxShaderUtil // https://www.shadertoy.com/view/XtyXzW
{
  // Linux crashes due to GL_NV_non_square_matrices
  // and I haven' t found a way to set version to 130 // (importing Eric's PR (openfl/openfl#2577) to this repo caused more errors)
  // So for now, Linux users will have to disable shaders specifically for Libitina.
  @:glFragmentSource('
	#extension GL_EXT_gpu_shader4 : enable
	#extension GL_NV_non_square_matrices : enable

	#pragma header

	vec2 uv = openfl_TextureCoordv.xy;
	vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
	vec2 iResolution = openfl_TextureSize;

	uniform float time;
	uniform float prob;
	uniform float intensityChromatic;
	const int sampleCount = 50;

	float _round(float n) {
		return floor(n + .5);
	}

	vec2 _round(vec2 n) {
		return floor(n + .5);
	}

	vec3 tex2D(sampler2D _tex,vec2 _p)
	{
		vec3 col=texture(_tex,_p).xyz;
		if(.5<abs(_p.x-.5)){
			col=vec3(.1);
		}
		return col;
	}

	const float PI = 3.14159265359;
	const float PHI = (1.618033988749895);

	// --------------------------------------------------------
	// Glitch core
	// --------------------------------------------------------

	float rand(vec2 co){
		return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
	}

	const float glitchScale = 0.4;

	vec2 glitchCoord(vec2 p, vec2 gridSize) {
		vec2 coord = floor(p / gridSize) * gridSize;;
		coord += (gridSize / 2.);
		return coord;
	}

	struct GlitchSeed {
		vec2 seed;
		float prob;
	};

	float fBox2d(vec2 p, vec2 b) {
	vec2 d = abs(p) - b;
	return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
	}

	GlitchSeed glitchSeed(vec2 p, float speed) {
		float seedTime = floor(time * speed);
		vec2 seed = vec2(
			1. + mod(seedTime / 100., 100.),
			1. + mod(seedTime, 100.)
		) / 100.;
		seed += p;
		return GlitchSeed(seed, prob);
	}

	float shouldApply(GlitchSeed seed) {
		return round(
			mix(
				mix(rand(seed.seed), 1., seed.prob - .5),
				0.,
				(1. - seed.prob) * .5
			)
		);
	}

	// gamma again
	const float GAMMA = 1.0;

	vec3 gamma(vec3 color, float g) {
		return pow(color, vec3(g));
	}

	vec3 linearToScreen(vec3 linearRGB) {
		return gamma(linearRGB, 1.0 / GAMMA);
	}

	// --------------------------------------------------------
	// Glitch effects
	// --------------------------------------------------------

	// Swap

	vec4 swapCoords(vec2 seed, vec2 groupSize, vec2 subGrid, vec2 blockSize) {
		vec2 rand2 = vec2(rand(seed), rand(seed+.1));
		vec2 range = subGrid - (blockSize - 1.);
		vec2 coord = floor(rand2 * range) / subGrid;
		vec2 bottomLeft = coord * groupSize;
		vec2 realBlockSize = (groupSize / subGrid) * blockSize;
		vec2 topRight = bottomLeft + realBlockSize;
		topRight -= groupSize / 2.;
		bottomLeft -= groupSize / 2.;
		return vec4(bottomLeft, topRight);
	}

	float isInBlock(vec2 pos, vec4 block) {
		vec2 a = sign(pos - block.xy);
		vec2 b = sign(block.zw - pos);
		return min(sign(a.x + a.y + b.x + b.y - 3.), 0.);
	}

	vec2 moveDiff(vec2 pos, vec4 swapA, vec4 swapB) {
		vec2 diff = swapB.xy - swapA.xy;
		return diff * isInBlock(pos, swapA);
	}

	void swapBlocks(inout vec2 xy, vec2 groupSize, vec2 subGrid, vec2 blockSize, vec2 seed, float apply) {

		vec2 groupOffset = glitchCoord(xy, groupSize);
		vec2 pos = xy - groupOffset;

		vec2 seedA = seed * groupOffset;
		vec2 seedB = seed * (groupOffset + .1);

		vec4 swapA = swapCoords(seedA, groupSize, subGrid, blockSize);
		vec4 swapB = swapCoords(seedB, groupSize, subGrid, blockSize);

		vec2 newPos = pos;
		newPos += moveDiff(pos, swapA, swapB) * apply;
		newPos += moveDiff(pos, swapB, swapA) * apply;
		pos = newPos;

		xy = pos + groupOffset;
	}


	// Static

	void staticNoise(inout vec2 p, vec2 groupSize, float grainSize, float contrast) {
		GlitchSeed seedA = glitchSeed(glitchCoord(p, groupSize), 5.);
		seedA.prob *= .5;
		if (shouldApply(seedA) == 1.) {
			GlitchSeed seedB = glitchSeed(glitchCoord(p, vec2(grainSize)), 5.);
			vec2 offset = vec2(rand(seedB.seed), rand(seedB.seed + .1));
			offset = round(offset * 2. - 1.);
			offset *= contrast;
			p += offset;
		}
	}


	// Freeze time

	void freezeTime(vec2 p, inout float time, vec2 groupSize, float speed) {
		GlitchSeed seed = glitchSeed(glitchCoord(p, groupSize), speed);
		//seed.prob *= .5;
		if (shouldApply(seed) == 1.) {
			float frozenTime = floor(time * speed) / speed;
			time = frozenTime;
		}
	}


	// --------------------------------------------------------
	// Glitch compositions
	// --------------------------------------------------------

	void glitchSwap(inout vec2 p) {

		vec2 pp = p;

		float scale = glitchScale;
		float speed = 5.;

		vec2 groupSize;
		vec2 subGrid;
		vec2 blockSize;
		GlitchSeed seed;
		float apply;

		groupSize = vec2(.6) * scale;
		subGrid = vec2(2.0);
		blockSize = vec2(1.0);

		seed = glitchSeed(glitchCoord(p, groupSize), speed);
		apply = shouldApply(seed);
		swapBlocks(p, groupSize, subGrid, blockSize, seed.seed, apply);

		groupSize = vec2(.8) * scale;
		subGrid = vec2(3.0);
		blockSize = vec2(1.0);

		seed = glitchSeed(glitchCoord(p, groupSize), speed);
		apply = shouldApply(seed);
		swapBlocks(p, groupSize, subGrid, blockSize, seed.seed, apply);

		groupSize = vec2(.2) * scale;
		subGrid = vec2(6.0);
		blockSize = vec2(1.0);

		seed = glitchSeed(glitchCoord(p, groupSize), speed);
		float apply2 = shouldApply(seed);
		swapBlocks(p, groupSize, subGrid, blockSize, (seed.seed + 1.), apply * apply2);
		swapBlocks(p, groupSize, subGrid, blockSize, (seed.seed + 2.), apply * apply2);
		swapBlocks(p, groupSize, subGrid, blockSize, (seed.seed + 3.), apply * apply2);
		swapBlocks(p, groupSize, subGrid, blockSize, (seed.seed + 4.), apply * apply2);
		swapBlocks(p, groupSize, subGrid, blockSize, (seed.seed + 5.), apply * apply2);

		groupSize = vec2(1.2, .2) * scale;
		subGrid = vec2(9.0,2.0);
		blockSize = vec2(3.0,1.0);

		seed = glitchSeed(glitchCoord(p, groupSize), speed);
		apply = shouldApply(seed);
		swapBlocks(p, groupSize, subGrid, blockSize, seed.seed, apply);
	}

	void glitchStatic(inout vec2 p) {
		staticNoise(p, vec2(.5, .25/2.) * glitchScale, .2 * glitchScale, 2.);
	}

	void glitchTime(vec2 p, inout float time) {
	freezeTime(p, time, vec2(.5) * glitchScale, 2.);
	}

	void glitchColor(vec2 p, inout vec3 color) {
		vec2 groupSize = vec2(.75,.125) * glitchScale;
		vec2 subGrid = vec2(0.0,6.0);
		float speed = 5.;
		GlitchSeed seed = glitchSeed(glitchCoord(p, groupSize), speed);
		seed.prob *= .3;
		if (shouldApply(seed) == 1.)
			color = vec3(0.0, 0.0, 0.0);
	}

	vec4 transverseChromatic(vec2 p) {
		vec2 destCoord = p;
		vec2 direction = normalize(destCoord - 0.5);
		vec2 velocity = direction * intensityChromatic * pow(length(destCoord - 0.5), 3.0);
		float inverseSampleCount = 1.0 / float(sampleCount);

		mat3x2 increments = mat3x2(velocity * 1.0 * inverseSampleCount, velocity * 2.0 * inverseSampleCount, velocity * 4.0 * inverseSampleCount);

		vec3 accumulator = vec3(0.0);
		mat3x2 offsets = mat3x2(0);
		for (int i = 0; i < sampleCount; i++) {
			accumulator.r += texture(bitmap, destCoord + offsets[0]).r;
			accumulator.g += texture(bitmap, destCoord + offsets[1]).g;
			accumulator.b += texture(bitmap, destCoord + offsets[2]).b;
			offsets -= increments;
		}
		vec4 newColor = vec4(accumulator / float(sampleCount), 1.0);
		return newColor;
	}

	void main() {
		// time = mod(time, 1.);
		vec2 uv = fragCoord/iResolution.xy;
		float alpha = texture(bitmap, uv).a;
		vec2 p = openfl_TextureCoordv.xy;
		vec3 color = texture2D(bitmap, p).rgb;

		glitchSwap(p);
		// glitchTime(p, time);
		glitchStatic(p);

		color = transverseChromatic(p).rgb;
		glitchColor(p, color);
		// color = linearToScreen(color);

	    gl_FragColor = vec4(color.r * alpha, color.g * alpha, color.b * alpha, alpha);
	}
	')
  public function new()
  {
    super();
  }
}

class GlitchyChromaticEffect extends ShaderBase
{
  public var shader:GlitchyChromaticShader = new GlitchyChromaticShader();
  public var glitch(default, set):Float = 0;

  var iTime:Float = 0;

  public function new()
  {
    shader.iTime.value = [0];
    shader.GLITCH.value = [glitch];
  }

  override public function update(elapsed:Float)
  {
    iTime += elapsed;
    shader.iTime.value = [iTime];
    shader.GLITCH.value = [glitch];
  }

  function set_glitch(value:Float)
  {
    glitch = value;
    shader.GLITCH.value = [glitch];
    return value;
  }
}

class GlitchyChromaticShader extends SLEFlxShaderUtil
{
  @:glFragmentSource('
    #pragma header
    uniform float iTime;
    uniform float GLITCH;
    #define iChannel0 bitmap
    #define texture flixel_texture2D
    #define fragColor gl_FragColor
    #define mainImage main
    const int NUM_SAMPLES = 5;


    float sat( float t ) {
        return clamp( t, 0.0, 1.0 );
    }

    vec2 sat( vec2 t ) {
        return clamp( t, 0.0, 1.0 );
    }
    float remap  ( float t, float a, float b ) {
        return sat( (t - a) / (b - a) );
    }
    float linterp( float t ) {
        return sat( 1.0 - abs( 2.0*t - 1.0 ) );
    }

    vec3 spectrum_offset( float t ) {
        vec3 ret;
        float lo = step(t,0.5);
        float hi = 1.0-lo;
        float w = linterp( remap( t, 1.0/6.0, 5.0/6.0 ) );
        float neg_w = 1.0-w;
        ret = vec3(lo,1.0,hi) * vec3(neg_w, w, neg_w);
        return pow( ret, vec3(1.0/2.2) );
    }

    //note: [0;1]
    float rand( vec2 n ) {
      return fract(sin(dot(n.xy, vec2(12.9898, 78.233)))* 43758.5453);
    }
    //note: [-1;1]
    float srand( vec2 n ) {
        return rand(n) * 2.0 - 1.0;
    }

    float mytrunc( float x, float num_levels )
    {
        return floor(x*num_levels) / num_levels;
    }
    vec2 mytrunc( vec2 x, float num_levels )
    {
        return floor(x*num_levels) / num_levels;
    }

    void mainImage()
    {
    //vec2 uv = openfl_TextureCoordv.xy;
    vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
    vec2 iResolution = openfl_TextureSize;

        vec2 uv = fragCoord.xy / iResolution.xy;
        uv.y = uv.y;

        float time = mod(iTime*100.0, 32.0)/10.0; // + modelmat[0].x + modelmat[0].z;

        float gnm = sat( GLITCH );
        float rnd0 = rand( mytrunc( vec2(time, time), 6.0 ) );
        float r0 = sat((1.0-gnm)*0.7 + rnd0);
        float rnd1 = rand( vec2(mytrunc( uv.x, 10.0*r0 ), time) ); //horz
        //float r1 = 1.0f - sat( (1.0f-gnm)*0.5f + rnd1 );
        float r1 = 0.5 - 0.5 * gnm + rnd1;
        //r1 = 1.0 - max( 0.0, ((r1<1.0) ? r1 : 0.9999999) ); //note: weird ass bug on old drivers
        float rnd2 = rand( vec2(mytrunc( uv.y, 40.0*r1 ), time) ); //vert
        float r2 = sat( rnd2 );
        float rnd3 = rand( vec2(mytrunc( uv.y, 10.0*r0 ), time) );
        float r3 = (1.0-sat(rnd3+0.8)) - 0.1;

        float pxrnd = rand( uv + time );

        float ofs = 0.05 * r2 * GLITCH ;
        ofs += 0.5 * pxrnd * ofs;

        uv.y += 0.2 * r3 * GLITCH;

        const float RCP_NUM_SAMPLES_F = 1.0/ float(NUM_SAMPLES);

        vec4 sum = vec4(0.0);
        vec3 wsum = vec3(0.0);
        for( int i=0; i<NUM_SAMPLES; ++i )
        {
            float t = float(i) * RCP_NUM_SAMPLES_F;
            uv.x = sat( uv.x + ofs * t );
            vec4 samplecol = texture( iChannel0, uv);
            vec3 s = spectrum_offset( t );
            samplecol.rgb = samplecol.rgb * s;
            sum += samplecol;
            wsum += s;
        }
        sum.rgb /= wsum;
        sum.a *= RCP_NUM_SAMPLES_F;

        fragColor.a = sum.a;
        fragColor.rgb = sum.rgb; // * outcol0.a;
    }
    ')
  public function new()
  {
    super();
  }
}

class GocpEffect extends ShaderBase
{
  public var shader:GocpShader = new GocpShader();
  public var iTime:Float = 0;
  public var texAlpha(default, set):Float = 0;
  public var saturation(default, set):Float = 0;

  public var threshold:Float = 0;
  public var rVal:Float = 0;
  public var gVal:Float = 0;
  public var bVal:Float = 0;

  public function new()
  {
    shader.iTime.value = [0];
    shader.texAlpha.value = [texAlpha];
    shader.saturation.value = [saturation];

    shader.threshold.value = [threshold];
    shader.rVal.value = [rVal];
    shader.gVal.value = [gVal];
    shader.bVal.value = [bVal];
  }

  override public function update(elapsed:Float)
  {
    iTime += elapsed;
    shader.iTime.value = [iTime];
    shader.texAlpha.value = [texAlpha];
    shader.saturation.value = [saturation];

    shader.threshold.value = [threshold];
    shader.rVal.value = [rVal];
    shader.gVal.value = [gVal];
    shader.bVal.value = [bVal];
  }

  function set_texAlpha(ta:Float):Float
  {
    texAlpha = ta;
    shader.texAlpha.value = [texAlpha];
    return ta;
  }

  function set_saturation(s:Float):Float
  {
    saturation = s;
    shader.saturation.value = [saturation];
    return s;
  }

  function set_threshold(th:Float):Float
  {
    threshold = th;
    shader.threshold.value = [threshold];
    return th;
  }

  function set_rVal(rv:Float):Float
  {
    rVal = rv;
    shader.rVal.value = [rVal];
    return rv;
  }

  function set_gVal(gv:Float):Float
  {
    gVal = gv;
    shader.gVal.value = [gVal];
    return gv;
  }

  function set_bVal(bv:Float):Float
  {
    bVal = bv;
    shader.bVal.value = [bVal];
    return bv;
  }
}

class GocpShader extends SLEFlxShaderUtil
{
  @:glFragmentSource('
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
    ')
  public function new()
  {
    super();
  }
}

class GreyscaleEffect extends ShaderBase // Has No Values To Add, Change, Take
{
  public var shader:GreyscaleShader = new GreyscaleShader();

  public function new() {}
}

class GreyscaleShader extends SLEFlxShaderUtil
{
  @:glFragmentSource(' void main()
{
  vec2
  uv = openfl_TextureCoordv;
  vec4
  tex = flixel_texture2D(bitmap, uv);
  vec3
  greyScale = vec3(.3, .587, .114);
  gl_FragColor = vec4(vec3(dot(tex.rgb, greyScale)), tex.a);
}
')
  public function new()
  {
    super();
  }
}

class GreyscaleEffectNew extends ShaderBase
{
  public var shader(default, null):GreyscaleShaderNew = new GreyscaleShaderNew();
  public var strength:Float = 0.0;

  public function new():Void
  {
    shader.strength.value = [0];
  }

  override public function update(elapsed:Float):Void
  {
    shader.strength.value[0] = strength;
  }
}

class GreyscaleShaderNew extends FlxFixedShader
{
  @:glFragmentSource('#pragma header uniform float strength;
void main()
{
  vec2
  uv = openfl_TextureCoordv;
  vec4
  col = flixel_texture2D(bitmap, uv);
  float
  grey = dot(col.rgb, vec3(0.299, 0.587, 0.114)); // https://en.wikipedia.org/wiki/Grayscale
  gl_FragColor = mix(col, vec4(grey, grey, grey, col.a), strength);
}
')
  public function new()
  {
    super();
  }
}

class HeatEffect extends ShaderBase
{
  public var shader(default, null):HeatShader = new HeatShader();
  public var strength:Float = 1.0;

  var iTime:Float = 0.0;

  public function new():Void
  {
    shader.strength.value = [strength];
    shader.iTime.value = [0.0];
  }

  override public function update(elapsed:Float):Void
  {
    shader.strength.value = [strength];
    iTime += elapsed;
    shader.iTime.value = [iTime];
  }
}

class HeatShader extends FlxFixedShader
{
  @:glFragmentSource('#pragma header uniform float strength;
uniform float iTime;
float rand(vec2 n)
{
  return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}
float noise(vec2 n)
{
  const
  vec2
  d = vec2(0.0, 1.0);
  vec2
  b = floor(n),
  f = smoothstep(vec2(0.0), vec2(1.0), fract(n));
  return mix(mix(rand(b), rand(b + d.yx), f.x), mix(rand(b + d.xy), rand(b + d.yy), f.x), f.y);
}
// https://www.shadertoy.com/view/XsVSRd
// edited version of this
// partially using a version in the comments that doesnt use a texture and uses noise instead
void main()
{
  vec2
  uv = openfl_TextureCoordv.xy;
  vec2
  offsetUV = vec4(noise(vec2(uv.x, uv.y + (iTime * 0.1)) * vec2(50))).xy;
  offsetUV -= vec2(.5, .5);
  offsetUV *= 2.;
  offsetUV *= 0.01 * 0.1 * strength;
  offsetUV *= (1. + uv.y);
  gl_FragColor = flixel_texture2D(bitmap, uv + offsetUV);
}
')
  public function new()
  {
    super();
  }
}

class HeatWaveEffect extends ShaderBase
{
  public var shader:HeatWaveShader = new HeatWaveShader();
  public var iTime:Float = 0;
  public var strength:Float = 0;
  public var speed:Float = 0;

  public function new()
  {
    shader.time.value = [0];
    shader.strength.value = [strength];
    shader.speed.value = [speed];
  }

  override public function update(elapsed:Float):Void
  {
    iTime += elapsed;
    shader.time.value = [iTime];
    shader.strength.value = [strength];
    shader.speed.value = [speed];
  }
}

class HeatWaveShader extends SLEFlxShaderUtil
{
  @:glFragmentSource('
    #pragma header

    uniform float time;
    uniform float strength;
    uniform float speed;

    float rand(vec2 n) { return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);}
    float noise(vec2 n) {
    const vec2 d = vec2(0.0, 1.0);
    vec2 b = floor(n), f = smoothstep(vec2(0.0), vec2(1.0), fract(n));
    return mix(mix(rand(b), rand(b + d.yx), f.x), mix(rand(b + d.xy), rand(b + d.yy), f.x), f.y);
    }

    void main() {
        vec2 p_m = openfl_TextureCoordv.xy;
        vec2 p_d = p_m;

        p_d.y = 1.0-p_d.y;
        p_d.t += (time * 0.1) * speed;

        p_d = mod(p_d, 1.0);
        vec4 dst_map_val = vec4(noise(p_d * vec2(50)));

        vec2 dst_offset = dst_map_val.xy;
        dst_offset -= vec2(.5,.5);
        dst_offset *= 2.;
        dst_offset *= (0.01 * strength);

        //reduce effect towards Y top
        dst_offset *= (1. - p_m.t);

        vec2 dist_tex_coord = p_m.st + dst_offset;
        gl_FragColor = flixel_texture2D(bitmap, dist_tex_coord);
    }
    ')
  public function new()
  {
    super();
  }
}

class IndividualGlitchesEffect extends ShaderBase
{
  public var shader:IndividualGlitchesShader = new IndividualGlitchesShader();

  public var binaryIntensity(default, set):Float = 0;

  public function new()
  {
    shader.binaryIntensity.value = [binaryIntensity];
  }

  override public function update(elpased:Float)
  {
    shader.binaryIntensity.value = [binaryIntensity];
  }

  public function set_binaryIntensity(binary:Float):Float
  {
    binaryIntensity = binary;
    shader.binaryIntensity.value = [binaryIntensity];
    return binary;
  }
}

class IndividualGlitchesShader extends SLEFlxShaderUtil
{
  @:glFragmentSource('
    #pragma header

    uniform float binaryIntensity;

    void main() {
        vec2 uv = openfl_TextureCoordv.xy;

        // get snapped position
        float psize = 0.04 * binaryIntensity;
        float psq = 1.0 / psize;

        float px = floor(uv.x * psq + 0.5) * psize;
        float py = floor(uv.y * psq + 0.5) * psize;

        vec4 colSnap = texture2D(bitmap, vec2(px, py));

        float lum = pow(1.0 - (colSnap.r + colSnap.g + colSnap.b) / 3.0, binaryIntensity);

        float qsize = psize * lum;
        float qsq = 1.0 / qsize;

        float qx = floor(uv.x * qsq + 0.5) * qsize;
        float qy = floor(uv.y * qsq + 0.5) * qsize;

        float rx = (px - qx) * lum + uv.x;
        float ry = (py - qy) * lum + uv.y;

        gl_FragColor = texture2D(bitmap, vec2(rx, ry));
    }
    ')
  public function new()
  {
    super();
  }
}

class InvertEffect extends ShaderBase
{
  public var shader:InvertShader = new InvertShader();
}

class InvertShader extends SLEFlxShaderUtil
{
  @:glFragmentSource('
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
    ')
  public function new()
  {
    super();
  }
}

class MirrorRepeatEffect extends ShaderBase
{
  public var shader(default, null):MirrorRepeatShader = new MirrorRepeatShader();
  public var zoom:Float = 5.0;

  var iTime:Float = 0.0;

  public var angle:Float = 0.0;

  public var x:Float = 0.0;
  public var y:Float = 0.0;

  public function new():Void
  {
    shader.zoom.value = [zoom];
    shader.angle.value = [angle];
    shader.iTime.value = [0.0];
    shader.x.value = [x];
    shader.y.value = [y];
  }

  override public function update(elapsed:Float):Void
  {
    shader.zoom.value = [zoom];
    shader.angle.value = [angle];
    iTime += elapsed;
    shader.iTime.value = [iTime];
    shader.x.value = [x];
    shader.y.value = [y];
  }
}

// moved to a seperate shader because not all modcharts need the barrel shit and probably runs slightly better on weaker pcs
class MirrorRepeatShader extends FlxFixedShader
{
  @:glFragmentSource('#pragma header // written by TheZoroForce240
uniform float zoom;
uniform float angle;
uniform float iTime;
uniform float x;
uniform float y;
vec4 render(vec2 uv)
{
  uv.x += x;
  uv.y += y;
  // funny mirroring shit
  if ((uv.x > 1.0 || uv.x < 0.0) && abs(mod(uv.x, 2.0)) > 1.0) uv.x = (0.0 - uv.x) + 1.0;
  if ((uv.y > 1.0 || uv.y < 0.0) && abs(mod(uv.y, 2.0)) > 1.0) uv.y = (0.0 - uv.y) + 1.0;
  return flixel_texture2D(bitmap, vec2(abs(mod(uv.x, 1.0)), abs(mod(uv.y, 1.0))));
}
void main()
{
  vec2
  iResolution = vec2(1280, 720);
  // rotation bullshit
  vec2
  center = vec2(0.5, 0.5);
  vec2
  uv = openfl_TextureCoordv.xy;
  mat2
  scaling = mat2(zoom, 0.0, 0.0, zoom);
  // uv = uv * scaling;
  float
  angInRad = radians(angle);
  mat2
  rotation = mat2(cos(angInRad), -sin(angInRad), sin(angInRad), cos(angInRad));
  // used to stretch back into 16:9
  // 0.5625 is from 9/16
  mat2
  aspectRatioShit = mat2(0.5625, 0.0, 0.0, 1.0);
  vec2
  fragCoordShit = iResolution * openfl_TextureCoordv.xy;
  uv = (fragCoordShit - .5 * iResolution.xy) / iResolution.y; // this helped a little, specifically the guy in the comments: https://www.shadertoy.com/view/tsSXzt
  uv = uv * scaling;
  uv = (aspectRatioShit) * (rotation * uv);
  uv = uv.xy + center; // move back to center
  gl_FragColor = render(uv);
}
')
  public function new()
  {
    super();
  }
}

class MonitorEffect extends ShaderBase
{
  public var shader:MonitorShader = new MonitorShader();
}

class MonitorShader extends SLEFlxShaderUtil
{
  @:glFragmentSource('
    #pragma header

    float zoom = 1.1;
    void main()
    {
        vec2 uv = openfl_TextureCoordv;
        uv = (uv-.5)*2.;
        uv *= zoom;

        uv.x *= 1. + pow(abs(uv.y/2.),3.);
        uv.y *= 1. + pow(abs(uv.x/2.),3.);
        uv = (uv + 1.)*.5;

        vec4 tex = vec4(
            texture2D(bitmap, uv+.0020).r,
            texture2D(bitmap, uv+.000).g,
            texture2D(bitmap, uv+.002).b,
            1.0
        );

        tex *= smoothstep(uv.x,uv.x+0.01,1.)*smoothstep(uv.y,uv.y+0.01,1.)*smoothstep(0,0.,uv.x)*smoothstep(0,0.,uv.y);

        float avg = (tex.r+tex.g+tex.b)/5.;
        gl_FragColor = tex + pow(avg,5.);
    }
    ')
  public function new()
  {
    super();
  }
}

class MosaicEffect extends ShaderBase
{
  public var shader(default, null):MosaicShader = new MosaicShader();
  public var strength:Float = 0.0;

  public function new():Void
  {
    shader.strength.value = [0];
  }

  override public function update(elapsed:Float):Void
  {
    shader.strength.value[0] = strength;
  }
}

class MosaicShader extends FlxFixedShader
{
  @:glFragmentSource('#pragma header uniform float strength;
void main()
{
  if (strength == 0.0)
  {
    gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
    return;
  }
  vec2
  blocks = openfl_TextureSize / vec2(strength, strength);
  gl_FragColor = flixel_texture2D(bitmap, floor(openfl_TextureCoordv * blocks) / blocks);
}
')
  public function new()
  {
    super();
  }
}

class MultiSplitEffect extends ShaderBase
{
  public var shader:MultiSplitShader = new MultiSplitShader();

  public var mult(default, set):Float = 0;

  public function new()
  {
    shader.multi.value = [mult];
  }

  override public function update(elapsed:Float)
  {
    shader.multi.value = [mult];
  }

  public function set_mult(isplit:Float):Float
  {
    mult = isplit;
    shader.multi.value = [mult];
    return isplit;
  }
}

class MultiSplitShader extends SLEFlxShaderUtil
{
  @:glFragmentSource("
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
  ")
  public function new()
  {
    super();
  }
}

class PaletteEffect extends ShaderBase
{
  public var shader(default, null):PaletteShader = new PaletteShader();
  public var strength:Float = 0.0;
  public var paletteSize:Float = 8.0;

  public function new():Void
  {
    shader.strength.value = [strength];
    shader.paletteSize.value = [paletteSize];
  }

  override public function update(elapsed:Float):Void
  {
    shader.strength.value = [strength];
    shader.paletteSize.value = [paletteSize];
  }
}

class PaletteShader extends FlxFixedShader
{
  @:glFragmentSource('#pragma header uniform float strength;
uniform float paletteSize;
float palette(float val, float size)
{
  float
  f = floor(val * (size - 1.0) + 0.5);
  return f / (size - 1.0);
}
void main()
{
  vec2
  uv = openfl_TextureCoordv;
  vec4
  col = flixel_texture2D(bitmap, uv);
  vec4
  reducedCol = vec4(col.r, col.g, col.b, col.a);
  reducedCol.r = palette(reducedCol.r, 8.0);
  reducedCol.g = palette(reducedCol.g, 8.0);
  reducedCol.b = palette(reducedCol.b, 8.0);
  gl_FragColor = mix(col, reducedCol, strength);
}
')
  public function new()
  {
    super();
  }
}

class PerlinSmokeEffect extends ShaderBase
{
  public var shader(default, null):PerlinSmokeShader = new PerlinSmokeShader();
  public var waveStrength:Float = 0; // for screen wave (only for ruckus)
  public var smokeStrength:Float = 1;
  public var speed:Float = 1;

  var iTime:Float = 0.0;

  public function new():Void
  {
    shader.waveStrength.value = [waveStrength];
    shader.smokeStrength.value = [smokeStrength];
    shader.iTime.value = [0.0];
  }

  override public function update(elapsed:Float):Void
  {
    shader.waveStrength.value = [waveStrength];
    shader.smokeStrength.value = [smokeStrength];
    iTime += elapsed * speed;
    shader.iTime.value = [iTime];
  }
}

class PerlinSmokeShader extends FlxFixedShader
{
  @:glFragmentSource('#pragma header uniform float iTime;
uniform float waveStrength;
uniform float smokeStrength;
// https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
//	Classic Perlin 3D Noise
//	by Stefan Gustavson
//
vec4 permute(vec4 x)
{
  return mod(((x * 34.0) + 1.0) * x, 289.0);
}
vec4 taylorInvSqrt(vec4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}
vec3 fade(vec3 t)
{
  return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}
float cnoise(vec3 P)
{
  vec3
  Pi0 = floor(P); // Integer part for indexing
  vec3
  Pi1 = Pi0 + vec3(1.0); // Integer part + 1
  Pi0 = mod(Pi0, 289.0);
  Pi1 = mod(Pi1, 289.0);
  vec3
  Pf0 = fract(P); // Fractional part for interpolation
  vec3
  Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0
  vec4
  ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
  vec4
  iy = vec4(Pi0.yy, Pi1.yy);
  vec4
  iz0 = Pi0.zzzz;
  vec4
  iz1 = Pi1.zzzz;
  vec4
  ixy = permute(permute(ix) + iy);
  vec4
  ixy0 = permute(ixy + iz0);
  vec4
  ixy1 = permute(ixy + iz1);
  vec4
  gx0 = ixy0 / 7.0;
  vec4
  gy0 = fract(floor(gx0) / 7.0) - 0.5;
  gx0 = fract(gx0);
  vec4
  gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
  vec4
  sz0 = step(gz0, vec4(0.0));
  gx0 -= sz0 * (step(0.0, gx0) - 0.5);
  gy0 -= sz0 * (step(0.0, gy0) - 0.5);
  vec4
  gx1 = ixy1 / 7.0;
  vec4
  gy1 = fract(floor(gx1) / 7.0) - 0.5;
  gx1 = fract(gx1);
  vec4
  gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
  vec4
  sz1 = step(gz1, vec4(0.0));
  gx1 -= sz1 * (step(0.0, gx1) - 0.5);
  gy1 -= sz1 * (step(0.0, gy1) - 0.5);
  vec3
  g000 = vec3(gx0.x, gy0.x, gz0.x);
  vec3
  g100 = vec3(gx0.y, gy0.y, gz0.y);
  vec3
  g010 = vec3(gx0.z, gy0.z, gz0.z);
  vec3
  g110 = vec3(gx0.w, gy0.w, gz0.w);
  vec3
  g001 = vec3(gx1.x, gy1.x, gz1.x);
  vec3
  g101 = vec3(gx1.y, gy1.y, gz1.y);
  vec3
  g011 = vec3(gx1.z, gy1.z, gz1.z);
  vec3
  g111 = vec3(gx1.w, gy1.w, gz1.w);
  vec4
  norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
  g000 *= norm0.x;
  g010 *= norm0.y;
  g100 *= norm0.z;
  g110 *= norm0.w;
  vec4
  norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
  g001 *= norm1.x;
  g011 *= norm1.y;
  g101 *= norm1.z;
  g111 *= norm1.w;
  float
  n000 = dot(g000, Pf0);
  float
  n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
  float
  n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
  float
  n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
  float
  n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
  float
  n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
  float
  n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
  float
  n111 = dot(g111, Pf1);
  vec3
  fade_xyz = fade(Pf0);
  vec4
  n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
  vec2
  n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
  float
  n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x);
  return 2.2 * n_xyz;
}
float generateSmoke(vec2 uv, vec2 offset, float scale, float speed)
{
  return cnoise(vec3((uv.x + offset.x) * scale, (uv.y + offset.y) * scale, iTime * speed));
}
float getSmoke(vec2 uv)
{
  float
  smoke = 0.0;
  if (smokeStrength == 0.0) return smoke;
  float
  smoke1 = generateSmoke(uv, vec2(0.0 - (iTime * 0.5), 0.0 + sin(iTime * 0.1) + (iTime * 0.1)), 1.0, 0.5 * 0.1);
  float
  smoke2 = generateSmoke(uv, vec2(200.0 - (iTime * 0.2), 200.0 + sin(iTime * 0.1) + (iTime * 0.05)), 4.0, 0.3 * 0.1);
  float
  smoke3 = generateSmoke(uv, vec2(700.0 - (iTime * 0.1), 700.0 + sin(iTime * 0.1) + (iTime * 0.1)), 6.0, 0.7 * 0.1);
  smoke = smoke1 * smoke2 * smoke3 * 2.0;
  return smoke * smokeStrength;
}
void main()
{
  vec2
  uv = openfl_TextureCoordv.xy + vec2(sin(cnoise(vec3(0.0, openfl_TextureCoordv.y * 2.5, iTime))), 0.0) * waveStrength;
  vec2
  smokeUV = uv;
  float
  smokeFactor = getSmoke(uv);
  if (smokeFactor < 0.0) smokeFactor = 0.0;
  vec3
  finalCol = flixel_texture2D(bitmap, uv).rgb + smokeFactor;
  gl_FragColor = vec4(finalCol.r, finalCol.g, finalCol.b, flixel_texture2D(bitmap, uv).a);
}
')
  public function new()
  {
    super();
  }
}

// Quick plane raymarcher thingy by 4mbr0s3 2 (partially)
class PlaneRaymarcherEffect extends ShaderBase
{
  public var shader(default, null):PlaneRaymarcherShader = new PlaneRaymarcherShader();

  public var pitch(get, set):Float;
  public var yaw(get, set):Float;
  public var cameraOffX(get, set):Float;
  public var cameraOffY(get, set):Float;
  public var cameraOffZ(get, set):Float;
  public var cameraLookAtX(get, set):Float;
  public var cameraLookAtY(get, set):Float;
  public var cameraLookAtZ(get, set):Float;

  function get_pitch():Float
  {
    return shader.pitch.value[0];
  }

  function get_cameraOffX():Float
  {
    return shader.cameraOff.value[0];
  }

  function get_cameraOffY():Float
  {
    return shader.cameraOff.value[1];
  }

  function get_cameraOffZ():Float
  {
    return shader.cameraOff.value[2];
  }

  function get_cameraLookAtX():Float
  {
    return shader.cameraLookAt.value[0];
  }

  function get_cameraLookAtY():Float
  {
    return shader.cameraLookAt.value[1];
  }

  function get_cameraLookAtZ():Float
  {
    return shader.cameraLookAt.value[2];
  }

  function set_pitch(value:Float):Float
  {
    shader.pitch.value = [value];
    return value;
  }

  function set_cameraOffX(value:Float):Float
  {
    shader.cameraOff.value[0] = value;
    return value;
  }

  function set_cameraOffY(value:Float):Float
  {
    shader.cameraOff.value[1] = value;
    return value;
  }

  function set_cameraOffZ(value:Float):Float
  {
    shader.cameraOff.value[2] = value;
    return value;
  }

  function set_cameraLookAtX(value:Float):Float
  {
    shader.cameraLookAt.value[0] = value;
    return value;
  }

  function set_cameraLookAtY(value:Float):Float
  {
    shader.cameraLookAt.value[1] = value;
    return value;
  }

  function set_cameraLookAtZ(value:Float):Float
  {
    shader.cameraLookAt.value[2] = value;
    return value;
  }

  function get_yaw():Float
  {
    return shader.yaw.value[0];
  }

  function set_yaw(value:Float):Float
  {
    shader.yaw.value = [value];
    return value;
  }

  public function new():Void
  {
    shader.cameraOff.value = [0, 0, 0];
    shader.cameraLookAt.value = [0, 0, 0];
    shader.pitch.value = [0];
    shader.yaw.value = [0];
    shader.uTime.value = [0];
  }

  override public function update(elapsed:Float):Void
  {
    shader.uTime.value[0] += elapsed;
  }
}

class PlaneRaymarcherShader extends SLEFlxShaderUtil
{
  // Drafted this in Shadertoy: https://www.shadertoy.com/view/fdlXzn
  @:glFragmentSource('
    // "RayMarching starting point"
    // by Martijn Steinrucken aka The Art of Code/BigWings - 2020
    // The MIT License
    // Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    // Original shader: https://www.shadertoy.com/view/WtGXDD
    // You can use this shader as a template for ray marching shaders

    #pragma header

    const float MAX_STEPS = 100;
    const float MAX_DIST = 100.0;
    const float SURF_DIST = 0.01;
    const float WIDTH = 1.778;
    const float HEIGHT = 1.0;

    uniform float uTime;
    uniform float pitch;
    uniform float yaw;
    uniform vec3 cameraOff;
    uniform vec3 cameraLookAt;

    mat2 Rot(float a) {
        float s=sin(a), c=cos(a);
        return mat2(c, -s, s, c);
    }

    float BoxSDF( vec3 p, vec3 b )
    {
      vec3 q = abs(p) - b;
      return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
    }

    float GetDist(vec3 p) {
      vec4 s = vec4(0, 1, 6, 1);

      float playfieldDist = BoxSDF(p, vec3(WIDTH, HEIGHT, 0));
      float d = playfieldDist; // Union

      return d;
    }

    vec3 GetNormal(vec3 p) {
      float d = GetDist(p);
      vec2 e = vec2(.001, 0);

      vec3 n = d - vec3(
        GetDist(p-e.xyy),
        GetDist(p-e.yxy),
        GetDist(p-e.yyx));

      return normalize(n);
    }


    vec3 GetRayDir(vec2 uv, vec3 p, vec3 l, float z) {
      vec3 f = normalize(l-p),
        r = normalize(cross(vec3(0.0,1.0,0.0), f)),
        u = cross(f,r),
        c = f*z,
        i = c + uv.x*r + uv.y*u,
        d = normalize(i);
      return d;
    }

    float RayMarch(vec3 ro, vec3 rd) {
        float d0 = 0.; // Distance marched
        for (int i = 0; i < MAX_STEPS; i++) {
            vec3 p = ro + rd * d0;
            float dS = GetDist(p); // Closest distance to surface
            d0 += dS;
            if (d0 > MAX_DIST || dS < SURF_DIST) {
                break;
            }
        }
        return d0;
    }

    void main()
    {
        vec2 uv = openfl_TextureCoordv - vec2(0.5);
        uv.x *= WIDTH / HEIGHT;
        vec3 ro = vec3(0, 0, -2); // Ray origin
        ro += cameraOff;
        ro.yz *= Rot(pitch);
        ro.xz *= Rot(yaw);
        vec3 rd = GetRayDir(uv, ro, cameraLookAt, 1.);

        float d = RayMarch(ro, rd);

        vec4 col = vec4(0);

        // Collision
        if (d < MAX_DIST) {
            vec3 p = ro + rd * d;
            vec3 n = GetNormal(p);

            float dif = dot(n, normalize(vec3(1,2,3)))*0.5+0.5;
            col += dif * dif;

            uv = vec2(p.x / WIDTH, p.y) * 0.5 + vec2(0.5);
            col = texture2D(bitmap, uv);
        }

        gl_FragColor = col;
    }')
  public function new()
  {
    super();
  }
}

// https://www.shadertoy.com/view/MlfBWr
// le shader
class RainFallEffect extends ShaderBase
{
  public var shader(default, null):RainFallShader = new RainFallShader();

  var iTime:Float = 0.0;

  public function new():Void
  {
    shader.iTime.value = [0.0];
  }

  override public function update(elapsed:Float):Void
  {
    iTime += elapsed;
    shader.iTime.value = [iTime];
  }
}

class RainFallShader extends FlxFixedShader
{
  @:glFragmentSource('#pragma header uniform float iTime;
vec2 rand(vec2 c)
{
  mat2
  m = mat2(12.9898, .16180, 78.233, .31415);
  return fract(sin(m * c) * vec2(43758.5453, 14142.1));
}
vec2 noise(vec2 p)
{
  vec2
  co = floor(p);
  vec2
  mu = fract(p);
  mu = 3. * mu * mu - 2. * mu * mu * mu;
  vec2
  a = rand((co + vec2(0., 0.)));
  vec2
  b = rand((co + vec2(1., 0.)));
  vec2
  c = rand((co + vec2(0., 1.)));
  vec2
  d = rand((co + vec2(1., 1.)));
  return mix(mix(a, b, mu.x), mix(c, d, mu.x), mu.y);
}
vec2 round(vec2 num)
{
  num.x = floor(num.x + 0.5);
  num.y = floor(num.y + 0.5);
  return num;
}
void main()
{
  vec2
  iResolution = vec2(1280, 720);
  vec2
  c = openfl_TextureCoordv.xy;
  vec2
  u = c,
  v = (c * .1),
  n = noise(v * 200.); // Displacement
  vec4
  f = flixel_texture2D(bitmap, openfl_TextureCoordv.xy);
  // Loop through the different inverse sizes of drops
  for (float r = 4.;
  r > 0.;
  r--
)
  {
    vec2
    x = iResolution.xy * r * .015, // Number of potential drops (in a grid)
    p = 6.28 * u * x + (n - .5) * 2.,
    s = sin(p);
    // Current drop properties. Coordinates are rounded to ensure a
    // consistent value among the fragment of a given drop.
    vec2
    v = round(u * x - 0.25) / x;
    vec4
    d = vec4(noise(v * 200.), noise(v));
    // Drop shape and fading
    float
    t = (s.x + s.y) * max(0., 1. - fract(iTime * (d.b + .1) + d.g) * 2.);
    ;
    // d.r -> only x% of drops are kept on, with x depending on the size of drops
    if (d.r < (5. - r) * .08 && t > .5)
    {
      // Drop normal
      vec3
      v = normalize(-vec3(cos(p), mix(.2, 2., t - .5)));
      // fragColor = vec4(v * 0.5 + 0.5, 1.0);  // show normals
      // Poor mans refraction (no visual need to do more)
      f = flixel_texture2D(bitmap, u - v.xy * .3);
    }
  }
  gl_FragColor = f;
}
')
  public function new()
  {
    super();
  }
}

class RayMarchEffect extends ShaderBase
{
  public var shader:RayMarchShader = new RayMarchShader();
  public var x:Float = 0;
  public var y:Float = 0;
  public var z:Float = 0;
  public var zoom:Float = -2;

  // Now you can customize these things for the shader! (NOW CAN CHANGE HOW MANY "windows" OR DISTANCE IS VISIBLE WHICH MAKES IT A BETTER SHADER)!
  public var stepsLimit:Float = 0;
  public var distLimit:Float = 0;
  public var surfDistLimit:Float = 0;

  public function new()
  {
    shader.iResolution.value = [FlxG.width, FlxG.height];
    shader.rotation.value = [0, 0, 0];
    shader.zoom.value = [zoom];

    shader.MAX_STEPS_LIMIT.value = [stepsLimit];
    shader.MAX_DIST_LIMIT.value = [distLimit];
    shader.SURF_DIST_LIMIT.value = [surfDistLimit];
  }

  override public function update(elapsed:Float)
  {
    shader.iResolution.value = [FlxG.width, FlxG.height];
    shader.rotation.value = [x * FlxAngle.TO_RAD, y * FlxAngle.TO_RAD, z * FlxAngle.TO_RAD];
    shader.zoom.value = [zoom];

    shader.MAX_STEPS_LIMIT.value = [stepsLimit];
    shader.MAX_DIST_LIMIT.value = [distLimit];
    shader.SURF_DIST_LIMIT.value = [surfDistLimit];
  }
}

// shader from here: https://www.shadertoy.com/view/WtGXDD
class RayMarchShader extends FlxFixedShader
{
  @:glFragmentSource('
  #pragma header

  // "RayMarching starting point"
  // by Martijn Steinrucken aka The Art of Code/BigWings - 2020
  // The MIT License
  // Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  // Email: countfrolic@gmail.com
  // Twitter: @The_ArtOfCode
  // YouTube: youtube.com/TheArtOfCodeIsCool
  // Facebook: https://www.facebook.com/groups/theartofcode/
  //
  // You can use this shader as a template for ray marching shaders

  const float MAX_STEPS = 100;
  const float MAX_DIST = 100.0;
  const float SURF_DIST = 0.001;
  uniform vec3 rotation;
  uniform vec3 iResolution;
  uniform float zoom;
  uniform float MAX_STEPS_LIMIT;
  uniform float MAX_DIST_LIMIT;
  uniform float SURF_DIST_LIMIT;
  // Rotation matrix around the X axis.
  mat3 rotateX(float theta)
  {
    float
    c = cos(theta);
    float
    s = sin(theta);
    return mat3(vec3(1.0, 0.0, 0.0), vec3(0.0, c, -s), vec3(0.0, s, c));
  }
  // Rotation matrix around the Y axis.
  mat3 rotateY(float theta)
  {
    float
    c = cos(theta);
    float
    s = sin(theta);
    return mat3(vec3(c, 0.0, s), vec3(0.0, 1.0, 0.0), vec3(-s, 0.0, c));
  }
  // Rotation matrix around the Z axis.
  mat3 rotateZ(float theta)
  {
    float
    c = cos(theta);
    float
    s = sin(theta);
    return mat3(vec3(c, -s, 0.0), vec3(s, c, 0.0), vec3(0.0, 0.0, 1.0));
  }
  mat2 Rot(float a)
  {
    float
    s = sin(a),
    c = cos(a);
    return mat2(c, -s, s, c);
  }
  float sdBox(vec3 p, vec3 s)
  {
    // p = p * rotateX(rotation.x) * rotateY(rotation.y) * rotateZ(rotation.z);
    p = abs(p) - s;
    return length(max(p, 0.)) + min(max(p.x, max(p.y, p.z)), 0.);
  }
  float plane(vec3 p, vec3 offset)
  {
    float
    d = p.z;
    return d;
  }
  float GetDist(vec3 p)
  {
    float
    d = plane(p, vec3(0.0, 0.0, 0.0));
    return d;
  }
  float RayMarch(vec3 ro, vec3 rd)
  {
    float
    dO = 0.;
    for (int i = 0;
    i < MAX_STEPS + MAX_STEPS_LIMIT;
    i++
  )
    {
      vec3
      p = ro + rd * dO;
      float
      dS = GetDist(p);
      dO += dS;
      if (dO > MAX_DIST + MAX_DIST_LIMIT || abs(dS) < SURF_DIST + SURF_DIST_LIMIT) break;
    }
    return dO;
  }
  vec3 GetNormal(vec3 p)
  {
    float
    d = GetDist(p);
    vec2
    e = vec2(.001, 0.0);
    vec3
    n = d - vec3(GetDist(p - e.xyy), GetDist(p - e.yxy), GetDist(p - e.yyx));
    return normalize(n);
  }
  vec3 GetRayDir(vec2 uv, vec3 p, vec3 l, float z)
  {
    vec3
    f = normalize(l - p),
    r = normalize(cross(vec3(0.0, 1.0, 0.0), f)),
    u = cross(f, r),
    c = f * z,
    i = c + uv.x * r + uv.y * u,
    d = normalize(i);
    return d;
  }
  vec2 repeat(vec2 uv)
  {
    return vec2(abs(mod(uv.x, 1.0)), abs(mod(uv.y, 1.0)));
  }
  void main() // this shader is pain
  {
    vec2
    center = vec2(0.5, 0.5);
    vec2
    uv = openfl_TextureCoordv.xy - center;
    uv.x = 0 - uv.x;
    vec3
    ro = vec3(0.0, 0.0, zoom);
    ro = ro * rotateX(rotation.x) * rotateY(rotation.y) * rotateZ(rotation.z);
    // ro.yz *= Rot(ShaderPointShit.y); //rotation shit
    // ro.xz *= Rot(ShaderPointShit.x);
    vec3
    rd = GetRayDir(uv, ro, vec3(0.0, 0., 0.0), 1.0);
    vec4
    col = vec4(0.0);
    float
    d = RayMarch(ro, rd);
    if (d < MAX_DIST + MAX_DIST_LIMIT)
    {
      vec3
      p = ro + rd * d;
      uv = vec2(p.x, p.y) * 0.5;
      uv += center; // move coords from top left to center
      col = flixel_texture2D(bitmap, repeat(uv)); // shadertoy to haxe bullshit i barely understand
    }
    gl_FragColor = col;
  }
  ')
  public function new()
  {
    super();
  }
}

class RedAberration extends ShaderBase
{
  public var shader:RedAberrationShader = new RedAberrationShader();

  public var time(default, set):Float = 0.0;
  public var intensity(default, set):Float = 0.0;
  public var initial(default, set):Float = 0.0;

  public function new()
  {
    shader.time.value = [time];
    shader.intensity.value = [intensity];
    shader.initial.value = [initial];
  }

  override public function update(elapsed:Float)
  {
    shader.time.value = [time];
    shader.intensity.value = [intensity];
    shader.initial.value = [initial];
  }

  function set_time(t:Float):Float
  {
    time = t;
    shader.time.value = [time];
    return t;
  }

  function set_intensity(i:Float):Float
  {
    intensity = i;
    shader.intensity.value = [intensity];
    return i;
  }

  function set_initial(i:Float):Float
  {
    initial = i;
    shader.initial.value = [initial];
    return i;
  }
}

class RedAberrationShader extends SLEFlxShaderUtil
{
  @:glFragmentSource('
    #pragma header

    const float PI = 3.14159265;
    uniform float time;
    uniform float intensity;
    uniform float initial;

    float sat( float t ) {
        return clamp( t, 0.0, 1.0 );
    }

    vec2 sat( vec2 t ) {
        return clamp( t, 0.0, 1.0 );
    }

    vec3 spectrum_offset( float t ) {
        float t0 = 3.0 * t - 1.5;
        return clamp( vec3( -t0, 1.0-abs(t0), t0), 0.0, 1.0);
    }

    void main() {
        vec2 uv = openfl_TextureCoordv;
        float ofs = (initial / 1000) + (intensity / 1000);

        vec4 sum = vec4(0.0);
        vec3 wsum = vec3(0.0);
        const int samples = 4;
        const float sampleinverse = 1.0 / float(samples);
        for( int i=0; i<samples; ++i )
        {
            float t = float(i) * sampleinverse;
            uv.x = sat( uv.x + ofs * t );
            vec4 samplecol = texture2D( bitmap, uv, -10.0 );
            vec3 s = spectrum_offset( t );
            samplecol.rgb = samplecol.rgb * s;
            sum += samplecol;
            wsum += s;
        }
        sum.rgb /= wsum;
        sum.a *= sampleinverse;

        gl_FragColor.a = sum.a;
        gl_FragColor.rgb = sum.rgb;
    }
    ')
  public function new()
  {
    super();
  }
}

class RGBPinEffect extends ShaderBase
{
  public var shader:RGBPinShader = new RGBPinShader();

  public var amount(default, set):Float = 0;
  public var distortionFactor(default, set):Float = 0;

  public function new():Void
  {
    shader.amount.value = [amount];
    shader.distortionFactor.value = [distortionFactor];
  }

  override public function update(elapsed:Float):Void
  {
    super.update(elapsed);

    shader.amount.value = [amount];
    shader.distortionFactor.value = [distortionFactor];
  }

  function set_amount(v:Float):Float
  {
    amount = v;
    shader.amount.value = [amount];
    return v;
  }

  function set_distortionFactor(v:Float):Float
  {
    distortionFactor = v;
    shader.distortionFactor.value = [distortionFactor];
    return v;
  }
}

class RGBPinShader extends SLEFlxShaderUtil
{
  @:glFragmentSource('
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
    }')
  public function new()
  {
    super();
  }
}

class RgbThreeEffect extends ShaderBase
{
  public var shader:RgbThreeEffectShader = new RgbThreeEffectShader();

  var iTime:Float = 0.0;

  public function new()
  {
    shader.iTime.value = [0];
  }

  override public function update(elapsed:Float)
  {
    iTime += elapsed;
    shader.iTime.value = [iTime];
  }
}

class RgbThreeEffectShader extends SLEFlxShaderUtil
{
  @:glFragmentSource('
    #pragma header
    vec2 uv = openfl_TextureCoordv.xy;
    vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
    vec2 iResolution = openfl_TextureSize;
    uniform float iTime;
    #define iChannel0 bitmap
    #define texture flixel_texture2D
    #define fragColor gl_FragColor
    #define mainImage main

    void mainImage()
    {
        vec2 uv = fragCoord.xy / iResolution.xy;

        float amount = 0.0;

        amount = (1.0 + sin(iTime*6.0)) * 0.5;
        amount *= 1.0 + sin(iTime*16.0) * 0.5;
        amount *= 1.0 + sin(iTime*19.0) * 0.5;
        amount *= 1.0 + sin(iTime*27.0) * 0.5;
        amount = pow(amount, 3.0);

        amount *= 0.05;

        vec3 col;
        col.r = texture( iChannel0, vec2(uv.x+amount,uv.y) ).r;
        col.g = texture( iChannel0, uv ).g;
        col.b = texture( iChannel0, vec2(uv.x-amount,uv.y) ).b;

        col *= (1.0 - amount * 0.5);

        fragColor = vec4(col,1.0);
    gl_FragColor.a = flixel_texture2D(bitmap, openfl_TextureCoordv).a;
    }
    //https://www.shadertoy.com/view/Mds3zn
    ')
  public function new()
  {
    super();
  }
}

class ScanlineEffectNew extends ShaderBase
{
  public var shader(default, null):ScanlineShaderNew = new ScanlineShaderNew();
  public var strength:Float = 0.0;
  public var pixelsBetweenEachLine:Float = 15.0;
  public var smooth:Bool = false;

  public function new():Void
  {
    shader.strength.value = [strength];
    shader.pixelsBetweenEachLine.value = [pixelsBetweenEachLine];
    shader.smoothVar.value = [smooth];
  }

  override public function update(elapsed:Float):Void
  {
    shader.strength.value = [strength];
    shader.pixelsBetweenEachLine.value = [pixelsBetweenEachLine];
    shader.smoothVar.value = [smooth];
  }
}

class ScanlineShaderNew extends FlxFixedShader
{
  @:glFragmentSource('#pragma header uniform float strength;
uniform float pixelsBetweenEachLine;
uniform bool smoothVar;
float m(float a, float b) // was having an issue with mod so i did this to try and fix it
{
  return a - (b * floor(a / b));
}
void main()
{
  vec2
  iResolution = vec2(1280.0, 720.0);
  vec2
  uv = openfl_TextureCoordv.xy;
  vec2
  fragCoordShit = iResolution * uv;
  vec4
  col = flixel_texture2D(bitmap, uv);
  if (smoothVar)
  {
    float
    apply = abs(sin(fragCoordShit.y) * 0.5 * pixelsBetweenEachLine);
    vec3
    finalCol = mix(col.rgb, vec3(0.0, 0.0, 0.0), apply);
    vec4
    scanline = vec4(finalCol.r, finalCol.g, finalCol.b, col.a);
    gl_FragColor = mix(col, scanline, strength);
    return;
  }
  vec4
  scanline = flixel_texture2D(bitmap, uv);
  if (m(floor(fragCoordShit.y), pixelsBetweenEachLine) == 0.0)
  {
    scanline = vec4(0.0, 0.0, 0.0, 1.0);
  }
  gl_FragColor = mix(col, scanline, strength);
}
')
  public function new()
  {
    super();
  }
}

class SobelEffect extends ShaderBase
{
  public var shader(default, null):SobelShader = new SobelShader();
  public var strength:Float = 1.0;
  public var intensity:Float = 1.0;

  public function new():Void
  {
    shader.strength.value = [0];
    shader.intensity.value = [0];
  }

  override public function update(elapsed:Float):Void
  {
    shader.strength.value[0] = strength;
    shader.intensity.value[0] = intensity;
  }
}

class SobelShader extends FlxFixedShader
{
  @:glFragmentSource('#pragma header uniform float strength;
uniform float intensity;
void main()
{
  vec2
  uv = openfl_TextureCoordv;
  vec4
  col = flixel_texture2D(bitmap, uv);
  vec2
  resFactor = (1 / openfl_TextureSize.xy) * intensity;
  if (strength <= 0)
  {
    gl_FragColor = col;
    return;
  }
  // https://en.wikipedia.org/wiki/Sobel_operator
  // adsjklalskdfjhaslkdfhaslkdfhj
  vec4
  topLeft = flixel_texture2D(bitmap, vec2(uv.x - resFactor.x, uv.y - resFactor.y));
  vec4
  topMiddle = flixel_texture2D(bitmap, vec2(uv.x, uv.y - resFactor.y));
  vec4
  topRight = flixel_texture2D(bitmap, vec2(uv.x + resFactor.x, uv.y - resFactor.y));
  vec4
  midLeft = flixel_texture2D(bitmap, vec2(uv.x - resFactor.x, uv.y));
  vec4
  midRight = flixel_texture2D(bitmap, vec2(uv.x + resFactor.x, uv.y));
  vec4
  bottomLeft = flixel_texture2D(bitmap, vec2(uv.x - resFactor.x, uv.y + resFactor.y));
  vec4
  bottomMiddle = flixel_texture2D(bitmap, vec2(uv.x, uv.y + resFactor.y));
  vec4
  bottomRight = flixel_texture2D(bitmap, vec2(uv.x + resFactor.x, uv.y + resFactor.y));
  vec4
  Gx = (topLeft) + (2 * midLeft) + (bottomLeft) - (topRight) - (2 * midRight) - (bottomRight);
  vec4
  Gy = (topLeft) + (2 * topMiddle) + (topRight) - (bottomLeft) - (2 * bottomMiddle) - (bottomRight);
  vec4
  G = sqrt((Gx * Gx) + (Gy * Gy));
  gl_FragColor = mix(col, G, strength);
}
')
  public function new()
  {
    super();
  }
}

class SquishyEffect extends ShaderBase
{
  public var shader:SquishyShader = new SquishyShader();

  var iTime:Float = 0.0;

  public function new()
  {
    shader.iTime.value = [0];
  }

  override public function update(elapsed:Float)
  {
    iTime += elapsed;
    shader.iTime.value = [iTime];
  }
}

class SquishyShader extends SLEFlxShaderUtil
{
  @:glFragmentSource('
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
    ')
  public function new()
  {
    super();
  }
}

class ThreeDEffect extends ShaderBase
{
  public var shader:ThreeDShader = new ThreeDShader();

  public var xrot(default, set):Float = 0;
  public var yrot(default, set):Float = 0;
  public var zrot(default, set):Float = 0;
  public var depth(default, set):Float = 0;

  public function new()
  {
    shader.xrot.value = [xrot];
    shader.yrot.value = [yrot];
    shader.zrot.value = [zrot];
    shader.depth.value = [depth];
  }

  override public function update(elapsed:Float)
  {
    shader.xrot.value = [xrot];
    shader.yrot.value = [yrot];
    shader.zrot.value = [zrot];
    shader.depth.value = [depth];
  }

  function set_xrot(x:Float):Float
  {
    xrot = x;
    shader.xrot.value = [xrot];
    return x;
  }

  function set_yrot(y:Float):Float
  {
    yrot = y;
    shader.yrot.value = [yrot];
    return y;
  }

  function set_zrot(z:Float):Float
  {
    zrot = z;
    shader.zrot.value = [zrot];
    return z;
  }

  function set_depth(d:Float):Float
  {
    depth = d;
    shader.depth.value = [depth];
    return d;
  }
}

// coding is like hitting on women, you never start with the number
//               -naether
// Edited by Geokureli
class ThreeDShader extends FlxFixedShader
{
  @:glFragmentSource('
  #pragma header // added space

  const float PI = 3.14159265; // was "#definePI 3.14159265"  which is nonsense
  uniform float xrot; // uniforms cant have default values, assign in the constructor
  uniform float yrot; // uniforms cant have default values, assign in the constructor
  uniform float zrot; // uniforms cant have default values, assign in the constructor
  uniform float depth; // uniforms cant have default values, assign in the constructor
  float plane( in vec3 norm, in vec3 po, in vec3 ro, in vec3 rd)
  {
    float
    de = dot(norm, rd);
    de = sign(de) * max(abs(de), 0.001);
    return dot(norm, po - ro) / de;
  }
  vec2 raytraceTexturedQuad( in vec3 rayOrigin, in vec3 rayDirection, in vec3 quadCenter, in vec3 quadRotation, in vec2 quadDimensions)
  {
    // Rotations ------------------
    float
    a = sin(quadRotation.x);
    float
    b = cos(quadRotation.x);
    float
    c = sin(quadRotation.y);
    float
    d = cos(quadRotation.y);
    float
    e = sin(quadRotation.z);
    float
    f = cos(quadRotation.z);
    float
    ac = a * c;
    float
    bc = b * c;
    mat3
    RotationMatrix = mat3(d * f, d * e, -c, ac * f - b * e, ac * e + b * f, a * d, bc * f + a * e, bc * e - a * f, b * d);
    //--------------------------------------
    vec3
    right = RotationMatrix * vec3(quadDimensions.x, 0.0, 0.0);
    vec3
    up = RotationMatrix * vec3(0.0, quadDimensions.y, 0.0); // prev version had 0, which is treated as an int
    vec3
    normal = cross(right, up);
    normal /= length(normal);
    // Find the plane hit point in space
    vec3
    pos = (rayDirection * plane(normal, quadCenter, rayOrigin, rayDirection)) - quadCenter;
    // Find the texture UV by projecting the hit point along the plane dirs
    return vec2(dot(pos, right) / dot(right, right), dot(pos, up) / dot(up, up)) + 0.5;
  }
  void main()
  {
    vec4
    texColor = texture2D(bitmap, openfl_TextureCoordv);
    // Screen UV goes from 0 - 1 along each axis
    vec2
    screenUV = openfl_TextureCoordv;
    vec2
    p = (2.0 * screenUV) - 1.0;
    float
    screenAspect = 1280.0 / 720.0; // added .0
    p.x *= screenAspect;
    // Normalized Ray Dir
    vec3
    dir = vec3(p.x, p.y, 1.0);
    dir /= length(dir);
    // Define the plane
    vec3
    planePosition = vec3(0.0, 0.0, depth + 0.5);
    vec3
    planeRotation = vec3(xrot, PI + yrot, zrot); // this the shit you needa change
    vec2
    planeDimension = vec2(-screenAspect, 1.0);
    vec2
    uv = raytraceTexturedQuad(vec3(0), dir, planePosition, planeRotation, planeDimension);
    // If we hit the rectangle, sample the texture
    if (abs(uv.x - 0.5) < 0.5 && abs(uv.y - 0.5) < 0.5)
    {
      gl_FragColor = vec4(flixel_texture2D(bitmap, uv));
    }
  }
')
  public function new()
  {
    super();
    // set drfault values of uniforms
    yrot.value = [0.0];
    zrot.value = [0.0];
    xrot.value = [0.0];
    depth.value = [0.0];
  }
}

class TypeVCREffect extends ShaderBase
{
  public var shader:TypeVCRShader = new TypeVCRShader();

  var iTime:Float = 0.0;

  public function new():Void
  {
    shader.iTime.value = [0.0];
  }

  override public function update(elapsed:Float):Void
  {
    iTime += elapsed;
    shader.iTime.value = [iTime];
  }
}

class TypeVCRShader extends SLEFlxShaderUtil
{
  @:glFragmentSource('
    #pragma header

    uniform float iTime;

    vec2 curve(vec2 uv)
    {
        uv = (uv - 0.5) * 2.0;
        uv *= 1.1;
        uv.x *= 1.0 + pow((abs(uv.y) / 5.0), 2.0);
        uv.y *= 1.0 + pow((abs(uv.x) / 4.0), 2.0);
        uv  = (uv / 2.0) + 0.5;
        uv =  uv *0.92 + 0.04;
        return uv;
    }

    void main()
    {
        vec2 q = openfl_TextureCoordv;
        vec2 uv = q;
        uv = curve( uv );
    float oga = flixel_texture2D( bitmap, uv).a;
        vec3 oricol = flixel_texture2D( bitmap, uv ).xyz; //q and uv is aready a vex2. no need for (q.x,q.y)
        vec3 col;
        float x =  sin(0.3*iTime+uv.y*21.0)*sin(0.7*iTime+uv.y*29.0)*sin(0.3+0.33*iTime+uv.y*31.0)*0.0017;

        col.r = flixel_texture2D(bitmap,vec2(x+uv.x+0.001,uv.y+0.001)).x+0.05;
        col.g = flixel_texture2D(bitmap,vec2(x+uv.x+0.000,uv.y-0.002)).y+0.05;
        col.b = flixel_texture2D(bitmap,vec2(x+uv.x-0.002,uv.y+0.000)).z+0.05;
        col.r += 0.08*flixel_texture2D(bitmap,0.75*vec2(x+0.025, -0.027)+vec2(uv.x+0.001,uv.y+0.001)).x;
        col.g += 0.05*flixel_texture2D(bitmap,0.75*vec2(x+-0.022, -0.02)+vec2(uv.x+0.000,uv.y-0.002)).y;
        col.b += 0.08*flixel_texture2D(bitmap,0.75*vec2(x+-0.02, -0.018)+vec2(uv.x-0.002,uv.y+0.000)).z;

        col = clamp(col*0.6+0.4*col*col*1.0,0.0,1.0);

        float vig = (0.0 + 1.0*16.0*uv.x*uv.y*(1.0-uv.x)*(1.0-uv.y));
        col *= vec3(pow(vig,0.3));

        col *= vec3(0.95,1.05,0.95);
        col *= 2.8;

        float scans = clamp( 0.35+0.35*sin(3.5*iTime+uv.y*openfl_TextureSize.y*1.5), 0.0, 1.0);

        float s = pow(scans,1.7);
        col = col*vec3( 0.4+0.7*s) ;

        col *= 1.0+0.01*sin(110.0*iTime);
        if (uv.x < 0.0 || uv.x > 1.0)
            col *= 0.0;
        if (uv.y < 0.0 || uv.y > 1.0)
            col *= 0.0;

        col*=1.0-0.65*vec3(clamp((mod(openfl_TextureCoordv.x, 2.0)-1.0)*2.0,0.0,1.0));

        float comp = smoothstep( 0.1, 0.9, sin(iTime) );

        // Remove the next line to stop cross-fade between original and postprocess
    //	col = mix( col, oricol, comp );

        gl_FragColor = vec4(col,oga);
    }
    ')
  public function new()
  {
    super();
  }
}

class VCRDistortionEffect extends ShaderBase
{
  public var shader:VCRDistortionShader = new VCRDistortionShader();

  public var glitchFactor(default, set):Float = 0;
  public var distortion(default, set):Bool = true;
  public var perspectiveOn(default, set):Bool = true;
  public var vignetteMoving(default, set):Bool = true;
  public var scanlinesOn(default, set):Bool = true;

  public function set_glitchFactor(glitch:Float):Float
  {
    glitchFactor = glitch;
    shader.glitchModifier.value = [glitchFactor];
    return glitch;
  }

  public function set_distortion(distort:Bool):Bool
  {
    distortion = distort;
    shader.distortionOn.value = [distortion];
    return distort;
  }

  public function set_perspectiveOn(persp:Bool):Bool
  {
    perspectiveOn = persp;
    shader.perspectiveOn.value = [perspectiveOn];
    return persp;
  }

  public function set_vignetteMoving(moving:Bool):Bool
  {
    vignetteMoving = moving;
    shader.vignetteOn.value = [vignetteMoving];
    return moving;
  }

  public function set_scanlinesOn(scan:Bool):Bool
  {
    scanlinesOn = scan;
    shader.vignetteOn.value = [scanlinesOn];
    return scan;
  }

  public function new()
  {
    shader.iTime.value = [0];
    shader.glitchModifier.value = [glitchFactor];
    shader.distortionOn.value = [distortion];
    shader.perspectiveOn.value = [perspectiveOn];
    shader.vignetteOn.value = [vignetteMoving];
    shader.scanlinesOn.value = [scanlinesOn];
    shader.iResolution.value = [Lib.current.stage.stageWidth, Lib.current.stage.stageHeight];
  }

  override public function update(elapsed:Float)
  {
    shader.iTime.value[0] += elapsed;
    shader.glitchModifier.value = [glitchFactor];
    shader.distortionOn.value = [distortion];
    shader.perspectiveOn.value = [perspectiveOn];
    shader.vignetteOn.value = [vignetteMoving];
    shader.scanlinesOn.value = [scanlinesOn];
    shader.iResolution.value = [Lib.current.stage.stageWidth, Lib.current.stage.stageHeight];
  }

  public function setVignette(state:Bool)
  {
    shader.vignetteOn.value[0] = state;
  }

  public function setPerspective(state:Bool)
  {
    shader.perspectiveOn.value[0] = state;
  }

  public function setGlitchModifier(modifier:Float)
  {
    shader.glitchModifier.value[0] = modifier;
  }

  public function setDistortion(state:Bool)
  {
    shader.distortionOn.value[0] = state;
  }

  public function setScanlines(state:Bool)
  {
    shader.scanlinesOn.value[0] = state;
  }

  public function setVignetteMoving(state:Bool)
  {
    shader.vignetteMoving.value[0] = state;
  }
}

class VCRDistortionShader extends FlxFixedShader // https://www.shadertoy.com/view/ldjGzV and https://www.shadertoy.com/view/Ms23DR and https://www.shadertoy.com/view/MsXGD4 and https://www.shadertoy.com/view/Xtccz4
{
  @:glFragmentSource('#pragma header uniform float iTime;
uniform bool vignetteOn;
uniform bool perspectiveOn;
uniform bool distortionOn;
uniform bool scanlinesOn;
uniform bool vignetteMoving;
// uniform sampler2D noiseTex;
uniform float glitchModifier;
uniform vec3 iResolution;
float onOff(float a, float b, float c)
{
  return step(c, sin(iTime + a * cos(iTime * b)));
}
float ramp(float y, float start, float end)
{
  float
  inside = step(start, y) - step(end, y);
  float
  fact = (y - start) / (end - start) * inside;
  return (1. - fact) * inside;
}
vec4 getVideo(vec2 uv)
{
  vec2
  look = uv;
  if (distortionOn)
  {
    float
    window = 1. / (1. + 20. * (look.y - mod(iTime / 4., 1.)) * (look.y - mod(iTime / 4., 1.)));
    look.x = look.x + (sin(look.y * 10. + iTime) / 50. * onOff(4., 4., .3) * (1. + cos(iTime * 80.)) * window) * (glitchModifier * 2);
    float
    vShift = 0.4 * onOff(2., 3., .9) * (sin(iTime) * sin(iTime * 20.) + (0.5 + 0.1 * sin(iTime * 200.) * cos(iTime)));
    look.y = mod(look.y + vShift * glitchModifier, 1.);
  }
  vec4
  video = flixel_texture2D(bitmap, look);
  return video;
}
vec2 screenDistort(vec2 uv)
{
  if (perspectiveOn)
  {
    uv = (uv - 0.5) * 2.0;
    uv *= 1.1;
    uv.x *= 1.0 + pow((abs(uv.y) / 5.0), 2.0);
    uv.y *= 1.0 + pow((abs(uv.x) / 4.0), 2.0);
    uv = (uv / 2.0) + 0.5;
    uv = uv * 0.92 + 0.04;
    return uv;
  }
  return uv;
}
float random(vec2 uv)
{
  return fract(sin(dot(uv, vec2(15.5151, 42.2561))) * 12341.14122 * sin(iTime * 0.03));
}
float noise(vec2 uv)
{
  vec2
  i = floor(uv);
  vec2
  f = fract(uv);
  float
  a = random(i);
  float
  b = random(i + vec2(1., 0.));
  float
  c = random(i + vec2(0., 1.));
  float
  d = random(i + vec2(1.));
  vec2
  u = smoothstep(0., 1., f);
  return mix(a, b, u.x) + (c - a) * u.y * (1. - u.x) + (d - b) * u.x * u.y;
}
vec2 scandistort(vec2 uv)
{
  float
  scan1 = clamp(cos(uv.y * 2.0 + iTime), 0.0, 1.0);
  float
  scan2 = clamp(cos(uv.y * 2.0 + iTime + 4.0) * 10.0, 0.0, 1.0);
  float
  amount = scan1 * scan2 * uv.x;
  // uv.x -= 0.05 * mix(flixel_texture2D(noiseTex, vec2(uv.x, amount)).r * amount, amount, 0.9);
  return uv;
}
void main()
{
  vec2
  uv = openfl_TextureCoordv;
  vec2
  curUV = screenDistort(uv);
  uv = scandistort(curUV);
  vec4
  video = getVideo(uv);
  float
  vigAmt = 1.0;
  float
  x = 0.;
  video.r = getVideo(vec2(x + uv.x + 0.001, uv.y + 0.001)).x + 0.05;
  video.g = getVideo(vec2(x + uv.x + 0.000, uv.y - 0.002)).y + 0.05;
  video.b = getVideo(vec2(x + uv.x - 0.002, uv.y + 0.000)).z + 0.05;
  video.r += 0.08 * getVideo(0.75 * vec2(x + 0.025, -0.027) + vec2(uv.x + 0.001, uv.y + 0.001)).x;
  video.g += 0.05 * getVideo(0.75 * vec2(x + -0.022, -0.02) + vec2(uv.x + 0.000, uv.y - 0.002)).y;
  video.b += 0.08 * getVideo(0.75 * vec2(x + -0.02, -0.018) + vec2(uv.x - 0.002, uv.y + 0.000)).z;
  video = clamp(video * 0.6 + 0.4 * video * video * 1.0, 0.0, 1.0);
  if (vignetteMoving) vigAmt = 3. + .3 * sin(iTime + 5. * cos(iTime * 5.));
  float
  vignette = (1. - vigAmt * (uv.y - .5) * (uv.y - .5)) * (1. - vigAmt * (uv.x - .5) * (uv.x - .5));
  if (vignetteOn) video *= vignette;
  gl_FragColor = mix(video, vec4(noise(uv * 75.)), .05);
  if (curUV.x < 0 || curUV.x > 1 || curUV.y < 0 || curUV.y > 1)
  {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
  }
}
')
  public function new()
  {
    super();
  }
}

class VCRDistortionEffect2 extends ShaderBase // the one used for tails doll /// No Things Used!
{
  public var shader:VCRDistortionShader2 = new VCRDistortionShader2();

  public function new()
  {
    shader.scanlinesOn.value = [true];
  }

  override public function update(elapsed:Float)
  {
    shader.scanlinesOn.value = [true];
  }
}

class VCRDistortionShader2 extends FlxFixedShader // https://www.shadertoy.com/view/ldjGzV and https://www.shadertoy.com/view/Ms23DR and https://www.shadertoy.com/view/MsXGD4 and https://www.shadertoy.com/view/Xtccz4
{
  @:glFragmentSource('#pragma header uniform float iTime;
uniform bool vignetteOn;
uniform bool perspectiveOn;
uniform bool distortionOn;
uniform bool scanlinesOn;
uniform bool vignetteMoving;
uniform sampler2D noiseTex;
uniform float glitchModifier;
uniform vec3 iResolution;
float onOff(float a, float b, float c)
{
  return step(c, sin(iTime + a * cos(iTime * b)));
}
float ramp(float y, float start, float end)
{
  float
  inside = step(start, y) - step(end, y);
  float
  fact = (y - start) / (end - start) * inside;
  return (1. - fact) * inside;
}
vec4 getVideo(vec2 uv)
{
  vec2
  look = uv;
  if (distortionOn)
  {
    float
    window = 1. / (1. + 20. * (look.y - mod(iTime / 4., 1.)) * (look.y - mod(iTime / 4., 1.)));
    look.x = look.x + (sin(look.y * 10. + iTime) / 50. * onOff(4., 4., .3) * (1. + cos(iTime * 80.)) * window) * (glitchModifier * 2.);
    float
    vShift = 0.4 * onOff(2., 3., .9) * (sin(iTime) * sin(iTime * 20.) + (0.5 + 0.1 * sin(iTime * 200.) * cos(iTime)));
    look.y = mod(look.y + vShift * glitchModifier, 1.);
  }
  vec4
  video = flixel_texture2D(bitmap, look);
  return video;
}
vec2 screenDistort(vec2 uv)
{
  if (perspectiveOn)
  {
    uv = (uv - 0.5) * 2.0;
    uv *= 1.1;
    uv.x *= 1.0 + pow((abs(uv.y) / 5.0), 2.0);
    uv.y *= 1.0 + pow((abs(uv.x) / 4.0), 2.0);
    uv = (uv / 2.0) + 0.5;
    uv = uv * 0.92 + 0.04;
    return uv;
  }
  return uv;
}
float random(vec2 uv)
{
  return fract(sin(dot(uv, vec2(15.5151, 42.2561))) * 12341.14122 * sin(iTime * 0.03));
}
float noise(vec2 uv)
{
  vec2
  i = floor(uv);
  vec2
  f = fract(uv);
  float
  a = random(i);
  float
  b = random(i + vec2(1., 0.));
  float
  c = random(i + vec2(0., 1.));
  float
  d = random(i + vec2(1.));
  vec2
  u = smoothstep(0., 1., f);
  return mix(a, b, u.x) + (c - a) * u.y * (1. - u.x) + (d - b) * u.x * u.y;
}
vec2 scandistort(vec2 uv)
{
  float
  scan1 = clamp(cos(uv.y * 2.0 + iTime), 0.0, 1.0);
  float
  scan2 = clamp(cos(uv.y * 2.0 + iTime + 4.0) * 10.0, 0.0, 1.0);
  float
  amount = scan1 * scan2 * uv.x;
  uv.x -= 0.05 * mix(flixel_texture2D(noiseTex, vec2(uv.x, amount)).r * amount, amount, 0.9);
  return uv;
}
void main()
{
  vec2
  uv = openfl_TextureCoordv;
  vec2
  curUV = screenDistort(uv);
  uv = scandistort(curUV);
  vec4
  video = getVideo(uv);
  float
  vigAmt = 1.0;
  float
  x = 0.;
  video.r = getVideo(vec2(x + uv.x + 0.001, uv.y + 0.001)).x + 0.05;
  video.g = getVideo(vec2(x + uv.x + 0.000, uv.y - 0.002)).y + 0.05;
  video.b = getVideo(vec2(x + uv.x - 0.002, uv.y + 0.000)).z + 0.05;
  video.r += 0.08 * getVideo(0.75 * vec2(x + 0.025, -0.027) + vec2(uv.x + 0.001, uv.y + 0.001)).x;
  video.g += 0.05 * getVideo(0.75 * vec2(x + -0.022, -0.02) + vec2(uv.x + 0.000, uv.y - 0.002)).y;
  video.b += 0.08 * getVideo(0.75 * vec2(x + -0.02, -0.018) + vec2(uv.x - 0.002, uv.y + 0.000)).z;
  video = clamp(video * 0.6 + 0.4 * video * video * 1.0, 0.0, 1.0);
  if (vignetteMoving) vigAmt = 3. + .3 * sin(iTime + 5. * cos(iTime * 5.));
  float
  vignette = (1. - vigAmt * (uv.y - .5) * (uv.y - .5)) * (1. - vigAmt * (uv.x - .5) * (uv.x - .5));
  if (vignetteOn) video *= vignette;
  gl_FragColor = mix(video, vec4(noise(uv * 75.)), .05);
  if (curUV.x < 0. || curUV.x > 1. || curUV.y < 0. || curUV.y > 1.)
  {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
  }
}
')
  public function new()
  {
    super();
  }
}

class VcrEffect extends ShaderBase
{
  public var shader:VcrShader = new VcrShader();

  var iTime:Float = 0.0;

  public function new()
  {
    shader.iTime.value = [0];
  }

  override public function update(elapsed:Float)
  {
    iTime += elapsed;
    shader.iTime.value = [iTime];
  }
}

class VcrShader extends SLEFlxShaderUtil
{
  @:glFragmentSource('
    #pragma header

    uniform float iTime;
   // uniform sampler2D noiseTex;
    uniform vec3 iResolution;

    float onOff(float a, float b, float c)
    {
        return step(c, sin(iTime + a*cos(iTime*b)));
    }

    float ramp(float y, float start, float end)
    {
        float inside = step(start,y) - step(end,y);
        float fact = (y-start)/(end-start)*inside;
        return (1.-fact) * inside;

    }

    vec4 getVideo(vec2 uv)
      {
        vec2 look = uv;
            float window = 1./(1.+20.*(look.y-mod(iTime/4.,1.))*(look.y-mod(iTime/4.,1.)));
            look.x = look.x + (sin(look.y*10. + iTime)/50.*onOff(4.,4.,.3)*(1.+cos(iTime*80.))*window)*(0.2*2);
            float vShift = 0.4*onOff(2.,3.,.9)*(sin(iTime)*sin(iTime*20.) +
                                                 (0.5 + 0.1*sin(iTime*200.)*cos(iTime)));
            look.y = mod(look.y + vShift*0.2, 1.);

        vec4 video = flixel_texture2D(bitmap,look);

        return video;
      }

    vec2 screenDistort(vec2 uv)
    {
        uv = (uv - 0.5) * 2.0;
        uv *= 1.1;
        uv.x *= 1.0 + pow((abs(uv.y) / 5.0), 2.0);
        uv.y *= 1.0 + pow((abs(uv.x) / 4.0), 2.0);
        uv  = (uv / 2.0) + 0.5;
        uv =  uv *0.92 + 0.04;
        return uv;

        return uv;
    }
    float random(vec2 uv)
    {
        return fract(sin(dot(uv, vec2(15.5151, 42.2561))) * 12341.14122 * sin(iTime * 0.03));
    }
    float noise(vec2 uv)
    {
        vec2 i = floor(uv);
        vec2 f = fract(uv);

        float a = random(i);
        float b = random(i + vec2(1.,0.));
        float c = random(i + vec2(0., 1.));
        float d = random(i + vec2(1.));

        vec2 u = smoothstep(0., 1., f);

        return mix(a,b, u.x) + (c - a) * u.y * (1. - u.x) + (d - b) * u.x * u.y;

    }


    vec2 scandistort(vec2 uv) {
        float scan1 = clamp(cos(uv.y * 2.0 + iTime), 0.0, 1.0);
        float scan2 = clamp(cos(uv.y * 2.0 + iTime + 4.0) * 10.0, 0.0, 1.0) ;
        float amount = scan1 * scan2 * uv.x;

        //uv.x -= 0.05 * mix(flixel_texture2D(noiseTex, vec2(uv.x, amount)).r * amount, amount, 0.9);

        return uv;

    }
    void main()
    {
        vec2 uv = openfl_TextureCoordv;
      vec2 curUV = screenDistort(uv);
        uv = scandistort(curUV);
        vec4 video = getVideo(uv);
      float vigAmt = 1.0;
      float x =  0.;


      video.r = getVideo(vec2(x+uv.x+0.001,uv.y+0.001)).x+0.05;
      video.g = getVideo(vec2(x+uv.x+0.000,uv.y-0.002)).y+0.05;
      video.b = getVideo(vec2(x+uv.x-0.002,uv.y+0.000)).z+0.05;
      video.r += 0.08*getVideo(0.75*vec2(x+0.025, -0.027)+vec2(uv.x+0.001,uv.y+0.001)).x;
      video.g += 0.05*getVideo(0.75*vec2(x+-0.022, -0.02)+vec2(uv.x+0.000,uv.y-0.002)).y;
      video.b += 0.08*getVideo(0.75*vec2(x+-0.02, -0.018)+vec2(uv.x-0.002,uv.y+0.000)).z;

      video = clamp(video*0.6+0.4*video*video*1.0,0.0,1.0);
          vigAmt = 3.+.3*sin(iTime + 5.*cos(iTime*5.));

        float vignette = (1.-vigAmt*(uv.y-.5)*(uv.y-.5))*(1.-vigAmt*(uv.x-.5)*(uv.x-.5));

         video *= vignette;


      gl_FragColor = mix(video,vec4(noise(uv * 300.)),.05);

      if(curUV.x<0 || curUV.x>1 || curUV.y<0 || curUV.y>1){
        gl_FragColor = vec4(0.0,0.0,0.0,0.0);
      }

    }
    ')
  public function new()
  {
    super();
  }
}

class VcrNoGlitchEffect extends ShaderBase
{
  public var shader:VcrNoGlitchShader = new VcrNoGlitchShader();

  var iTime:Float = 0.0;

  public function new()
  {
    shader.iTime.value = [0];
  }

  override public function update(elapsed:Float)
  {
    iTime += elapsed;
    shader.iTime.value = [iTime];
  }
}

class VcrNoGlitchShader extends SLEFlxShaderUtil
{
  @:glFragmentSource('
    #pragma header

    uniform float iTime;
   // uniform sampler2D noiseTex;
    uniform vec3 iResolution;

    float onOff(float a, float b, float c)
    {
        return step(c, sin(iTime + a*cos(iTime*b)));
    }

    float ramp(float y, float start, float end)
    {
        float inside = step(start,y) - step(end,y);
        float fact = (y-start)/(end-start)*inside;
        return (1.-fact) * inside;

    }

    vec4 getVideo(vec2 uv)
      {
        vec2 look = uv;
            float window = 1./(1.+20.*(look.y-mod(iTime/4.,1.))*(look.y-mod(iTime/4.,1.)));
            look.x = look.x + (sin(look.y*10. + iTime)/50.*onOff(4.,4.,.3)*(1.+cos(iTime*80.))*window)*(0*2);
            float vShift = 1*onOff(2.,3.,.9)*(sin(iTime)*sin(iTime*20.) +
                                                 (1 + 0.1*sin(iTime*200.)*cos(iTime)));
            look.y = mod(look.y + vShift*0, 0.);

        vec4 video = flixel_texture2D(bitmap,look);

        return video;
      }

    vec2 screenDistort(vec2 uv)
    {
        uv = (uv - 0.5) * 2.0;
        uv *= 1.1;
        uv.x *= 1.0 + pow((abs(uv.y) / 2.0), 3.0);
        uv.y *= 1.0 + pow((abs(uv.x) / 2.0), 3.0);
        uv  = (uv / 2.0) + 0.5;
        uv =  uv *0.92 + 0.04;
        return uv;

        return uv;
    }
    float random(vec2 uv)
    {
        return fract(sin(dot(uv, vec2(15.5151, 42.2561))) * 12341.14122 * sin(iTime * 0.3));
    }
    float noise(vec2 uv)
    {
        vec2 i = floor(uv);
        vec2 f = fract(uv);

        float a = random(i);
        float b = random(i + vec2(1.,0.));
        float c = random(i + vec2(0., 1.));
        float d = random(i + vec2(1.));

        vec2 u = smoothstep(0., 1., f);

        return mix(a,b, u.x) + (c - a) * u.y * (1. - u.x) + (d - b) * u.x * u.y;

    }


    vec2 scandistort(vec2 uv) {
        float scan1 = clamp(cos(uv.y * 1 + iTime), 1.0, 1.0);
        float scan2 = clamp(cos(uv.y * 1 + iTime + 1.0) * 10.0, 1.0, 1.0) ;
        float amount = scan1 * scan2 * uv.x;

        //uv.x -= 0.05 * mix(flixel_texture2D(noiseTex, vec2(uv.x, amount)).r * amount, amount, 2);

        return uv;

    }
    void main()
    {
        vec2 uv = openfl_TextureCoordv;
      vec2 curUV = screenDistort(uv);
        uv = scandistort(curUV);
        vec4 video = getVideo(uv);
      float vigAmt = 1;
      float x =  0.;


      video.r = getVideo(vec2(x+uv.x+0.001,uv.y+0.001)).x+0.05;
      video.b = getVideo(vec2(x+uv.x+0.000,uv.y-0.002)).y+0.05;
      video.b = getVideo(vec2(x+uv.x-0.002,uv.y+0.000)).z+0.05;
      video.r += 0.08*getVideo(0.75*vec2(x+0.025, -0.027)+vec2(uv.x+0.001,uv.y+0.001)).x;
      video.g += 0.05*getVideo(0.75*vec2(x+-0.022, -0.02)+vec2(uv.x+0.000,uv.y-0.002)).y;
      video.b += 0.08*getVideo(0.75*vec2(x+-0.02, -0.018)+vec2(uv.x-0.002,uv.y+0.000)).z;

      video = clamp(video*0.6+0.4*video*video*1.0,0.0,1.0);
          vigAmt = 3.+.3*sin(iTime + 5.*cos(iTime*5.));

        float vignette = (1.-vigAmt*(uv.y-.5)*(uv.y-.5))*(1.-vigAmt*(uv.x-.5)*(uv.x-.5));

         video *= vignette;


      gl_FragColor = mix(video,vec4(noise(uv * 75.)),.05);

      if(curUV.x<0 || curUV.x>1 || curUV.y<0 || curUV.y>1){
        gl_FragColor = vec4(1.0,0.0,1.0,0.0);
      }

    }
    ')
  public function new()
  {
    super();
  }
}

class VcrWithGlitch extends ShaderBase
{
  public var shader:VcrWithGlitchShader = new VcrWithGlitchShader();

  var iTime:Float = 0.0;

  public function new()
  {
    shader.iTime.value = [0];
  }

  override public function update(elapsed:Float)
  {
    iTime += elapsed;
    shader.iTime.value = [iTime];
  }
}

class VcrWithGlitchShader extends SLEFlxShaderUtil
{
  @:glFragmentSource('
    #pragma header

    uniform float iTime;
   // uniform sampler2D noiseTex;
    uniform vec3 iResolution;

    float onOff(float a, float b, float c)
    {
        return step(c, sin(iTime + a*cos(iTime*b)));
    }

    float ramp(float y, float start, float end)
    {
        float inside = step(start,y) - step(end,y);
        float fact = (y-start)/(end-start)*inside;
        return (1.-fact) * inside;

    }

    vec4 getVideo(vec2 uv)
      {
        vec2 look = uv;
            float window = 1./(1.+20.*(look.y-mod(iTime/4.,1.))*(look.y-mod(iTime/4.,1.)));
            look.x = look.x + (sin(look.y*10. + iTime)/50.*onOff(4.,4.,.3)*(1.+cos(iTime*80.))*window)*(0.1*2);
            float vShift = 0.4*onOff(2.,3.,.9)*(sin(iTime)*sin(iTime*20.) +
                                                 (0.5 + 0.1*sin(iTime*200.)*cos(iTime)));
            look.y = mod(look.y + vShift*0.1, 1.);

        vec4 video = flixel_texture2D(bitmap,look);

        return video;
      }

    vec2 screenDistort(vec2 uv)
    {
        uv = (uv - 0.5) * 2.0;
        uv *= 1.1;
        uv.x *= 1.0 + pow((abs(uv.y) / 5.0), 2.0);
        uv.y *= 1.0 + pow((abs(uv.x) / 4.0), 2.0);
        uv  = (uv / 2.0) + 0.5;
        uv =  uv *0.92 + 0.04;
        return uv;

        return uv;
    }
    float random(vec2 uv)
    {
        return fract(sin(dot(uv, vec2(15.5151, 42.2561))) * 12341.14122 * sin(iTime * 0.03));
    }
    float noise(vec2 uv)
    {
        vec2 i = floor(uv);
        vec2 f = fract(uv);

        float a = random(i);
        float b = random(i + vec2(1.,0.));
        float c = random(i + vec2(0., 1.));
        float d = random(i + vec2(1.));

        vec2 u = smoothstep(0., 1., f);

        return mix(a,b, u.x) + (c - a) * u.y * (1. - u.x) + (d - b) * u.x * u.y;

    }


    vec2 scandistort(vec2 uv) {
        float scan1 = clamp(cos(uv.y * 2.0 + iTime), 0.0, 1.0);
        float scan2 = clamp(cos(uv.y * 2.0 + iTime + 4.0) * 10.0, 0.0, 1.0) ;
        float amount = scan1 * scan2 * uv.x;

        //uv.x -= 0.05 * mix(flixel_texture2D(noiseTex, vec2(uv.x, amount)).r * amount, amount, 0.9);

        return uv;

    }
    void main()
    {
        vec2 uv = openfl_TextureCoordv;
      vec2 curUV = screenDistort(uv);
        uv = scandistort(curUV);
        vec4 video = getVideo(uv);
      float vigAmt = 1.0;
      float x =  0.;


      video.r = getVideo(vec2(x+uv.x+0.001,uv.y+0.001)).x+0.05;
      video.g = getVideo(vec2(x+uv.x+0.000,uv.y-0.002)).y+0.05;
      video.b = getVideo(vec2(x+uv.x-0.002,uv.y+0.000)).z+0.05;
      video.r += 0.08*getVideo(0.75*vec2(x+0.025, -0.027)+vec2(uv.x+0.001,uv.y+0.001)).x;
      video.g += 0.05*getVideo(0.75*vec2(x+-0.022, -0.02)+vec2(uv.x+0.000,uv.y-0.002)).y;
      video.b += 0.08*getVideo(0.75*vec2(x+-0.02, -0.018)+vec2(uv.x-0.002,uv.y+0.000)).z;

      video = clamp(video*0.6+0.4*video*video*1.0,0.0,1.0);
          vigAmt = 3.+.3*sin(iTime + 5.*cos(iTime*5.));

        float vignette = (1.-vigAmt*(uv.y-.5)*(uv.y-.5))*(1.-vigAmt*(uv.x-.5)*(uv.x-.5));

         video *= vignette;


      gl_FragColor = mix(video,vec4(noise(uv * 75.)),.05);

      if(curUV.x<0 || curUV.x>1 || curUV.y<0 || curUV.y>1){
        gl_FragColor = vec4(0.0,0.0,0.0,0.0);
      }
    }
    ')
  public function new()
  {
    super();
  }
}

class VHSEffect extends ShaderBase
{
  public var shader:VHSShader = new VHSShader();

  var iTime:Float = 0;

  public function new()
  {
    iTime = 0;
    shader.iTime.value = [iTime];
  }

  override public function update(elapsed:Float)
  {
    iTime += elapsed;
    shader.iTime.value = [iTime];
  }
}

class VHSShader extends SLEFlxShaderUtil
{
  @:glFragmentSource('
    //SHADERTOY PORT FIX (thx bb)
    #pragma header
    vec2 uv = openfl_TextureCoordv.xy;
    vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
    vec2 iResolution = openfl_TextureSize;
    uniform float iTime;
    #define iChannel0 bitmap
    #define texture flixel_texture2D
    #define fragColor gl_FragColor
    #define mainImage main
    //SHADERTOY PORT FIX
    // Fork of "20151110_VHS" by FMS_Cat. https://shadertoy.com/view/XtBXDt
    // 2020-03-25 02:11:48

    #define time iTime
    #define resolution ( iResolution.xy )
    const float PI = 3.14159265;

    vec3 tex2D( sampler2D _tex, vec2 _p ){
      vec3 col = texture2D( _tex, _p ).xyz;
      if ( 0.5 < abs( _p.x - 0.5 ) ) {
        col = vec3( 0.1 );
      }
      return col;
    }

    float hash( vec2 _v ){
      return fract( sin( dot( _v, vec2( 89.44, 19.36 ) ) ) * 22189.22 );
    }

    float iHash( vec2 _v, vec2 _r ){
      float h00 = hash( vec2( floor( _v * _r + vec2( 0.0, 0.0 ) ) / _r ) );
      float h10 = hash( vec2( floor( _v * _r + vec2( 1.0, 0.0 ) ) / _r ) );
      float h01 = hash( vec2( floor( _v * _r + vec2( 0.0, 1.0 ) ) / _r ) );
      float h11 = hash( vec2( floor( _v * _r + vec2( 1.0, 1.0 ) ) / _r ) );
      vec2 ip = vec2( smoothstep( vec2( 0.0, 0.0 ), vec2( 1.0, 1.0 ), mod( _v*_r, 1. ) ) );
      return ( h00 * ( 1. - ip.x ) + h10 * ip.x ) * ( 1. - ip.y ) + ( h01 * ( 1. - ip.x ) + h11 * ip.x ) * ip.y;
    }

    float noise( vec2 _v ){
      float sum = 0.;
      for( int i=1; i<9; i++ )
      {
        sum += iHash( _v + vec2( i ), vec2( 2. * pow( 2., float( i ) ) ) ) / pow( 2., float( i ) );
      }
      return sum;
    }

    void main(){
      vec2 fragCoord = openfl_TextureCoordv * iResolution;
      vec2 uv = gl_FragCoord.xy / resolution;
      vec2 uvn = uv;
      vec3 col = vec3( 0.0 );
      vec4 color = texture2D(bitmap, uv);

      // tape wave
      uvn.x += ( noise( vec2( uvn.y, time ) ) - 0.5 )* 0.005;
      uvn.x += ( noise( vec2( uvn.y * 100.0, time * 10.0 ) ) - 0.5 ) * 0.01;

      // tape crease
      float tcPhase = clamp( ( sin( uvn.y * 8.0 - time * PI * 1.2 ) - 0.92 ) * noise( vec2( time ) ), 0.0, 0.01 ) * 10.0;
      float tcNoise = max( noise( vec2( uvn.y * 100.0, time * 10.0 ) ) - 0.5, 0.0 );
      uvn.x = uvn.x - tcNoise * tcPhase;

      // switching noise
      float snPhase = smoothstep( 0.03, 0.0, uvn.y );
      uvn.y += snPhase * 0.3;
      uvn.x += snPhase * ( ( noise( vec2( uv.y * 100.0, time * 10.0 ) ) - 0.5 ) * 0.2 );

      col = tex2D( bitmap, uvn );
      col *= 1.0 - tcPhase;
      col = mix(
        col,
        col.yzx,
        snPhase
      );

      // bloom
      for( float x = -4.0; x < 2.5; x += 1.0 ){
        col.xyz += vec3(
          tex2D( bitmap, uvn + vec2( x - 0.0, 0.0 ) * 7E-3 ).x,
          tex2D( bitmap, uvn + vec2( x - 2.0, 0.0 ) * 7E-3 ).y,
          tex2D( bitmap, uvn + vec2( x - 4.0, 0.0 ) * 7E-3 ).z
        ) * 0.1;
      }
      col *= 0.6;

      // ac beat
      col *= 1.0 + clamp( noise( vec2( 0.0, uv.y + time * 0.2 ) ) * 0.6 - 0.25, 0.0, 0.1 );

      if (color.a < 0.1)
            discard;

      gl_FragColor = vec4( col, 1.0 );
    }
    ')
  public function new()
  {
    super();
  }
}

class VignetteEffect extends ShaderBase
{
  public var shader(default, null):VignetteShader = new VignetteShader();
  public var strength:Float = 1.0;
  public var size:Float = 0.0;
  public var red:Float = 0.0;
  public var green:Float = 0.0;
  public var blue:Float = 0.0;

  public function new():Void
  {
    shader.strength.value = [0];
    shader.size.value = [0];
    shader.red.value = [red];
    shader.green.value = [green];
    shader.blue.value = [blue];
  }

  override public function update(elapsed:Float):Void
  {
    shader.strength.value[0] = strength;
    shader.size.value[0] = size;
    shader.red.value = [red];
    shader.green.value = [green];
    shader.blue.value = [blue];
  }
}

class VignetteShader extends FlxFixedShader
{
  @:glFragmentSource('#pragma header uniform float strength;
uniform float size;
uniform float red;
uniform float green;
uniform float blue;
void main()
{
  vec2
  uv = openfl_TextureCoordv;
  vec4
  col = flixel_texture2D(bitmap, uv);
  // modified from this
  // https://www.shadertoy.com/view/lsKSWR
  uv = uv * (1.0 - uv.yx);
  float
  vig = uv.x * uv.y * strength;
  vig = pow(vig, size);
  vig = 0.0 - vig + 1.0;
  vec3
  vigCol = vec3(vig, vig, vig);
  vigCol.r = vigCol.r * (red / 255);
  vigCol.g = vigCol.g * (green / 255);
  vigCol.b = vigCol.b * (blue / 255);
  col.rgb += vigCol;
  col.a += vig;
  gl_FragColor = col;
}
')
  public function new()
  {
    super();
  }
}

class VignetteGlitchEffect extends ShaderBase
{
  public var shader:VignetteGlitchShader = new VignetteGlitchShader();

  public var time(default, set):Float = 0.0;
  public var prob(default, set):Float = 0.0;
  public var vignetteIntensity(default, set):Float = 0.0;

  public function new()
  {
    shader.time.value = [time];
    shader.prob.value = [prob];
    shader.vignetteIntensity.value = [vignetteIntensity];
  }

  override public function update(elapsed:Float)
  {
    shader.time.value = [time];
    shader.prob.value = [prob];
    shader.vignetteIntensity.value = [vignetteIntensity];
  }

  function set_time(t:Float):Float
  {
    time = t;
    shader.time.value = [time];
    return t;
  }

  function set_prob(p:Float):Float
  {
    prob = p;
    shader.prob.value = [prob];
    return p;
  }

  function set_vignetteIntensity(vi:Float):Float
  {
    vignetteIntensity = vi;
    shader.vignetteIntensity.value = [vignetteIntensity];
    return vi;
  }
}

class VignetteGlitchShader extends GraphicsShader
{
  @:glFragmentSource('
  // https://www.shadertoy.com/view/XtyXzW

  #pragma header
  #extension GL_EXT_gpu_shader4 : enable

  uniform float time;
  uniform float prob;
  uniform float vignetteIntensity;

  float _round(float n) {
      return floor(n + .5);
  }

  vec2 _round(vec2 n) {
      return floor(n + .5);
  }

  vec3 tex2D(sampler2D _tex,vec2 _p)
  {
      vec3 col=texture(_tex,_p).xyz;
      if(.5<abs(_p.x-.5)){
          col=vec3(.1);
      }
      return col;
  }

  const float PI = 3.14159265359;
  const float PHI = (1.618033988749895);

  // --------------------------------------------------------
  // Glitch core
  // --------------------------------------------------------

  float rand(vec2 co){
      return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
  }

  const float glitchScale = 0.5;

  vec2 glitchCoord(vec2 p, vec2 gridSize) {
      vec2 coord = floor(p / gridSize) * gridSize;;
      coord += (gridSize / 2.);
      return coord;
  }

  struct GlitchSeed {
      vec2 seed;
      float prob;
  };

  float fBox2d(vec2 p, vec2 b) {
    vec2 d = abs(p) - b;
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
  }

  GlitchSeed glitchSeed(vec2 p, float speed) {
      float seedTime = floor(time * speed);
      vec2 seed = vec2(
          1. + mod(seedTime / 100., 100.),
          1. + mod(seedTime, 100.)
      ) / 100.;
      seed += p;
      return GlitchSeed(seed, prob);
  }

  float shouldApply(GlitchSeed seed) {
      return round(
          mix(
              mix(rand(seed.seed), 1., seed.prob - .5),
              0.,
              (1. - seed.prob) * .5
          )
      );
  }

  // gamma again
  const float GAMMA = 1;

  vec3 gamma(vec3 color, float g) {
      return pow(color, vec3(g));
  }

  vec3 linearToScreen(vec3 linearRGB) {
      return gamma(linearRGB, 1.0 / GAMMA);
  }

  // --------------------------------------------------------
  // Glitch effects
  // --------------------------------------------------------

  // Swap

  vec4 swapCoords(vec2 seed, vec2 groupSize, vec2 subGrid, vec2 blockSize) {
      vec2 rand2 = vec2(rand(seed), rand(seed+.1));
      vec2 range = subGrid - (blockSize - 1.);
      vec2 coord = floor(rand2 * range) / subGrid;
      vec2 bottomLeft = coord * groupSize;
      vec2 realBlockSize = (groupSize / subGrid) * blockSize;
      vec2 topRight = bottomLeft + realBlockSize;
      topRight -= groupSize / 2.;
      bottomLeft -= groupSize / 2.;
      return vec4(bottomLeft, topRight);
  }

  float isInBlock(vec2 pos, vec4 block) {
      vec2 a = sign(pos - block.xy);
      vec2 b = sign(block.zw - pos);
      return min(sign(a.x + a.y + b.x + b.y - 3.), 0.);
  }

  vec2 moveDiff(vec2 pos, vec4 swapA, vec4 swapB) {
      vec2 diff = swapB.xy - swapA.xy;
      return diff * isInBlock(pos, swapA);
  }

  void swapBlocks(inout vec2 xy, vec2 groupSize, vec2 subGrid, vec2 blockSize, vec2 seed, float apply) {

      vec2 groupOffset = glitchCoord(xy, groupSize);
      vec2 pos = xy - groupOffset;

      vec2 seedA = seed * groupOffset;
      vec2 seedB = seed * (groupOffset + .1);

      vec4 swapA = swapCoords(seedA, groupSize, subGrid, blockSize);
      vec4 swapB = swapCoords(seedB, groupSize, subGrid, blockSize);

      vec2 newPos = pos;
      newPos += moveDiff(pos, swapA, swapB) * apply;
      newPos += moveDiff(pos, swapB, swapA) * apply;
      pos = newPos;

      xy = pos + groupOffset;
  }


  // Static

  void staticNoise(inout vec2 p, vec2 groupSize, float grainSize, float contrast) {
      GlitchSeed seedA = glitchSeed(glitchCoord(p, groupSize), 5.);
      seedA.prob *= .5;
      if (shouldApply(seedA) == 1.) {
          GlitchSeed seedB = glitchSeed(glitchCoord(p, vec2(grainSize)), 5.);
          vec2 offset = vec2(rand(seedB.seed), rand(seedB.seed + .1));
          offset = round(offset * 2. - 1.);
          offset *= contrast;
          p += offset;
      }
  }

  // --------------------------------------------------------
  // Glitch compositions
  // --------------------------------------------------------

  void glitchSwap(inout vec2 p) {
      vec2 pp = p;

      float scale = glitchScale;
      float speed = 5.;

      vec2 groupSize;
      vec2 subGrid;
      vec2 blockSize;
      GlitchSeed seed;
      float apply;

      groupSize = vec2(.6) * scale;
      subGrid = vec2(2.0);
      blockSize = vec2(1.0);

      seed = glitchSeed(glitchCoord(p, groupSize), speed);
      apply = shouldApply(seed);
      swapBlocks(p, groupSize, subGrid, blockSize, seed.seed, apply);

      groupSize = vec2(.8) * scale;
      subGrid = vec2(3.0);
      blockSize = vec2(1.0);

      seed = glitchSeed(glitchCoord(p, groupSize), speed);
      apply = shouldApply(seed);
      swapBlocks(p, groupSize, subGrid, blockSize, seed.seed, apply);

      groupSize = vec2(.2) * scale;
      subGrid = vec2(6.0);
      blockSize = vec2(1.0);

      seed = glitchSeed(glitchCoord(p, groupSize), speed);
      float apply2 = shouldApply(seed);
      swapBlocks(p, groupSize, subGrid, blockSize, (seed.seed + 1.), apply * apply2);
      swapBlocks(p, groupSize, subGrid, blockSize, (seed.seed + 2.), apply * apply2);
      swapBlocks(p, groupSize, subGrid, blockSize, (seed.seed + 3.), apply * apply2);
      swapBlocks(p, groupSize, subGrid, blockSize, (seed.seed + 4.), apply * apply2);
      swapBlocks(p, groupSize, subGrid, blockSize, (seed.seed + 5.), apply * apply2);

      groupSize = vec2(1.2, .2) * scale;
      subGrid = vec2(9.0,2.0);
      blockSize = vec2(3.0,1.0);

      seed = glitchSeed(glitchCoord(p, groupSize), speed);
      apply = shouldApply(seed);
      swapBlocks(p, groupSize, subGrid, blockSize, seed.seed, apply);
  }

  void glitchStatic(inout vec2 p) {
      staticNoise(p, vec2(.5, .25/2.) * glitchScale, .2 * glitchScale, 2.);
  }


  void main() {
      // time = mod(time, 1.);
      float alpha = openfl_Alphav;
      vec2 p = openfl_TextureCoordv.xy;
      vec3 basecolor = texture2D(bitmap, openfl_TextureCoordv).rgb;

      glitchSwap(p);
      glitchStatic(p);

      vec3 color = texture2D(bitmap, p).rgb;

      float amount = (0.5 * sin(time * PI) + vignetteIntensity);
      float vignette = distance(openfl_TextureCoordv, vec2(0.5));
      //
      vignette = mix(1.0, 1.0 - amount, vignette);
      //
      gl_FragColor = vec4(mix(color.rgb, basecolor.rgb, vignette), 1.0);
  }
  ')
  public function new()
  {
    super();
  }
}

class WaveBurstEffect extends ShaderBase
{
  public var shader(default, null):WaveBurstShader = new WaveBurstShader();
  public var strength:Float = 0.0;

  public function new():Void
  {
    shader.strength.value = [strength];
  }

  override public function update(elapsed:Float):Void
  {
    shader.strength.value = [strength];
  }
}

class WaveBurstShader extends FlxFixedShader
{
  @:glFragmentSource('#pragma header uniform float strength;
float nrand(vec2 n)
{
  return fract(sin(dot(n.xy, vec2(12.9898, 78.233))) * 43758.5453);
}
void main()
{
  vec2
  uv = openfl_TextureCoordv.xy;
  vec4
  col = flixel_texture2D(bitmap, uv);
  float
  rnd = sin(uv.y * 1000.0) * strength;
  rnd += nrand(uv) * strength;
  col = flixel_texture2D(bitmap, vec2(uv.x - rnd, uv.y));
  gl_FragColor = col;
}
')
  public function new()
  {
    super();
  }
}

class WaterEffect extends ShaderBase
{
  public var shader(default, null):WaterShader = new WaterShader();
  public var strength:Float = 10.0;
  public var iTime:Float = 0.0;
  public var speed:Float = 1.0;

  public function new():Void
  {
    shader.strength.value = [strength];
    shader.iTime.value = [iTime];
  }

  override public function update(elapsed:Float):Void
  {
    shader.strength.value = [strength];
    iTime += elapsed * speed;
    shader.iTime.value = [iTime];
  }
}

class WaterShader extends FlxFixedShader
{
  @:glFragmentSource('#pragma header uniform float iTime;
uniform float strength;
vec2 mirror(vec2 uv)
{
  if ((uv.x > 1.0 || uv.x < 0.0) && abs(mod(uv.x, 2.0)) > 1.0) uv.x = (0.0 - uv.x) + 1.0;
  if ((uv.y > 1.0 || uv.y < 0.0) && abs(mod(uv.y, 2.0)) > 1.0) uv.y = (0.0 - uv.y) + 1.0;
  return vec2(abs(mod(uv.x, 1.0)), abs(mod(uv.y, 1.0)));
}
vec2 warp(vec2 uv)
{
  vec2
  warp = strength * (uv + iTime);
  uv = vec2(cos(warp.x - warp.y) * cos(warp.y), sin(warp.x - warp.y) * sin(warp.y));
  return uv;
}
void main()
{
  vec2
  uv = openfl_TextureCoordv.xy;
  vec4
  col = flixel_texture2D(bitmap, mirror(uv + (warp(uv) - warp(uv + 1.0)) * (0.0035)));
  gl_FragColor = col;
}
')
  public function new()
  {
    super();
  }
}

class WaveCircleEffect extends ShaderBase
{
  public var shader(default, null):WaveCircleShader = new WaveCircleShader();

  public var waveSpeed(default, set):Float = 0;
  public var waveFrequency(default, set):Float = 0;
  public var waveAmplitude(default, set):Float = 0;

  public function new():Void
  {
    shader.uTime.value = [0];
  }

  override public function update(elapsed:Float):Void
  {
    super.update(elapsed);

    shader.uTime.value[0] += elapsed;
  }

  function set_waveSpeed(v:Float):Float
  {
    waveSpeed = v;
    shader.uSpeed.value = [waveSpeed];
    return v;
  }

  function set_waveFrequency(v:Float):Float
  {
    waveFrequency = v;
    shader.uFrequency.value = [waveFrequency];
    return v;
  }

  function set_waveAmplitude(v:Float):Float
  {
    waveAmplitude = v;
    shader.uWaveAmplitude.value = [waveAmplitude];
    return v;
  }
}

class WaveCircleShader extends FlxFixedShader
{
  @:glFragmentSource('
    #pragma header
    //uniform float tx, ty; // x,y waves phase

    //modified version of the wave shader to create weird garbled corruption like messes
    uniform float uTime;

    /**
     * How fast the waves move over time
    */
    uniform float uSpeed;

    /**
     * Number of waves over time
     */
    uniform float uFrequency;

    /**
     * How much the pixels are going to stretch over the waves
     */
    uniform float uWaveAmplitude;

    vec2 sineWave(vec2 pt)
    {
    float
    x = 0.0;
    float
    y = 0.0;
    float
    offsetX = sin(pt.y * uFrequency + uTime * uSpeed) * (uWaveAmplitude / pt.x * pt.y);
    float
    offsetY = sin(pt.x * uFrequency - uTime * uSpeed) * (uWaveAmplitude / pt.y * pt.x);
    pt.x += offsetX; // * (pt.y - 1.0); // <- Uncomment to stop bottom part of the screen from moving
    pt.y += offsetY;
    return vec2(pt.x + x, pt.y + y);
    }
    void main()
    {
    vec2
    uv = sineWave(openfl_TextureCoordv);
    gl_FragColor = texture2D(bitmap, uv);
    }
  ')
  public function new()
  {
    super();
  }
}
