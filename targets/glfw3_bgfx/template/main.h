
//Lang/OS...
#include <ctime>
#include <cmath>
#include <cctype>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <vector>
#include <typeinfo>
#include <signal.h>

#if _WIN32
#include <winsock2.h>
#include <windows.h>
#include <shlobj.h>
#include <direct.h>
#include <sys/stat.h>
#undef LoadString

#elif __APPLE__
#define GLFW_INCLUDE_GLCOREARB
#include <ApplicationServices/ApplicationServices.h>
#include <mach-o/dyld.h>
#include <sys/stat.h>
#include <dirent.h>
#include <copyfile.h>
#include <pthread.h>
#include <OpenGl/gl.h>  // header include necessary for mojo 1

#elif __linux
#define GL_GLEXT_PROTOTYPES
#include <unistd.h>
#include <sys/stat.h>
#include <dirent.h>
#include <pthread.h>
#endif

// Graphics/Audio stuff

// bx
#include <bx/bx.h>
#include <bx/os.h>

#if BX_PLATFORM_LINUX || BX_PLATFORM_BSD
#	define GLFW_EXPOSE_NATIVE_X11
#	define GLFW_EXPOSE_NATIVE_GLX
#elif BX_PLATFORM_OSX
#	define GLFW_EXPOSE_NATIVE_COCOA
#	define GLFW_EXPOSE_NATIVE_NSGL
#elif BX_PLATFORM_WINDOWS
#	define GLFW_EXPOSE_NATIVE_WIN32
#	define GLFW_EXPOSE_NATIVE_WGL
#endif
// #define GLFW_INCLUDE_NONE

//OpenGL...
#include <GLFW/glfw3.h>
#include <GLFW/glfw3native.h>

// bgfx
#include <bgfx/bgfx.h>
#include <bgfx/platform.h>
#include <bgfx/c99/bgfx.h>
// #include "logo.h"
#include "common.h"
#include "bgfx_utils.h"

// bimg
#include <bimg/decode.h>

//OpenAL...
//
#include <al.h>
#include <alc.h>

//stb_image lib
//
#include <stb_image.h>

//stb_vorbis lib
//
#define STB_VORBIS_HEADER_ONLY
#include <stb_vorbis.c>

// freetype
#if BX_COMPILER_MSVC
#	define generic GenericFromFreeType // WinRT language extensions see "generic" as a keyword... this is stupid
#endif // BX_COMPILER_MSVC

BX_PRAGMA_DIAGNOSTIC_PUSH();
BX_PRAGMA_DIAGNOSTIC_IGNORED_MSVC(4245) // error C4245: '=' : conversion from 'int' to 'FT_UInt', signed/unsigned mismatch
BX_PRAGMA_DIAGNOSTIC_IGNORED_MSVC(4611) // warning C4611 : interaction between '_setjmp' and C++ object destruction is non - portable
#if BX_COMPILER_MSVC || BX_COMPILER_GCC >= 40300
#pragma push_macro("interface")
#endif
#undef interface
#include <freetype.h>
#if BX_COMPILER_MSVC || BX_COMPILER_GCC >= 40300
#pragma pop_macro("interface")
#endif
BX_PRAGMA_DIAGNOSTIC_POP();

// sdf
#define SDF_IMPLEMENTATION
#include <sdf.h>

