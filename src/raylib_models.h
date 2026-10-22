#ifndef GOOSE_RAYLIB_MODELS_H
#define GOOSE_RAYLIB_MODELS_H

#include "raylib_adapter.h"

#define GRL_MAX_MODELS 64
#define GRL_MAX_MESHES 64
/* Bound native tessellation arithmetic, allocation sizes and 16-bit indices. */
#define GRL_MAX_MESH_SUBDIVISIONS 128

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

/* Mesh tokens use a distinct low-word tag; they cannot name a model slot.
 * Generated meshes are uploaded by raylib and require a live window. */
uint64_t grl_gen_mesh_poly(int32_t sides, float radius);
uint64_t grl_gen_mesh_plane(float width, float length, int32_t res_x, int32_t res_z);
uint64_t grl_gen_mesh_cube(float width, float height, float length);
uint64_t grl_gen_mesh_sphere(float radius, int32_t rings, int32_t slices);
uint64_t grl_gen_mesh_hemi_sphere(float radius, int32_t rings, int32_t slices);
uint64_t grl_gen_mesh_cylinder(float radius, float height, int32_t slices);
uint64_t grl_gen_mesh_cone(float radius, float height, int32_t slices);
uint8_t grl_is_mesh_valid(uint64_t token);
uint8_t grl_unload_mesh(uint64_t token);
int32_t grl_unload_all_meshes(void);
int32_t grl_mesh_vertex_count(uint64_t token);
int32_t grl_mesh_triangle_count(uint64_t token);
uint8_t grl_get_mesh_bounding_box(uint64_t token, void *out);
/* transform borrows 64 possibly unaligned bytes, in Goose Matrix field order.
 * DrawMesh uses the default material with a temporary tint, not a Material ABI. */
uint8_t grl_draw_mesh(uint64_t token, const void *transform, uint32_t rgba);
/* Success moves ownership and invalidates every source alias. Failure (zero)
 * leaves a valid source intact, including when the model table is full. */
uint64_t grl_load_model_from_mesh(uint64_t token);

/* Explicit window shutdown releases managed models/meshes before destroying GL. */
void grl_close_window(void);

#endif
