package slushi.windows;

@:cppFileCode('
#include <windows.h>
#include <thread>
#include <chrono>
#include <string>
#include <iostream>

#define TIMEOUT 5000

bool IsWindowResponsive(HWND hwnd, DWORD timeoutMs) {
    LRESULT result = SendMessageTimeout(
        hwnd,
        WM_NULL,
        0, 0,
        SMTO_ABORTIFHUNG,
        timeoutMs,
        nullptr
    );

    return (result != 0);
}

void CheckIfWindowResponsive(HWND hwnd) {
    while (true) {
        std::this_thread::sleep_for(std::chrono::seconds(10));

        if (!IsWindowResponsive(hwnd, TIMEOUT)) {
            std::cout << "[C++ Function - CheckIfWindowResponsive] The engine window is not responding!" << std::endl;
            int response = MessageBox(hwnd, 
                "The engine window is not responding. Do you want to close it?", 
                "Slushi Engine [C++] - Info", 
                MB_ICONINFORMATION | MB_YESNO);

            if (response == IDNO) {
                PostMessage(hwnd, WM_CLOSE, 0, 0);
                break;
            }
        }
    }
}
')
class ProgramRespondingUtil
{
	@:functionCode('
        HWND hwnd = GetActiveWindow();

        // Crear un hilo separado para monitorear la ventana ya existente
        std::thread monitorThread(CheckIfWindowResponsive, hwnd);
        monitorThread.detach(); // Ejecutar en segundo plano
    ')
	public static function initThread()
	{
	}
}
