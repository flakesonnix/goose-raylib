/* White-box resource checks; rendering/oracles use real raylib/OpenGL only. */
#include "raylib_render_textures.c"
#include "raylib_models.h"
#include <assert.h>
#include <limits.h>
#include <stdio.h>

static void invalid_handles(void) {
    uint64_t invalid[] = {0, 1, UINT64_MAX, (UINT64_C(1) << 32) | RENDER_TEXTURE_TOKEN_TAG,
        (UINT64_C(1) << 32) | RENDER_TEXTURE_TOKEN_TAG | (GRL_MAX_RENDER_TEXTURES + 1)};
    for (size_t i = 0; i < sizeof(invalid)/sizeof(invalid[0]); ++i) {
        assert(!grl_is_render_texture_valid(invalid[i]));
        assert(!grl_begin_texture_mode(invalid[i]));
        assert(!grl_unload_render_texture(invalid[i]));
        assert(grl_render_texture_width(invalid[i]) == 0 && grl_render_texture_height(invalid[i]) == 0);
        assert(!grl_draw_render_texture(invalid[i], 0, 0, UINT32_MAX));
        assert(!grl_draw_render_texture_pro(invalid[i], 0, 0, 1, -1, 0, 0, 1, 1, 0, 0, 0, UINT32_MAX));
    }
}
static void headless(void) {
    invalid_handles();
    assert(grl_load_render_texture(32, 24) == 0);
    assert(!grl_is_texture_mode_active() && !grl_end_texture_mode());
    assert(grl_unload_all_render_textures() == 0);
    grl_shutdown_render_textures();
    puts("render texture adapter headless validation passed");
}
static void pattern(void) {
    ClearBackground(WHITE);
    DrawRectangle(0, 0, 32, 9, RED);
    DrawRectangle(0, 9, 32, 15, GREEN);
    DrawRectangle(24, 0, 8, 24, BLUE);
    DrawPixel(2, 3, YELLOW);
}
static Image capture(void) {
    rlDrawRenderBatchActive();
    Image image = LoadImageFromScreen();
    assert(IsImageValid(image));
    return image;
}
static void same_image(Image a, Image b) {
    assert(a.width == b.width && a.height == b.height);
    Color *ac = LoadImageColors(a), *bc = LoadImageColors(b);
    assert(ac != NULL && bc != NULL);
    size_t count = (size_t)a.width*a.height, colored = 0;
    assert(memcmp(ac, bc, count*sizeof(Color)) == 0);
    for (size_t i = 0; i < count; ++i) if (ac[i].r != 245 || ac[i].g != 245 || ac[i].b != 245) colored++;
    assert(colored > 20 && colored < count - 20);
    UnloadImageColors(ac); UnloadImageColors(bc);
    UnloadImage(a); UnloadImage(b);
}
static void pixel(Image image, int x, int y, Color expected) {
    Color actual = GetImageColor(image, x, y);
    assert(actual.r == expected.r && actual.g == expected.g && actual.b == expected.b && actual.a == expected.a);
}
static void simple_oracle(uint64_t token, RenderTexture2D native) {
    BeginDrawing(); ClearBackground(RAYWHITE);
    assert(grl_draw_render_texture(token, 20, 30, UINT32_MAX));
    Image actual = capture();
    pixel(actual, 25, 33, RED); pixel(actual, 25, 50, GREEN); pixel(actual, 49, 33, BLUE);
    pixel(actual, 5, 5, RAYWHITE);
    EndDrawing();
    BeginDrawing(); ClearBackground(RAYWHITE);
    DrawTextureRec(native.texture, (Rectangle){0, 0, 32, -24}, (Vector2){20, 30}, WHITE);
    Image expected = capture();
    EndDrawing();
    same_image(actual, expected);
}
static void pro_oracle(uint64_t token, RenderTexture2D native, Rectangle source, float angle) {
    Rectangle dest = {123, 72, 112, 81};
    Vector2 origin = {18, 11};
    Color tint = {201, 219, 167, 255};
    BeginDrawing(); ClearBackground(RAYWHITE);
    assert(grl_draw_render_texture_pro(token, source.x, source.y, source.width, source.height,
        dest.x, dest.y, dest.width, dest.height, origin.x, origin.y, angle, UINT32_C(0xc9dba7ff)));
    Image actual = capture();
    EndDrawing();
    BeginDrawing(); ClearBackground(RAYWHITE);
    DrawTexturePro(native.texture, source, dest, origin, angle, tint);
    Image expected = capture();
    EndDrawing();
    same_image(actual, expected);
}
static void graphics(void) {
    SetTraceLogLevel(LOG_WARNING);
    SetConfigFlags(FLAG_WINDOW_HIDDEN);
    InitWindow(320, 240, "render texture native oracles");
    assert(IsWindowReady());
    invalid_handles();
    typedef unsigned char (*IsObject)(unsigned int);
    IsObject is_fbo = (IsObject)rlGetProcAddress("glIsFramebuffer");
    IsObject is_texture = (IsObject)rlGetProcAddress("glIsTexture");
    IsObject is_renderbuffer = (IsObject)rlGetProcAddress("glIsRenderbuffer");
    typedef void (*GetInteger)(unsigned int, int *);
    GetInteger get_integer = (GetInteger)rlGetProcAddress("glGetIntegerv");
    assert(is_fbo && is_texture && is_renderbuffer && get_integer);
    assert(grl_load_render_texture(0, 24) == 0);
    assert(grl_load_render_texture(32, -1) == 0);
    assert(grl_load_render_texture(INT_MAX, INT_MAX) == 0);
    assert(grl_load_render_texture(GRL_MAX_RENDER_TEXTURE_SIZE + 1, 1) == 0);

    RenderTexture2D failed = LoadRenderTexture(4, 4);
    assert(IsRenderTextureValid(failed));
    failed.texture.width = 0;  // fail the native metadata validity check
    assert(retain_render_texture(0, failed) == 0);
    assert(!is_fbo(failed.id) && !is_texture(failed.texture.id) && !is_renderbuffer(failed.depth.id));
    assert(!render_texture_slots[0].in_use && render_texture_slots[0].generation == 0);
    Image solid = GenImageColor(2, 2, RED);
    failed = (RenderTexture2D){0};
    failed.id = rlLoadFramebuffer();
    failed.texture = LoadTextureFromImage(solid);
    failed.depth = failed.texture;  // valid metadata, but no FBO attachments
    UnloadImage(solid);
    assert(IsRenderTextureValid(failed));
    assert(retain_render_texture(0, failed) == 0);  // completeness must also be checked
    assert(!is_fbo(failed.id) && !is_texture(failed.texture.id));
    assert(render_texture_slots[0].generation == 0);

    uint64_t first = grl_load_render_texture(32, 24), second = grl_load_render_texture(80, 40);
    assert(grl_is_render_texture_valid(first) && grl_is_render_texture_valid(second));
    RenderTexture2D a = render_texture_slot(first)->target, b = render_texture_slot(second)->target;
    assert(grl_render_texture_width(first) == 32 && grl_render_texture_height(first) == 24);
    assert(is_fbo(a.id) && is_texture(a.texture.id) && is_renderbuffer(a.depth.id));
    assert(grl_begin_texture_mode(first));
    assert(grl_is_texture_mode_active() && rlGetActiveFramebuffer() == a.id);
    int viewport[4]; get_integer(0x0ba2, viewport);  // GL_VIEWPORT
    assert(viewport[2] == 32 && viewport[3] == 24);
    assert(grl_is_render_texture_valid(first) && rlGetActiveFramebuffer() == a.id);
    assert(!grl_begin_texture_mode(second) && !grl_begin_texture_mode(0));
    assert(!grl_unload_render_texture(first) && !grl_unload_render_texture(second));
    assert(grl_load_render_texture(8, 8) == 0 && grl_unload_all_render_textures() == 0);
    assert(!grl_draw_render_texture(first, 0, 0, UINT32_MAX));
    assert(!grl_draw_render_texture_pro(first, 0, 0, 32, -24, 0, 0, 32, 24, 0, 0, 0, UINT32_MAX));
    assert(rlGetActiveFramebuffer() == a.id);
    pattern();
    assert(grl_end_texture_mode() && !grl_end_texture_mode());
    assert(!grl_is_texture_mode_active() && rlGetActiveFramebuffer() == 0);
    get_integer(0x0ba2, viewport);
    assert(viewport[2] == 320 && viewport[3] == 240);
    RenderTexture2D native = LoadRenderTexture(32, 24);
    BeginTextureMode(native); pattern(); EndTextureMode();
    simple_oracle(first, native);
    pro_oracle(first, native, (Rectangle){3, 2, 25, -18}, 23);
    pro_oracle(first, native, (Rectangle){3, 2, -25, 18}, -17);
    pro_oracle(first, native, (Rectangle){0, 0, 32, -24}, 0);
    assert(!grl_draw_render_texture_pro(first, NAN, 0, 32, -24, 0, 0, 32, 24, 0, 0, 0, UINT32_MAX));
    assert(!grl_draw_render_texture_pro(first, 0, 0, 32, -24, 0, 0, 32, 24, 0, 0, INFINITY, UINT32_MAX));
    UnloadRenderTexture(native);

    assert(grl_begin_texture_mode(second));
    ClearBackground(BLACK);
    assert(grl_draw_render_texture(first, 4, 6, UINT32_MAX));  // other targets may be sampled
    assert(grl_end_texture_mode());
    BeginDrawing(); ClearBackground(RAYWHITE);
    assert(grl_draw_render_texture(second, 0, 0, UINT32_MAX));
    Image composite = capture();
    pixel(composite, 9, 9, RED); pixel(composite, 9, 26, GREEN); pixel(composite, 70, 35, BLACK);
    UnloadImage(composite); EndDrawing();

    // Unload before EndDrawing must flush already queued texture samples.
    BeginDrawing(); ClearBackground(RAYWHITE);
    assert(grl_draw_render_texture(first, 20, 30, UINT32_MAX));
    assert(grl_unload_render_texture(first));
    assert(!is_fbo(a.id) && !is_texture(a.texture.id) && !is_renderbuffer(a.depth.id));
    assert(is_fbo(b.id) && is_texture(b.texture.id) && is_renderbuffer(b.depth.id));
    Image flushed = capture(); pixel(flushed, 25, 33, RED); UnloadImage(flushed);
    EndDrawing();
    assert(!grl_unload_render_texture(first));
    uint64_t replacement = grl_load_render_texture(1, 1);
    assert(replacement != first && (uint32_t)replacement == (uint32_t)first);
    assert(!grl_is_render_texture_valid(first) && !grl_begin_texture_mode(first));
    assert(grl_unload_all_render_textures() == 2);
    assert(!is_fbo(b.id) && !is_texture(b.texture.id) && !is_renderbuffer(b.depth.id));
    assert(grl_unload_all_render_textures() == 0);

    for (int i = 0; i < GRL_MAX_RENDER_TEXTURES; ++i) assert(grl_load_render_texture(1, 1));
    assert(grl_load_render_texture(1, 1) == 0);
    uint64_t model = grl_gen_model_cube(1, 1, 1), mesh = grl_gen_mesh_cube(1, 1, 1);
    assert(model && mesh);  // capacities and token kinds are independent
    assert(!grl_is_render_texture_valid(model) && !grl_begin_texture_mode(mesh));
    assert(!grl_is_model_valid(replacement) && !grl_is_mesh_valid(replacement));
    assert(grl_unload_all_render_textures() == GRL_MAX_RENDER_TEXTURES);
    assert(grl_is_model_valid(model) && grl_is_mesh_valid(mesh));
    assert(grl_unload_model(model) && grl_unload_mesh(mesh));
    render_texture_slots[0].generation = UINT32_MAX - 1;
    uint64_t last = grl_load_render_texture(1, 1);
    assert((last >> 32) == UINT32_MAX && (uint32_t)last == (RENDER_TEXTURE_TOKEN_TAG | 1));
    assert(grl_unload_render_texture(last));
    uint64_t left = grl_load_render_texture(8, 8);
    assert(left && (uint32_t)left != (uint32_t)last && !grl_is_render_texture_valid(last));
    assert(grl_begin_texture_mode(left));
    ClearBackground(RED);
    DrawRectangle(0, 0, 4, 4, BLUE);
    grl_close_window();  // active mode is ended before resources and GL are destroyed
    assert(!IsWindowReady() && active_render_texture == 0);
    for (int i = 0; i < GRL_MAX_RENDER_TEXTURES; ++i) assert(!render_texture_slots[i].in_use);
    InitWindow(320, 240, "render textures reopened");
    assert(IsWindowReady());
    replacement = grl_load_render_texture(8, 8);
    assert(replacement && replacement != left && !grl_is_render_texture_valid(left));
    assert(grl_begin_texture_mode(replacement)); ClearBackground(BLUE);
    assert(grl_end_texture_mode() && grl_unload_all_render_textures() == 1);
    grl_close_window();
    puts("render texture adapter graphics passed (native image oracles, mode guards, GPU deletion, capacity, retirement)");
}
int main(int argc, char **argv) {
    headless();
    if (argc == 2 && strcmp(argv[1], "--graphics") == 0) graphics();
    else assert(argc == 1);
    return 0;
}
