
CC=gcc
CFLAGS=

CXX=g++
CXXFLAGS=

CPPFLAGS=$(CCOPTS) \
-MMD -MP -MP -D__STDC_LIMIT_MACROS -D__STDC_FORMAT_MACROS \
-D__STDC_CONSTANT_MACROS -DNDEBUG -DWIN32 \
-DMINGW_HAS_SECURE_API=1 -DENTRY_CONFIG_IMPLEMENT_MAIN=1 \
-I../curl/include \
-I../bx/include/compat/mingw \
-I../bx/include \
-I../bimg/include \
-I../bgfx/include \
-I../bgfx/examples/common \
-I../freetype \
-I../sdf \
-Wall -Wextra -fomit-frame-pointer -g -O3 -m64 \
-Wshadow -fdata-sections -ffunction-sections \
-msse2 -m64 -w \
-Wno-free-nonheap-object\
-I../curl/include \
-I../glfw3/include \
-I../glfw3/src \
-I../openal/include \
-I../stb \
-I../zlib-1.2.8 \
-I../lpng1610

LD=g++
LDFLAGS=$(LDOPTS) -Wl,--subsystem,windows
#LDLIBS=-lcomdlg32 -lgdi32 -lopengl32 $(LIBOPTS) -lws2_32
LDLIBS= \
-L"." \
-L../openal/libs/Win64 \
-mwindows -m64 -Wl,--gc-sections -static -static-libgcc -static-libstdc++ \
../bgfx/libs/libexample-commonRelease.a \
../bgfx/libs/libexample-glueRelease.a \
../bgfx/libs/libbgfxRelease.a \
../bgfx/libs/libbimg_decodeRelease.a \
../bgfx/libs/libbimgRelease.a \
../bgfx/libs/libbxRelease.a \
-lcomdlg32 -lgdi32 -lopengl32 $(LIBOPTS) -lws2_32 -lpsapi

vpath %.c ../glfw3/src
vpath %.c ../stb
vpath %.cpp ..

OBJS0=\
context.o \
egl_context.o \
init.o \
input.o \
monitor.o \
osmesa_context.o \
vulkan.o \
wgl_context.o \
win32_init.o \
win32_joystick.o \
win32_monitor.o \
win32_time.o \
win32_thread.o \
win32_window.o \
window.o \
stb_vorbis.o \
main.o

# stb_image.o \

TMP=build/$(dir $(OUT))

OBJS=$(patsubst %.o,$(TMP)%.o,$(OBJS0))

all : $(OUT)

$(OUT) : $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $(OBJS) $(LDLIBS)

$(TMP)%.o : %.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -c -o $@ $<

$(TMP)%.o : %.cpp
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c -o $@ $<
