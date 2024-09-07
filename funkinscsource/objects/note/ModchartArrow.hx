package objects.note;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.graphics.tile.FlxDrawTrianglesItem;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDirectionFlags;
import lime.math.Vector2;
import openfl.geom.Matrix;
import openfl.geom.Vector3D;
import openfl.display.TriangleCulling;

class ModchartArrow extends FunkinSCSprite
{
  // If set, will reference this sprites graphic! Very useful for animations!
  public var initialized:Bool = false; // if this is false it won't use most of functions
  public var projectionEnabled:Bool = true;

  public var angleX:Float = 0;
  public var angleY:Float = 0;
  public var angleZ:Float = 0;

  public var scaleX:Float = 1;
  public var scaleY:Float = 1;
  public var scaleZ:Float = 1;

  public var skewX:Float = 0;
  public var skewY:Float = 0;
  public var skewZ:Float = 0;

  // in %
  public var skewX_offset:Float = 0.5;
  public var skewY_offset:Float = 0.5;
  public var skewZ_offset:Float = 0.5;

  public var moveX:Float = 0;
  public var moveY:Float = 0;
  public var moveZ:Float = 0;

  public var fovOffsetX:Float = 0;
  public var fovOffsetY:Float = 0;
  // public var fovOffsetZ:Float = 0;
  public var pivotOffsetX:Float = 0;
  public var pivotOffsetY:Float = 0;
  public var pivotOffsetZ:Float = 0;

  public var fov:Float = 90;

  /**
   * A `Vector` of floats where each pair of numbers is treated as a coordinate location (an x, y pair).
   */
  public var vertices:DrawData<Float> = new DrawData<Float>();

  /**
   * A `Vector` of integers or indexes, where every three indexes define a triangle.
   */
  public var indices:DrawData<Int> = new DrawData<Int>();

  /**
   * A `Vector` of normalized coordinates used to apply texture mapping.
   */
  public var uvtData:DrawData<Float> = new DrawData<Float>();

  // custom setter to prevent values below 0, cuz otherwise we'll devide by 0!
  public var subdivisions(default, set):Int = 2;

  function set_subdivisions(value:Int):Int
  {
    if (value < 0) value = 0;
    subdivisions = value;
    return subdivisions;
  }

  public var daOffsetX:Float = 0;
  public var typeOffsetX:Float = 0;
  public var typeOffsetY:Float = 0;

  // <----
  public var drawManual:Bool = false;
  public var hasSetupRender:Bool = false;

  public function setUpThreeDRender():Void
  {
    if (!hasSetupRender)
    {
      drawManual = true;
      setUp();
      hasSetupRender = true;
    }
  }

  public function setUp():Void
  {
    this.x = 0;
    this.y = 0;
    this.z = 0;

    this.active = true; // This NEEDS to be true for the note to be drawn!
    updateColorTransform();
    var nextRow:Int = (subdivisions + 1 + 1);
    var noteIndices:Array<Int> = [];
    for (x in 0...subdivisions + 1)
    {
      for (y in 0...subdivisions + 1)
      {
        // indices are created from top to bottom, going along the x axis each cycle.
        var funny:Int = y + (x * nextRow);
        noteIndices.push(0 + funny);
        noteIndices.push(nextRow + funny);
        noteIndices.push(1 + funny);

        noteIndices.push(nextRow + funny);
        noteIndices.push(1 + funny);
        noteIndices.push(nextRow + 1 + funny);
      }
    }
    indices = new DrawData<Int>(noteIndices.length, true, noteIndices);

    // UV coordinates are normalized, so they range from 0 to 1.
    var i:Int = 0;
    for (x in 0...subdivisions + 2) // x
    {
      for (y in 0...subdivisions + 2) // y
      {
        var xPercent:Float = x / (subdivisions + 1);
        var yPercent:Float = y / (subdivisions + 1);
        uvtData[i * 2] = xPercent;
        uvtData[i * 2 + 1] = yPercent;
        i++;
      }
    }
    updateTris();
  }

