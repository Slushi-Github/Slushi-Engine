package slushi.windows;

/**
 * This file has the functions related to the Windows GDI, there are MENZ virus GDI effects.
 * 
 * Author: Slushi
 */

#if windows
@:cppFileCode('
#include <Windows.h>
#include <windowsx.h>
#include <cstdio>
#include <iostream>
#include <tchar.h>
#include <dwmapi.h>
#include <winuser.h>
#include <winternl.h>
#include <Shlobj.h>
#include <commctrl.h>
#include <string>

#include <locale>
#include <codecvt>

#include <math.h>
#include <cmath>

#define UNICODE

#pragma comment(lib, "Dwmapi")
#pragma comment(lib, "ntdll.lib")
#pragma comment(lib, "User32.lib")
#pragma comment(lib, "Shell32.lib")
#pragma comment(lib, "gdi32.lib")

/////////////////////////////////////////////////////////////////////////////

#define elapsedTime 0

int payloadDrawErrors(BOOLEAN mode) {
    if (mode) {
        int ix = GetSystemMetrics(SM_CXICON) / 2;
        int iy = GetSystemMetrics(SM_CYICON) / 2;
        
        HWND hwnd = GetDesktopWindow();
        HDC hdc = GetWindowDC(hwnd);

        POINT cursor;
        GetCursorPos(&cursor);

        DrawIcon(hdc, cursor.x - ix, cursor.y - iy, LoadIcon(NULL, IDI_ERROR));

        if (rand() % (int)(10/(elapsedTime/500.0+1)+1) == 0) {
            DrawIcon(hdc, rand()%GetSystemMetrics(SM_CXSCREEN), rand()%GetSystemMetrics(SM_CYSCREEN), LoadIcon(NULL, IDI_WARNING));
        }
        
        ReleaseDC(hwnd, hdc);

        out: return 2;
    }
}

int payloadBlink(BOOLEAN mode) {
    if (mode) {
        HWND hwnd = GetDesktopWindow();
        HDC hdc = GetWindowDC(hwnd);
        RECT rekt;
        GetWindowRect(hwnd, &rekt);
        BitBlt(hdc, 0, 0, rekt.right - rekt.left, rekt.bottom - rekt.top, hdc, 0, 0, NOTSRCCOPY);
        ReleaseDC(hwnd, hdc);

        out: return 100;
    }
}

int payloadGlitchs(BOOLEAN mode) {
    if (mode) {
        HWND hwnd = GetDesktopWindow();
        HDC hdc = GetWindowDC(hwnd);
        RECT rekt;
        GetWindowRect(hwnd, &rekt);

        int x1 = rand() % (rekt.right - 100);
        int y1 = rand() % (rekt.bottom - 100);
        int x2 = rand() % (rekt.right - 100);
        int y2 = rand() % (rekt.bottom - 100);
        int width = rand() % 600;
        int height = rand() % 600;

        BitBlt(hdc, x1, y1, width, height, hdc, x2, y2, SRCCOPY);
        ReleaseDC(hwnd, hdc);

        out: return 200.0 / (elapsedTime / 5.0 + 1) + 3;
    }
}

int payloadTunnel(BOOLEAN mode) {
    if (mode) {
        HWND hwnd = GetDesktopWindow();
        HDC hdc = GetWindowDC(hwnd);
        RECT rekt;
        GetWindowRect(hwnd, &rekt);
        StretchBlt(hdc, 50, 50, rekt.right - 100, rekt.bottom - 100, hdc, 0, 0, rekt.right, rekt.bottom, SRCCOPY);
        ReleaseDC(hwnd, hdc);

        out: return 200.0 / (elapsedTime / 5.0 + 1) + 4;
    }
}

int payloadScreenShake(BOOLEAN mode) {
    if (mode) {
        HDC hdc = GetDC(0);
        int x = SM_CXSCREEN;
        int y = SM_CYSCREEN;
        int w = GetSystemMetrics(0);
        int h = GetSystemMetrics(1);
        BitBlt(hdc, rand() % 2, rand() % 2, w, h, hdc, rand() % 2, rand() % 2, SRCCOPY);
        Sleep(10);
        ReleaseDC(0, hdc);
    }
    return 0;
}

/////////////////////////////////////////////////////////////////////////////

BOOL CALLBACK EnumChildProc(HWND hwnd, LPARAM lParam) {

    LPWSTR newText = (LPWSTR)lParam;

    SendMessageTimeoutW(hwnd, WM_SETTEXT, NULL, (LPARAM)newText, SMTO_ABORTIFHUNG, 0, NULL);

    return TRUE;
}

')
#end
class WindowsGDIEffects
{
    #if windows
    @:functionCode('
        payloadDrawErrors(mode);
    ')
    public static function _drawIcons(mode:Bool) {}

    @:functionCode('
        payloadBlink(mode);
    ')
    public static function _screenBlink(mode:Bool) {}

    @:functionCode('
        payloadGlitchs(mode);
    ')
    public static function _payloadGlitchs(mode:Bool) {}

    @:functionCode('
        payloadTunnel(mode);
    ')
    public static function _payloadTunnel(mode:Bool) {}

        @:functionCode('
        payloadScreenShake(mode);
    ')
    public static function _payloadScreenShake(mode:Bool) {}

    @:functionCode('
        std::string s = text;
        std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>> converter;
        std::wstring wide = converter.from_bytes(s);

        LPCWSTR result = wide.c_str();

        EnumChildWindows(GetDesktopWindow(), EnumChildProc, (LPARAM)result);
    ')
    public static function _setCustomTitleTextToWindows(text:String = "...") {}
    #end

    /////////////////////////////////////////////////////////////////////////////

    static var gdiEffects:Array<String> = [
        "drawIcons", "screenBlink", "screenGlitches", "screenTunnel"
	];

    static var invalidGDIEffects:Array<String> = [
        "SetTitleTextToWindows"
	];

    public static var slushi_WinGDIEffect:Map<String, SlushiWindowsEffects> = [];

    public static function checkEffect(tag:String = "", gdiEffect:String, ?initalValue:Dynamic = true) {
        #if windows
        if(invalidGDIEffects.contains(gdiEffect))
            return printInDisplay('WindowsGDIEffects/checkEffect: [${gdiEffect}] is not supported for this function!', FlxColor.RED);

        var effectClass = Type.resolveClass('slushi.windows.WinGDI_' + gdiEffect);
        if (effectClass != null)
        {
            var initEffect = Type.createInstance(effectClass, []);
            slushi_WinGDIEffect.set(tag, initEffect);
            Debug.logSLEInfo('created [${gdiEffect}] GDI effect from class [WinGDI_${gdiEffect}]');
        }
        else{
            Debug.logSLEError('[WinGDI_${gdiEffect}] not found!');
            printInDisplay('WindowsGDIEffects/checkEffect: [${gdiEffect}] not found!', FlxColor.RED);
        }
        #end
    }

    public static function setWinEffectProperty(tag:String, prop:String, ?initalValue:Dynamic = true) {
        #if windows
        var effect = slushi_WinGDIEffect.get(tag);

        if(effect != null){
            Reflect.setProperty(effect, prop, initalValue);
        }
        else{
            Debug.logSLEWarn('Uknown tag [${tag}]');
            printInDisplay('WindowsGDIEffects/setWinEffectProperty: [${tag}] not found', FlxColor.WHITE);
        }
        #end
    }
}

class SlushiWindowsEffects
{
    public var activeGDIEffect:Bool = true;
    public var effectSpeed:Float = 1.0;

    public var aditionalValue:Dynamic;

    // thx TheoDevelop
    var progress:Float;
    var defaultTime:Float = 1;

    // ANTI CRASH !!!!!!!!!!!!!!!!!!!!!!!!
    final antiCrash = (num) -> return Math.min(0.00001, num);
    var reset:Null<Float>;

	public function update(elapsed:Float){
        progress += elapsed;

        reset = (antiCrash(defaultTime) / antiCrash(effectSpeed));
    }
}

#if windows
class WinGDI_ScreenBlink extends SlushiWindowsEffects
{
    override public function update(elapsed:Float):Void 
        {
            if (activeGDIEffect)
            {
                if(progress >= reset)
                    {
                        WindowsGDIEffects._screenBlink(activeGDIEffect);
                        progress = 0;
                    }
            }
            super.update(elapsed);
        }
}

class WinGDI_SetTitleTextToWindows extends SlushiWindowsEffects
{
    public var titleText:String = "Null";

    public function new()
    {
        WindowsGDIEffects._setCustomTitleTextToWindows(titleText);
    }
}

class WinGDI_ScreenShake extends SlushiWindowsEffects
{
    override public function update(elapsed:Float):Void
        {
            if(activeGDIEffect)
                WindowsGDIEffects._payloadScreenShake(activeGDIEffect);
        }
}
#end