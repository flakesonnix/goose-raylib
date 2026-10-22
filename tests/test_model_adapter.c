/* White-box tests use the actual adapter source, with real raylib/GL calls.
 * This lets us test generation exhaustion without creating 2^32 resources,
 * and inspect owned texture IDs without exposing native pointers to Goose. */
#include "raylib_models.c"
#include <assert.h>
#include <stdio.h>

static goose_slice_u8 text(const char *s) {
    return (goose_slice_u8){(const uint8_t *)s, (int64_t)strlen(s)};
}

static void headless(void) {
    uint64_t invalid[] = {0, 1, UINT64_MAX, UINT64_C(1) << 32, (UINT64_C(1) << 32) | (GRL_MAX_MODELS + 1)};
    for (size_t i = 0; i < sizeof(invalid)/sizeof(invalid[0]); ++i) {
        unsigned char out[26];
        memset(out, 0xa5, sizeof(out));
        assert(!grl_is_model_valid(invalid[i]));
        assert(!grl_unload_model(invalid[i]));
        assert(!grl_get_model_bounding_box(invalid[i], out + 1));
        assert(out[0] == 0xa5 && out[25] == 0xa5);
        for (int j = 1; j < 25; ++j) assert(out[j] == 0);
        assert(!grl_draw_model(invalid[i], 0, 0, 0, 1, UINT32_MAX));
        assert(!grl_draw_model_wires(invalid[i], 0, 0, 0, 1, UINT32_MAX));
    }
    assert(grl_load_model(text("no-window.obj")) == 0);
    assert(grl_gen_model_cube(1, 1, 1) == 0);
    assert(grl_unload_all_models() == 0);
    grl_close_window();  // safe before initialization and after shutdown
    puts("model adapter headless validation passed");
}

static unsigned int owned_texture(Model model) {
    for (int m = 0; m < model.materialCount; ++m) {
        for (int map = MATERIAL_MAP_ALBEDO; map <= MATERIAL_MAP_BRDF; ++map) {
            unsigned int id = model.materials[m].maps[map].texture.id;
            if (id != 0 && id != rlGetTextureIdDefault()) return id;
        }
    }
    return 0;
}

