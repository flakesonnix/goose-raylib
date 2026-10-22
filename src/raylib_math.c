#include "raylib_math.h"

/* raymath is header-only here. No assumption that these inline functions
 * exist as exported symbols in libraylib, and no copied upstream math code. */
#define RAYMATH_STATIC_INLINE
#include <raymath.h>
#include <string.h>

_Static_assert(sizeof(float) == 4, "Goose f32 requires 32-bit float");
_Static_assert(sizeof(double) == 8, "Goose f64 requires 64-bit double");

static Vector3 read_v(const void *data) {
    float f[3];
    memcpy(f, data, sizeof(f));
    return (Vector3){f[0], f[1], f[2]};
}
static void write_v(void *out, Vector3 v) {
    float f[3] = {v.x, v.y, v.z};
    memcpy(out, f, sizeof(f));
}
static Quaternion read_q(const void *data) {
    float f[4];
    memcpy(f, data, sizeof(f));
    return (Quaternion){f[0], f[1], f[2], f[3]};
}
static void write_q(void *out, Quaternion q) {
    float f[4] = {q.x, q.y, q.z, q.w};
    memcpy(out, f, sizeof(f));
}
static Matrix read_m(const void *data) {
    float f[16];
    memcpy(f, data, sizeof(f));
    return (Matrix){f[0], f[1], f[2], f[3], f[4], f[5], f[6], f[7],
                    f[8], f[9], f[10], f[11], f[12], f[13], f[14], f[15]};
}
static void write_m(void *out, Matrix m) {
    float f[16] = {m.m0, m.m4, m.m8, m.m12, m.m1, m.m5, m.m9, m.m13,
                   m.m2, m.m6, m.m10, m.m14, m.m3, m.m7, m.m11, m.m15};
    memcpy(out, f, sizeof(f));
}

void grm_vector3_add(const void *a, const void *b, void *out) { write_v(out, Vector3Add(read_v(a), read_v(b))); }
void grm_vector3_subtract(const void *a, const void *b, void *out) { write_v(out, Vector3Subtract(read_v(a), read_v(b))); }
void grm_vector3_scale(const void *v, float scale, void *out) { write_v(out, Vector3Scale(read_v(v), scale)); }
float grm_vector3_dot(const void *a, const void *b) { return Vector3DotProduct(read_v(a), read_v(b)); }
float grm_vector3_length(const void *v) { return Vector3Length(read_v(v)); }
void grm_vector3_cross(const void *a, const void *b, void *out) { write_v(out, Vector3CrossProduct(read_v(a), read_v(b))); }
void grm_vector3_normalize(const void *v, void *out) { write_v(out, Vector3Normalize(read_v(v))); }
void grm_vector3_transform(const void *v, const void *m, void *out) { write_v(out, Vector3Transform(read_v(v), read_m(m))); }
void grm_vector3_lerp(const void *a, const void *b, float amount, void *out) { write_v(out, Vector3Lerp(read_v(a), read_v(b), amount)); }

void grm_matrix_identity(void *out) { write_m(out, MatrixIdentity()); }
void grm_matrix_translate(float x, float y, float z, void *out) { write_m(out, MatrixTranslate(x, y, z)); }
void grm_matrix_scale(float x, float y, float z, void *out) { write_m(out, MatrixScale(x, y, z)); }
void grm_matrix_rotate_xyz(const void *angles, void *out) { write_m(out, MatrixRotateXYZ(read_v(angles))); }
void grm_matrix_multiply(const void *left, const void *right, void *out) { write_m(out, MatrixMultiply(read_m(left), read_m(right))); }
void grm_matrix_invert(const void *m, void *out) { write_m(out, MatrixInvert(read_m(m))); }
void grm_matrix_perspective(double fovy, double aspect, double near_plane, double far_plane, void *out) {
    write_m(out, MatrixPerspective(fovy, aspect, near_plane, far_plane));
}
void grm_matrix_ortho(double left, double right, double bottom, double top, double near_plane, double far_plane, void *out) {
    write_m(out, MatrixOrtho(left, right, bottom, top, near_plane, far_plane));
}
void grm_matrix_look_at(const void *eye, const void *target, const void *up, void *out) {
    write_m(out, MatrixLookAt(read_v(eye), read_v(target), read_v(up)));
}

void grm_quaternion_identity(void *out) { write_q(out, QuaternionIdentity()); }
void grm_quaternion_normalize(const void *q, void *out) { write_q(out, QuaternionNormalize(read_q(q))); }
void grm_quaternion_multiply(const void *a, const void *b, void *out) { write_q(out, QuaternionMultiply(read_q(a), read_q(b))); }
void grm_quaternion_slerp(const void *a, const void *b, float amount, void *out) { write_q(out, QuaternionSlerp(read_q(a), read_q(b), amount)); }
void grm_quaternion_from_axis_angle(const void *axis, float angle, void *out) { write_q(out, QuaternionFromAxisAngle(read_v(axis), angle)); }
void grm_quaternion_to_matrix(const void *q, void *out) { write_m(out, QuaternionToMatrix(read_q(q))); }
void grm_quaternion_from_matrix(const void *m, void *out) { write_q(out, QuaternionFromMatrix(read_m(m))); }
