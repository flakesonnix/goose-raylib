#ifndef GOOSE_RAYLIB_3D_H
#define GOOSE_RAYLIB_3D_H

#include <stdint.h>

/* Only scalars and pointers cross this boundary. Camera3D is ten f32 fields
 * followed by one i32; Matrix is sixteen f32 fields in declaration order.
 * Pointer arguments may be unaligned (Goose structs are packed): always
 * copy with memcpy, never dereference as a native raylib struct. */
void grl_begin_mode_3d(const void *camera);
void grl_end_mode_3d(void);
void grl_get_camera_matrix(const void *camera, void *out);
void grl_get_world_to_screen(float x, float y, float z, const void *camera, void *out);
void grl_get_screen_to_world_ray(float x, float y, const void *camera, void *out);
void grl_update_camera_pro(void *camera, float mx, float my, float mz,
                          float rx, float ry, float rz, float zoom);

/* Colors use 0xRRGGBBAA, independently of machine byte order. */
void grl_draw_line_3d(float ax, float ay, float az, float bx, float by, float bz, uint32_t rgba);
void grl_draw_point_3d(float x, float y, float z, uint32_t rgba);
void grl_draw_triangle_3d(float ax, float ay, float az, float bx, float by, float bz,
                          float cx, float cy, float cz, uint32_t rgba);
void grl_draw_cube(float x, float y, float z, float w, float h, float length, uint32_t rgba);
void grl_draw_cube_v(float x, float y, float z, float w, float h, float length, uint32_t rgba);
void grl_draw_cube_wires(float x, float y, float z, float w, float h, float length, uint32_t rgba);
void grl_draw_cube_wires_v(float x, float y, float z, float w, float h, float length, uint32_t rgba);
void grl_draw_sphere(float x, float y, float z, float radius, uint32_t rgba);
void grl_draw_sphere_ex(float x, float y, float z, float radius, int32_t rings, int32_t slices, uint32_t rgba);
void grl_draw_sphere_wires(float x, float y, float z, float radius, int32_t rings, int32_t slices, uint32_t rgba);
void grl_draw_cylinder(float x, float y, float z, float top, float bottom, float height, int32_t sides, uint32_t rgba);
void grl_draw_cylinder_ex(float ax, float ay, float az, float bx, float by, float bz,
                          float start_radius, float end_radius, int32_t sides, uint32_t rgba);
void grl_draw_cylinder_wires(float x, float y, float z, float top, float bottom, float height, int32_t sides, uint32_t rgba);
void grl_draw_cylinder_wires_ex(float ax, float ay, float az, float bx, float by, float bz,
                                float start_radius, float end_radius, int32_t sides, uint32_t rgba);
void grl_draw_capsule(float ax, float ay, float az, float bx, float by, float bz,
                       float radius, int32_t rings, int32_t slices, uint32_t rgba);
void grl_draw_capsule_wires(float ax, float ay, float az, float bx, float by, float bz,
                             float radius, int32_t rings, int32_t slices, uint32_t rgba);
void grl_draw_plane(float x, float y, float z, float width, float length, uint32_t rgba);
void grl_draw_ray(float x, float y, float z, float dx, float dy, float dz, uint32_t rgba);
void grl_draw_grid(int32_t slices, float spacing);
void grl_draw_bounding_box(float ax, float ay, float az, float bx, float by, float bz, uint32_t rgba);

#endif