  public function updateTris(debugTrace:Bool = false):Void
  {
    var w:Float = frameWidth;
    var h:Float = frameHeight;

    var i:Int = 0;
    for (x in 0...subdivisions + 2) // x
    {
      for (y in 0...subdivisions + 2) // y
      {
        var point2D:Vector2;
        var point3D:Vector3D = new Vector3D(0, 0, 0);
        point3D.x = (w / (subdivisions + 1)) * x;
        point3D.y = (h / (subdivisions + 1)) * y;

        // skew funny
        var xPercent:Float = x / (subdivisions + 1);
        var yPercent:Float = y / (subdivisions + 1);
        var xPercent_SkewOffset:Float = xPercent - skewY_offset;
        var yPercent_SkewOffset:Float = yPercent - skewX_offset;
        // Keep math the same as skewedsprite for parity reasons.
        point3D.x += yPercent_SkewOffset * Math.tan(skewX * FlxAngle.TO_RAD) * h;
        point3D.y += xPercent_SkewOffset * Math.tan(skewY * FlxAngle.TO_RAD) * w;
        point3D.z += yPercent_SkewOffset * Math.tan(skewZ * FlxAngle.TO_RAD) * h;

        // scale
        var newWidth:Float = (scaleX - 1) * (xPercent - 0.5);
        point3D.x += (newWidth) * w;
        newWidth = (scaleY - 1) * (yPercent - 0.5);
        point3D.y += (newWidth) * h;

        // _skewMatrix.b = Math.tan(skew.y * FlxAngle.TO_RAD);
        // _skewMatrix.c = Math.tan(skew.x * FlxAngle.TO_RAD);

        point2D = applyPerspective(point3D, xPercent, yPercent);

        point2D.x += (frameWidth - frameWidth) / 2;
        point2D.y += (frameHeight - frameHeight) / 2;

        vertices[i * 2] = point2D.x;
        vertices[i * 2 + 1] = point2D.y;
        i++;
      }
    }

    if (debugTrace) trace("\nverts: \n" + vertices + "\n");

    // temp fix for now I guess lol?
    flipX = false;
    flipY = false;
  }

  @:access(flixel.FlxCamera)
  public function applyPerspective(pos:Vector3D, xPercent:Float = 0, yPercent:Float = 0):Vector2
  {
    var w:Float = frameWidth;
    var h:Float = frameHeight;

    var pos_modified:Vector3D = new Vector3D(pos.x, pos.y, pos.z);

    var whatWasTheZBefore:Float = pos_modified.z;

    var rotateModPivotPoint:Vector2 = new Vector2(w / 2, h / 2);
    rotateModPivotPoint.x += pivotOffsetX;
    rotateModPivotPoint.y += pivotOffsetY;
    var thing:Vector2 = ModchartUtil.rotateAround(rotateModPivotPoint, new Vector2(pos_modified.x, pos_modified.y), angleZ);
    pos_modified.x = thing.x;
    pos_modified.y = thing.y;

    var rotateModPivotPoint:Vector2 = new Vector2(w / 2, 0);
    rotateModPivotPoint.x += pivotOffsetX;
    rotateModPivotPoint.y += pivotOffsetZ;
    var thing:Vector2 = ModchartUtil.rotateAround(rotateModPivotPoint, new Vector2(pos_modified.x, pos_modified.z), -angleY);
    pos_modified.x = thing.x;
    pos_modified.z = thing.y;

    var rotateModPivotPoint:Vector2 = new Vector2(0, h / 2);
    rotateModPivotPoint.x += pivotOffsetZ;
    rotateModPivotPoint.y += pivotOffsetY;
    var thing:Vector2 = ModchartUtil.rotateAround(rotateModPivotPoint, new Vector2(pos_modified.z, pos_modified.y), -angleX);
    pos_modified.z = thing.x;
    pos_modified.y = thing.y;

    // Calculate the difference of the rotation and use this as input for the applyPerspective function (idk it just works)
    // Feel free to move this calculation around if you wanna account for other facts like offsetZ (if added) or moveZ, idk what you're doing exactly with this code lol
    // -Hazard24
    var zDifference:Float = pos_modified.z - whatWasTheZBefore;

    // Apply offset here before it gets affected by z projection!
    pos_modified.x -= offset.x;
    pos_modified.y -= offset.y;
    pos_modified.x += daOffsetX; // Moved offsetX here so it's with the other Offsets -Hazard24

    pos_modified.x += moveX;
    pos_modified.y += moveY;
    pos_modified.z += moveZ;

    if (projectionEnabled)
    {
      pos_modified.x += this.x;
      pos_modified.y += this.y;
      // pos_modified.x += (width/2);
      // pos_modified.y += (height/2);
      pos_modified.z += this.z; // ?????

      pos_modified.x += fovOffsetX;
      pos_modified.y += fovOffsetY;
      pos_modified.z *= 0.001;

      // var thisNotePos = perspectiveMath(new Vector3D(pos_modified.x+(width/2), pos_modified.y+(height/2), zDifference * 0.001), -(width/2), -(height/2));
      pos_modified.z = zDifference * 0.001;
      var thisNotePos:Vector3D = perspectiveMath(pos_modified, 0, 0);
      // No need for any offsets since the offsets are already a part of pos_modified for each Vert. Plus if you look at the +height/2 part, you'll realise it's just cancelling each other out lmfao
      // -Hazard24

      thisNotePos.x -= this.x;
      thisNotePos.y -= this.y;
      thisNotePos.z -= this.z; // ?????

      thisNotePos.x -= fovOffsetX;
      thisNotePos.y -= fovOffsetY;
      return new Vector2(thisNotePos.x, thisNotePos.y);
    }
    else
    {
      return new Vector2(pos_modified.x, pos_modified.y);
    }
  }

