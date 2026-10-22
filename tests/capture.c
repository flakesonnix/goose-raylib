/* Test-only real framebuffer readback, not a replacement for raylib. */
#include <raylib.h>
#include <rlgl.h>
#include "raylib_adapter.h"
#include <stdint.h>
#include <string.h>

uint32_t grl_test_pixel(int32_t x, int32_t y) {
    rlDrawRenderBatchActive();
    Image image = LoadImageFromScreen();
    if (!IsImageValid(image)) return 0;
    Color c = GetImageColor(image, x, y);
    UnloadImage(image);
    return ((uint32_t)c.r << 24) | ((uint32_t)c.g << 16) | ((uint32_t)c.b << 8) | c.a;
}

uint8_t grl_test_title(goose_slice_u8 title) {
    /* The Goose test passes a subslice of a longer, non-NUL-terminated value. */
    return strcmp(rl_to_c_string(title), "3D ABI test") == 0;
}
