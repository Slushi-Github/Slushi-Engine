package slushi.slushiUtils.shaders;

import openfl.display3D._internal.GLShader;
import openfl.display3D._internal.GLProgram;

import flixel.system.FlxAssets.FlxShader;

/**
 *  This code helps the program itself to both alert the user that a 
 *  shader did not compile correctly (due to its GPU/GPU driver) and to 
 *  prevent the program from crashing.
 *  The object or camera where it was applied could be have unexpected results 
 *  that would have been expected if the shader compiled correctly. 
 *  
 *  @:author Slushi
 */

class SLEFlxShaderUtil extends FlxShader
{
    public var shaderName:String = "UNKNOWN";

    @:noCompletion override private function __createGLShader(source:String, type:Int):GLShader
        {
            #if (openfl >= "9.2.2")
            @:privateAccess
            var gl = __context.gl;

            var shader = gl.createShader(type);
            gl.shaderSource(shader, source);
            gl.compileShader(shader);
            var shaderInfoLog = gl.getShaderInfoLog(shader);
            var hasInfoLog = shaderInfoLog != null && StringTools.trim(shaderInfoLog) != "";
            var compileStatus = gl.getShaderParameter(shader, gl.COMPILE_STATUS);

            if (hasInfoLog || compileStatus == 0)
            {
                var message = (type == gl.VERTEX_SHADER) ? "Can\'t compile [VERTEX] shader:\n" : "Can\'t compile [FRAGMENT] shader:\n";
                    message += shaderInfoLog;
                if (compileStatus == 0) {
                    #if windows
                    CppAPI.showMessageBox(message, "Slushi Engine: Error compiling shader!", MSG_ERROR);
                    #else
                    WindowFuncs.windowAlert(message, "Slushi Engine: Error compiling shader!");
                    #end
                    Debug.logError("Error compiling shader: \n" + message + "\n");
                }
                else if (hasInfoLog){
                    Debug.logInfo(message);
                } 
            }
            return shader;
            #end
        }

    override private function __createGLProgram(vertexSource:String, fragmentSource:String):GLProgram
        {
            @:privateAccess
            var gl = __context.gl;

            var vertexShader = __createGLShader(vertexSource, gl.VERTEX_SHADER);
            var fragmentShader = __createGLShader(fragmentSource, gl.FRAGMENT_SHADER);

            var program = gl.createProgram();

            // Fix support for drivers that don't draw if attribute 0 is disabled
            for (param in __paramFloat)
            {
                if (param.name.indexOf("Position") > -1 && StringTools.startsWith(param.name, "openfl_"))
                {
                    gl.bindAttribLocation(program, 0, param.name);
                    break;
                }
            }

            gl.attachShader(program, vertexShader);
            gl.attachShader(program, fragmentShader);
            gl.linkProgram(program);

            if (gl.getProgramParameter(program, gl.LINK_STATUS) == 0)
            {
                var message = "Unable to initialize the shader program";
                message += "\n" + gl.getProgramInfoLog(program);
                Debug.logError("\nError initializing shader program:\n" + message + "\n");
            }

            return program;
        }
}