  public var zNear:Float = 0.0;
  public var zFar:Float = 100.0;

  // https://github.com/TheZoroForce240/FNF-Modcharting-Tools/blob/main/source/modcharting/ModchartUtil.hx
  public function perspectiveMath(pos:Vector3D, offsetX:Float = 0, offsetY:Float = 0):Vector3D
  {
    try
    {
      var _FOV:Float = this.fov;

      _FOV *= (Math.PI / 180.0);

      var newz:Float = pos.z - 1;
      var zRange:Float = zNear - zFar;
      var tanHalfFOV:Float = 1;
      var dividebyzerofix:Float = FlxMath.fastCos(_FOV * 0.5);
      if (dividebyzerofix != 0)
      {
        tanHalfFOV = FlxMath.fastSin(_FOV * 0.5) / dividebyzerofix;
      }

      if (pos.z > 1) newz = 0;

      var xOffsetToCenter:Float = pos.x - (FlxG.width * 0.5);
      var yOffsetToCenter:Float = pos.y - (FlxG.height * 0.5);

      var zPerspectiveOffset:Float = (newz + (2 * zFar * zNear / zRange));

      // divide by zero check
      if (zPerspectiveOffset == 0) zPerspectiveOffset = 0.001;

      xOffsetToCenter += (offsetX * -zPerspectiveOffset);
      yOffsetToCenter += (offsetY * -zPerspectiveOffset);

      xOffsetToCenter += (0 * -zPerspectiveOffset);
      yOffsetToCenter += (0 * -zPerspectiveOffset);

      var xPerspective:Float = xOffsetToCenter * (1 / tanHalfFOV);
      var yPerspective:Float = yOffsetToCenter * tanHalfFOV;
      xPerspective /= -zPerspectiveOffset;
      yPerspective /= -zPerspectiveOffset;

      pos.x = xPerspective + (FlxG.width * 0.5);
      pos.y = yPerspective + (FlxG.height * 0.5);
      pos.z = zPerspectiveOffset;
      return pos;
    }
    catch (e)
    {
      trace("OH GOD OH FUCK IT NEARLY DIED CUZ OF: \n" + e.toString());
      return pos;
    }
  }
}
