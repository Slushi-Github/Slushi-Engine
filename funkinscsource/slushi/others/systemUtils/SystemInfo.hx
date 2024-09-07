package slushi.others.systemUtils;

import slushi.others.systemUtils.HiddenProcess;
import slushi.others.systemUtils.MemoryUtil;
import lime.system.System;

using StringTools;

class SystemInfo
{
	public static var osInfo:String = "Unknown";
	public static var gpuName:String = "Unknown";
	public static var vRAM:String = "Unknown";
	public static var cpuName:String = "Unknown";
	public static var totalMem:String = "Unknown";
	public static var memType:String = "Unknown";
	public static var gpuMaxSize:String = "Unknown";

	static var __formattedSysText:String = "";

	public static inline function init()
	{
		#if linux
		var process = new HiddenProcess("cat", ["/etc/os-release"]);
		if (process.exitCode() != 0)
			Debug.logTrace('Unable to grab OS Label');
		else
		{
			var osName = "";
			var osVersion = "";
			for (line in process.stdout.readAll().toString().split("\n"))
			{
				if (line.startsWith("PRETTY_NAME="))
				{
					var index = line.indexOf('"');
					if (index != -1)
						osName = line.substring(index + 1, line.lastIndexOf('"'));
					else
					{
						var arr = line.split("=");
						arr.shift();
						osName = arr.join("=");
					}
				}
				if (line.startsWith("VERSION="))
				{
					var index = line.indexOf('"');
					if (index != -1)
						osVersion = line.substring(index + 1, line.lastIndexOf('"'));
					else
					{
						var arr = line.split("=");
						arr.shift();
						osVersion = arr.join("=");
					}
				}
			}
			if (osName != "")
				osInfo = '${osName} ${osVersion}'.trim();
		}
		#else
		if (System.platformLabel != null
			&& System.platformLabel != ""
			&& System.platformVersion != null
			&& System.platformVersion != "")
			osInfo = '${System.platformLabel.replace(System.platformVersion, "").trim()} ${System.platformVersion}';
		else
			Debug.logWarn('Unable to grab OS Label');
		#end

		try
		{
			#if windows
			var process = new HiddenProcess("wmic", ["cpu", "get", "name"]);
			if (process.exitCode() != 0)
				throw 'Could not fetch CPU information';

			cpuName = process.stdout.readAll().toString().trim().split("\n")[1].trim();
			#elseif mac
			var process = new HiddenProcess("sysctl -a | grep brand_string"); // Somehow this isnt able to use the args but it still works
			if (process.exitCode() != 0)
				throw 'Could not fetch CPU information';

			cpuName = process.stdout.readAll().toString().trim().split(":")[1].trim();
			#elseif linux
			var process = new HiddenProcess("cat", ["/proc/cpuinfo"]);
			if (process.exitCode() != 0)
				throw 'Could not fetch CPU information';

			for (line in process.stdout.readAll().toString().split("\n"))
			{
				if (line.indexOf("model name") == 0)
				{
					cpuName = line.substring(line.indexOf(":") + 2);
					break;
				}
			}
			#end
		}
		catch (e)
		{
			Debug.logWarn('Unable to grab CPU Name: $e');
		}

		@:privateAccess {
			if (flixel.FlxG.stage.context3D != null && flixel.FlxG.stage.context3D.gl != null)
			{
				gpuName = Std.string(flixel.FlxG.stage.context3D.gl.getParameter(flixel.FlxG.stage.context3D.gl.RENDERER)).split("/")[0].trim();
				#if !flash
				var size = FlxG.bitmap.maxTextureSize;
				gpuMaxSize = size + "x" + size;
				#end
			}
			else
				Debug.logWarn('Unable to grab GPU Info');
		}

		#if cpp
		totalMem = Std.string(MemoryUtil.getTotalMem() / 1024) + " GB";
		#else
		Debug.logWarn('Unable to grab RAM Amount');
		#end

		try
		{
			memType = MemoryUtil.getMemType();
		}
		catch (e)
		{
			Debug.logWarn('Unable to grab RAM Type: $e');
		}
		formatSysInfo();
	}

	static function formatSysInfo()
	{
		if (osInfo != "Unknown")
			__formattedSysText = 'System: $osInfo';
		if (cpuName != "Unknown")
			__formattedSysText += '\nCPU: $cpuName ${openfl.system.Capabilities.cpuArchitecture} ${(openfl.system.Capabilities.supports64BitProcesses ? '64-Bit' : '32-Bit')}';
		if (gpuName != cpuName || vRAM != "Unknown")
		{
			var gpuNameKnown = gpuName != "Unknown" && gpuName != cpuName;
			var vramKnown = vRAM != "Unknown";

			if (gpuNameKnown || vramKnown)
				__formattedSysText += "\n";

			if (gpuNameKnown)
				__formattedSysText += 'GPU: $gpuName';
			if (gpuNameKnown && vramKnown)
				__formattedSysText += " | ";
			if (vramKnown)
				__formattedSysText += 'VRAM: $vRAM';
		}
		if (totalMem != "Unknown" && memType != "Unknown")
			__formattedSysText += '\nTotal RAM: $totalMem $memType';

		Debug.logSLEInfo("\n\n" + __formattedSysText + "\n");
	}
}
