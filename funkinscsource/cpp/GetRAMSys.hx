package cpp;

import cpp.ConstCharStar;
import cpp.Native;
import cpp.UInt64;

#if cpp
#if linux
@:headerCode('
#include <stdio.h>
')
#elseif windows
@:headerCode('
#include <Windows.h>
#include <cstdio>
#include <iostream>
#include <tchar.h>
#include <dwmapi.h>
#include <winuser.h>
')
#elseif macos
@:cppFileCode('
#include <sys/sysctl.h>
')
#end
#end
class GetRAMSys
{
  #if cpp
  #if linux
  @:functionCode('
		FILE *meminfo = fopen("/proc/meminfo", "r");

    	if(meminfo == NULL)
			return -1;

    	char line[256];
    	while(fgets(line, sizeof(line), meminfo))
    	{
        	int ram;
        	if(sscanf(line, "MemTotal: %d kB", &ram) == 1)
        	{
            	fclose(meminfo);
            	return (ram / 1024);
        	}
    	}

    	fclose(meminfo);
    	return -1;
	')
  #elseif windows
  @:functionCode('
		unsigned long long allocatedRAM = 0;
		GetPhysicallyInstalledSystemMemory(&allocatedRAM);
		return (allocatedRAM / 1024);
	')
  #elseif macos
  @:functionCode('
	int mib [] = { CTL_HW, HW_MEMSIZE };
	int64_t value = 0;
	size_t length = sizeof(value);

	if(-1 == sysctl(mib, 2, &value, &length, NULL, 0))
		return -1; // An error occurred

	return value / 1024 / 1024;
	')
  #end
  public static function obtainRAM():UInt64
  {
    return 0;
  }
  #end
}
