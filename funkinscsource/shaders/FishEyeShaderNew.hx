package shaders;

import haxe.Json;
import openfl.utils.Assets;

typedef FishEyeNewJSON =
{
  var presets:Array<Array<Float>>;
}

class FishEyeShaderNew extends FlxFixedShader // https://www.shadertoy.com/view/WsVSzV
{
  @:glFragmentSource('#pragma header vec2 uv = openfl_TextureCoordv.xy;
vec2 fragCoord = openfl_TextureCoordv * openfl_TextureSize;
vec2 iResolution = openfl_TextureSize;
uniform float iTime;
#defineiChannel0 bitmap#definetexture flixel_texture2D#definefragColor gl_FragColor#definemainImage main // For AMD, uniform cannot have anything after its been assigned.
uniform float warp; // simulate curvature of CRT monitor
uniform float scan; // simulate darkness between scanlines
void mainImage()
{
  // squared distance from center
  vec2
  uv = fragCoord / iResolution.xy;
  vec2
  dc = abs(0.5 - uv);
  dc *= dc;
  // warp the fragment coordinates
  uv.x -= 0.5;
  uv.x *= 1.0 + (dc.y * (0.7 * warp));
  uv.x += 0.5;
  uv.y -= 0.5;
  uv.y *= 1.0 + (dc.x * (0.9 * warp));
  uv.y += 0.5;
  // sample inside boundaries, otherwise set to black
  if (uv.y > 1.0 || uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0) fragColor = vec4(0.0, 0.0, 0.0, 1.0);
  else
  {
    // determine if we are drawing in a scanline
    float
    apply = abs(sin(fragCoord.y) * 0.5 * scan);
    // sample the texture
    fragColor = vec4(mix(flixel_texture2D(bitmap, uv).rgb, vec3(0.0), apply), 1.0);
  }
}
')
  var json:FishEyeNewJSON = null;

  public var preset(default, set):Int = 0;

  function set_preset(value:Int):Int
  {
    var presetData:Array<Float> = json.presets[value];
    data.warp.value = [presetData[0]];
    data.scan.value = [presetData[1]];
    return value;
  }

  public function new()
  {
    super();

    var jsonTxt:String = Assets.getText(Paths.json(' shader / fisheyenew '));
    json = cast Json.parse(jsonTxt);

    iTime.value = [0];
    this.preset = preset;
  }
}