static void graphics(const char *assets) {
    SetTraceLogLevel(LOG_WARNING);
    SetConfigFlags(FLAG_WINDOW_HIDDEN);
    InitWindow(320, 240, "model adapter lifecycle");
    assert(IsWindowReady());
    typedef unsigned char (*IsTexture)(unsigned int);
    IsTexture is_texture = (IsTexture)rlGetProcAddress("glIsTexture");
    typedef unsigned char (*IsObject)(unsigned int);
    IsObject is_program = (IsObject)rlGetProcAddress("glIsProgram");
    IsObject is_buffer = (IsObject)rlGetProcAddress("glIsBuffer");
    assert(is_texture != NULL && is_program != NULL && is_buffer != NULL);

    assert(grl_gen_model_cube(0, 1, 1) == 0);
    assert(grl_gen_model_cube(NAN, 1, 1) == 0);
    assert(grl_gen_model_cube(1, INFINITY, 1) == 0);
    assert(grl_load_model((goose_slice_u8){NULL, -1}) == 0);
    assert(grl_load_model((goose_slice_u8){NULL, 10}) == 0);
    assert(grl_load_model(text("")) == 0);
    unsigned char too_long[RL_ADAPTER_MAX_STR];
    memset(too_long, 'x', sizeof(too_long));
    assert(grl_load_model((goose_slice_u8){too_long, sizeof(too_long)}) == 0);

    uint64_t model = grl_gen_model_cube(2, 4, 6);
    assert(grl_is_model_valid(model));
    assert(!grl_draw_model(model, 0, 0, 0, INFINITY, UINT32_MAX));
    assert(!grl_draw_model_ex(model, 0, 0, 0, 0, 1, 0, NAN, 1, 1, 1, UINT32_MAX));
    assert(!grl_draw_model_wires(model, NAN, 0, 0, 1, UINT32_MAX));
    assert(!grl_draw_model_wires_ex(model, 0, 0, 0, 0, 1, 0, 0, 1, INFINITY, 1, UINT32_MAX));
    unsigned char bounds[26];
    memset(bounds, 0xa5, sizeof(bounds));
    assert(grl_get_model_bounding_box(model, bounds + 1));
    float actual[6];
    memcpy(actual, bounds + 1, sizeof(actual));
    const float expected[6] = {-1, -2, -3, 1, 2, 3};
    assert(memcmp(actual, expected, sizeof(expected)) == 0);
    assert(bounds[0] == 0xa5 && bounds[25] == 0xa5);
    assert(grl_unload_model(model));
    assert(!grl_unload_model(model));
    uint64_t replacement = grl_gen_model_cube(1, 1, 1);
    assert(replacement != model && (uint32_t)replacement == (uint32_t)model);
    assert(!grl_is_model_valid(model));
    assert(!grl_draw_model(model, 0, 0, 0, 1, UINT32_MAX));
    assert(grl_unload_model(replacement));

    char path[4096];
    int n = snprintf(path, sizeof(path), "%s/textured.obj", assets);
    assert(n > 0 && n < (int)sizeof(path));
    uint64_t first = grl_load_model(text(path));
    uint64_t second = grl_load_model(text(path));
    assert(first && second);
    ModelSlot *slot = model_slot(first);
    unsigned int texture = owned_texture(slot->model);
    unsigned int other_texture = owned_texture(model_slot(second)->model);
    unsigned int default_texture = rlGetTextureIdDefault();
    unsigned int vertex_buffer = slot->model.meshes[0].vboId[0];
    unsigned int other_buffer = model_slot(second)->model.meshes[0].vboId[0];
    assert(texture && other_texture && texture != other_texture);
    assert(is_texture(texture) && is_texture(other_texture) && is_texture(default_texture));
    assert(vertex_buffer != other_buffer && is_buffer(vertex_buffer) && is_buffer(other_buffer));
    // Force legitimate same-model map/material aliases to exercise deduplication.
    Texture2D shared = {0};
    for (int m = 0; m < slot->model.materialCount; ++m) {
        if (slot->model.materials[m].maps[MATERIAL_MAP_ALBEDO].texture.id == texture) {
            shared = slot->model.materials[m].maps[MATERIAL_MAP_ALBEDO].texture;
            break;
        }
    }
    assert(shared.id == texture);
    Shader shader = LoadShaderFromMemory(NULL,
        "#version 330\nout vec4 finalColor;\nvoid main() { finalColor = vec4(1.0); }\n");
    unsigned int default_shader = rlGetShaderIdDefault();
    assert(IsShaderValid(shader) && shader.id != default_shader);
    assert(is_program(shader.id) && is_program(default_shader));
    for (int m = 0; m < slot->model.materialCount; ++m) {
        assert(slot->model.materials[m].maps[MATERIAL_MAP_NORMAL].texture.id == 0);
        slot->model.materials[m].maps[MATERIAL_MAP_NORMAL].texture = shared;
        slot->model.materials[m].shader = shader;
    }
    assert(grl_unload_model(first));
    assert(!is_texture(texture));  // actual GPU texture released, not just a token
    assert(!is_buffer(vertex_buffer) && is_buffer(other_buffer));
    assert(!is_program(shader.id) && is_program(default_shader));
    assert(is_texture(other_texture) && is_texture(default_texture));
    assert(grl_unload_model(second));
    assert(!is_buffer(other_buffer));
    assert(!is_texture(other_texture) && is_texture(default_texture));

    for (int i = 0; i < GRL_MAX_MODELS; ++i) assert(grl_gen_model_cube(1, 1, 1) != 0);
    assert(grl_gen_model_cube(1, 1, 1) == 0);  // full table, no extra mesh allocated
    assert(grl_load_model(text(path)) == 0);
    assert(grl_unload_all_models() == GRL_MAX_MODELS);
    assert(grl_unload_all_models() == 0);

    model_slots[0].generation = UINT32_MAX - 1;  // unused slot, test wrap boundary
    uint64_t last = grl_gen_model_cube(1, 1, 1);
    assert((last >> 32) == UINT32_MAX && (uint32_t)last == 1);
    assert(grl_unload_model(last));
    uint64_t after = grl_gen_model_cube(1, 1, 1);
    assert(after != 0 && (uint32_t)after != 1);  // retired, never recycled
    assert(!grl_is_model_valid(last));

    grl_close_window();  // releases the remaining managed model before GL closes
    assert(!IsWindowReady() && !grl_is_model_valid(after));
    InitWindow(320, 240, "model adapter reopened context");
    assert(IsWindowReady());
    uint64_t reopened = grl_gen_model_cube(1, 1, 1);
    assert(reopened != 0 && reopened != after && !grl_is_model_valid(after));
    assert(grl_unload_all_models() == 1);
    grl_close_window();
    puts("model adapter graphics passed (ownership, stale IDs, capacity, generation retirement, context reopen)");
}

int main(int argc, char **argv) {
    headless();
    if (argc == 3 && strcmp(argv[1], "--graphics") == 0) graphics(argv[2]);
    else assert(argc == 1);
    return 0;
}
