#ifndef GOOSE_RAYLIB_MODELS_H
#define GOOSE_RAYLIB_MODELS_H

#include "raylib_adapter.h"

#define GRL_MAX_MODELS 64

/* Tokens: upper 32 bits = generation, lower 32 bits = one-based slot.
 * Zero is invalid. No native pointers/Model structs cross this boundary. */
uint64_t grl_load_model(goose_slice_u8 path);
uint64_t grl_gen_model_cube(float width, float height, float length);
uint8_t grl_is_model_valid(uint64_t token);
uint8_t grl_unload_model(uint64_t token);
int32_t grl_unload_all_models(void);
int32_t grl_model_mesh_count(uint64_t token);
int32_t grl_model_material_count(uint64_t token);
/* out borrows 24 writable bytes (six f32 fields), possibly unaligned.
 * Invalid handles write all-zero bounds and return false. */
uint8_t grl_get_model_bounding_box(uint64_t token, void *out);
uint8_t grl_draw_model(uint64_t token, float x, float y, float z, float scale, uint32_t rgba);
uint8_t grl_draw_model_ex(uint64_t token, float x, float y, float z,
                          float ax, float ay, float az, float angle,
                          float sx, float sy, float sz, uint32_t rgba);
uint8_t grl_draw_model_wires(uint64_t token, float x, float y, float z, float scale, uint32_t rgba);
uint8_t grl_draw_model_wires_ex(uint64_t token, float x, float y, float z,
                                float ax, float ay, float az, float angle,
                                float sx, float sy, float sz, uint32_t rgba);

/* Explicit window shutdown releases managed models before destroying GL. */
void grl_close_window(void);

#endif
