package slushi.others;

import sys.io.File;

/**
 * A simple macro for showing information about the engine compilation
 * 
 * Author: Slushi
 */

class EngineMacros
{
    #if macro
    static var ENGINE_VERSION = "0.3.4";
    static var CUSTOM_BUILD_NAME = "not defined";

    public static function initialize_compilation() {
        Sys.println('\n\x1b[38;5;236m== STARTING COMPILATION ===================\033[0m');
        Sys.println('---- \033[96mSlushi Engine\033[0m version: \x1b[38;5;236m[\033[0m\x1b[38;5;11m${ENGINE_VERSION}\033[0m\x1b[38;5;236m]\033[0m ----');

        Sys.println('\x1b[38;5;7mBuild info:\033[0m');
        #if SLUSHI_CPP_CODE
        Sys.println('C++ Code is \x1b[38;5;10menabled\x1b[0m');
        #else
        Sys.println('C++ Code is \x1b[38;5;1mdisabled\x1b[0m');
        #end
        #if SLUSHI_LUA
        Sys.println('Slushi Lua is \x1b[38;5;10menabled\x1b[0m');
        #else
        Sys.println('Slushi Lua is \x1b[38;5;1mdisabled\x1b[0m');
        #end
        #if CUSTOM_BUILD
        Sys.println('This is a custom build?: \x1b[38;5;10mYES\x1b[0m');
        Sys.println('Custom build name: \x1b[38;5;242m${CUSTOM_BUILD_NAME}\x1b[0m');
        #else
        Sys.println('This is a custom build?: \x1b[38;5;1mNO\x1b[0m');
        #end
        #if THIS_IS_A_BUILD_TEST
        Sys.println('Compiling a \x1b[38;5;11mtest build\x1b[0m!');
        #end
        #if windows
        Sys.println('Compiling for \x1b[38;5;4mWindows\x1b[0m');
        #elseif linux
        Sys.println('Compiling for \x1b[38;5;5mmLinux\x1b[0m');
        #end

        Sys.println('-----------');
        Sys.println('Trying to initialize the compilation...');
        Sys.println('Date on start compilation: \033[32m${Date.now().toString()}\033[0m');
        Sys.println('\x1b[38;5;234m==========================\033[0m\n\x1b[38;5;8m');
    }
    #end
}