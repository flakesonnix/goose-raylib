#include "raylib_3d.h"

#include <raylib.h>
#include <string.h>

_Static_assert(sizeof(float) == 4, "Goose f32 requires 32-bit float");
_Static_assert(sizeof(int) == 4, "raylib int requires 32 bits");

static Camera3D read_camera(const void *data) {
    float f[10];
    int32_t projection;
    memcpy(f, data, sizeof(f));
    memcpy(&projection, (const unsigned char *)data + sizeof(f), sizeof(projection));
    return (Camera3D){ {f[0], f[1], f[2]}, {f[3], f[4], f[5]},
                       {f[6], f[7], f[8]}, f[9], projection };
}

static void write_camera(void *data, Camera3D c) {
    float f[10] = { c.position.x, c.position.y, c.position.z,
                    c.target.x, c.target.y, c.target.z,
                    c.up.x, c.up.y, c.up.z, c.fovy };
    int32_t projection = c.projection;
    memcpy(data, f, sizeof(f));
    memcpy((unsigned char *)data + sizeof(f), &projection, sizeof(projection));
}

static Color unpack_color(uint32_t c) {
    return (Color){ (unsigned char)(c >> 24), (unsigned char)(c >> 16),
                    (unsigned char)(c >> 8), (unsigned char)c };
}

void grl_begin_mode_3d(const void *camera) { BeginMode3D(read_camera(camera)); }
void grl_end_mode_3d(void) { EndMode3D(); }

void grl_get_camera_matrix(const void *camera, void *out) {
    Matrix m = GetCameraMatrix(read_camera(camera));
    float fields[16] = { m.m0, m.m4, m.m8, m.m12, m.m1, m.m5, m.m9, m.m13,
                         m.m2, m.m6, m.m10, m.m14, m.m3, m.m7, m.m11, m.m15 };
    memcpy(out, fields, sizeof(fields));
}

void grl_get_world_to_screen(float x, float y, float z, const void *camera, void *out) {
    Vector2 v = GetWorldToScreen((Vector3){x, y, z}, read_camera(camera));
    float fields[2] = { v.x, v.y };
    memcpy(out, fields, sizeof(fields));
}

void grl_get_screen_to_world_ray(float x, float y, const void *camera, void *out) {
    Ray r = GetScreenToWorldRay((Vector2){x, y}, read_camera(camera));
    float fields[6] = { r.position.x, r.position.y, r.position.z,
                        r.direction.x, r.direction.y, r.direction.z };
    memcpy(out, fields, sizeof(fields));
}

void grl_update_camera_pro(void *camera, float mx, float my, float mz,
                          float rx, float ry, float rz, float zoom) {
    Camera3D c = read_camera(camera);
    UpdateCameraPro(&c, (Vector3){mx, my, mz}, (Vector3){rx, ry, rz}, zoom);
    write_camera(camera, c);
}

void grl_draw_line_3d(float ax, float ay, float az, float bx, float by, float bz, uint32_t c) {
    DrawLine3D((Vector3){ax, ay, az}, (Vector3){bx, by, bz}, unpack_color(c));
}
void grl_draw_point_3d(float x, float y, float z, uint32_t c) {
    DrawPoint3D((Vector3){x, y, z}, unpack_color(c));
}
void grl_draw_triangle_3d(float ax, float ay, float az, float bx, float by, float bz,
                          float cx, float cy, float cz, uint32_t c) {
    DrawTriangle3D((Vector3){ax, ay, az}, (Vector3){bx, by, bz}, (Vector3){cx, cy, cz}, unpack_color(c));
}
void grl_draw_cube(float x, float y, float z, float w, float h, float length, uint32_t c) {
    DrawCube((Vector3){x, y, z}, w, h, length, unpack_color(c));
}
void grl_draw_cube_v(float x, float y, float z, float w, float h, float length, uint32_t c) {
    DrawCubeV((Vector3){x, y, z}, (Vector3){w, h, length}, unpack_color(c));
}
void grl_draw_cube_wires(float x, float y, float z, float w, float h, float length, uint32_t c) {
    DrawCubeWires((Vector3){x, y, z}, w, h, length, unpack_color(c));
}
void grl_draw_cube_wires_v(float x, float y, float z, float w, float h, float length, uint32_t c) {
    DrawCubeWiresV((Vector3){x, y, z}, (Vector3){w, h, length}, unpack_color(c));
}
void grl_draw_sphere(float x, float y, float z, float radius, uint32_t c) {
    DrawSphere((Vector3){x, y, z}, radius, unpack_color(c));
}
void grl_draw_sphere_ex(float x, float y, float z, float radius, int32_t rings, int32_t slices, uint32_t c) {
    DrawSphereEx((Vector3){x, y, z}, radius, rings, slices, unpack_color(c));
}
void grl_draw_sphere_wires(float x, float y, float z, float radius, int32_t rings, int32_t slices, uint32_t c) {
    DrawSphereWires((Vector3){x, y, z}, radius, rings, slices, unpack_color(c));
}
void grl_draw_cylinder(float x, float y, float z, float top, float bottom, float height, int32_t sides, uint32_t c) {
    DrawCylinder((Vector3){x, y, z}, top, bottom, height, sides, unpack_color(c));
}
void grl_draw_cylinder_ex(float ax, float ay, float az, float bx, float by, float bz,
                          float start_radius, float end_radius, int32_t sides, uint32_t c) {
    DrawCylinderEx((Vector3){ax, ay, az}, (Vector3){bx, by, bz}, start_radius, end_radius, sides, unpack_color(c));
}
void grl_draw_cylinder_wires(float x, float y, float z, float top, float bottom, float height, int32_t sides, uint32_t c) {
    DrawCylinderWires((Vector3){x, y, z}, top, bottom, height, sides, unpack_color(c));
}
void grl_draw_cylinder_wires_ex(float ax, float ay, float az, float bx, float by, float bz,
                                float start_radius, float end_radius, int32_t sides, uint32_t c) {
    DrawCylinderWiresEx((Vector3){ax, ay, az}, (Vector3){bx, by, bz}, start_radius, end_radius, sides, unpack_color(c));
}
void grl_draw_capsule(float ax, float ay, float az, float bx, float by, float bz,
                       float radius, int32_t rings, int32_t slices, uint32_t c) {
    DrawCapsule((Vector3){ax, ay, az}, (Vector3){bx, by, bz}, radius, rings, slices, unpack_color(c));
}
void grl_draw_capsule_wires(float ax, float ay, float az, float bx, float by, float bz,
                             float radius, int32_t rings, int32_t slices, uint32_t c) {
    DrawCapsuleWires((Vector3){ax, ay, az}, (Vector3){bx, by, bz}, radius, rings, slices, unpack_color(c));
}
void grl_draw_plane(float x, float y, float z, float width, float length, uint32_t c) {
    DrawPlane((Vector3){x, y, z}, (Vector2){width, length}, unpack_color(c));
}
void grl_draw_ray(float x, float y, float z, float dx, float dy, float dz, uint32_t c) {
    DrawRay((Ray){ {x, y, z}, {dx, dy, dz} }, unpack_color(c));
}
void grl_draw_grid(int32_t slices, float spacing) { DrawGrid(slices, spacing); }
void grl_draw_bounding_box(float ax, float ay, float az, float bx, float by, float bz, uint32_t c) {
    DrawBoundingBox((BoundingBox){ {ax, ay, az}, {bx, by, bz} }, unpack_color(c));
}
