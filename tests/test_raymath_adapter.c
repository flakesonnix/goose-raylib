#include "raylib_math.h"
#define RAYMATH_STATIC_INLINE
#include <raymath.h>
#include <assert.h>
#include <stdio.h>
#include <string.h>

/* Every operation uses unaligned input/output buffers. Check all trailing
 * bytes so a Vector3/Quaternion output cannot accidentally write a Matrix. */
static void check_fields(const unsigned char *out, const float *expected, size_t n) {
    assert(out[0] == 0xa5);
    float actual[16];
    memcpy(actual, out + 1, n * sizeof(float));
    for (size_t i = 0; i < n; i++) assert(fabsf(actual[i] - expected[i]) < 0.00001f);
    for (size_t i = 1 + n * sizeof(float); i < 66; i++) assert(out[i] == 0xa5);
}
static void check_v(const unsigned char *out, Vector3 v) {
    const float f[3] = {v.x, v.y, v.z}; check_fields(out, f, 3);
}
static void check_q(const unsigned char *out, Quaternion q) {
    const float f[4] = {q.x, q.y, q.z, q.w}; check_fields(out, f, 4);
}
static void store_m(void *out, Matrix m) {
    const float f[16] = {m.m0, m.m4, m.m8, m.m12, m.m1, m.m5, m.m9, m.m13,
                         m.m2, m.m6, m.m10, m.m14, m.m3, m.m7, m.m11, m.m15};
    memcpy(out, f, sizeof(f));
}
static void check_m(const unsigned char *out, Matrix m) {
    float expected[16]; store_m(expected, m); check_fields(out, expected, 16);
}

int main(void) {
    unsigned char a[66], b[66], ma[66], mb[66], qa[66], qb[66], out[66];
    const float af[3] = {1.25f, -2.5f, 3.75f}, bf[3] = {-4.5f, 5.25f, 6.5f};
    const Vector3 av = {af[0], af[1], af[2]}, bv = {bf[0], bf[1], bf[2]};
    memcpy(a + 1, af, sizeof(af)); memcpy(b + 1, bf, sizeof(bf));

    memset(out, 0xa5, sizeof(out));
    grm_vector3_add(a + 1, b + 1, out + 1); check_v(out, Vector3Add(av, bv));
    grm_vector3_subtract(a + 1, b + 1, out + 1); check_v(out, Vector3Subtract(av, bv));
    grm_vector3_scale(a + 1, -2, out + 1); check_v(out, Vector3Scale(av, -2));
    assert(fabsf(grm_vector3_dot(a + 1, b + 1) - Vector3DotProduct(av, bv)) < 0.00001f);
    assert(fabsf(grm_vector3_length(a + 1) - Vector3Length(av)) < 0.00001f);
    grm_vector3_cross(a + 1, b + 1, out + 1); check_v(out, Vector3CrossProduct(av, bv));
    grm_vector3_normalize(a + 1, out + 1); check_v(out, Vector3Normalize(av));
    grm_vector3_lerp(a + 1, b + 1, 0.3f, out + 1); check_v(out, Vector3Lerp(av, bv, 0.3f));

    const Matrix left = MatrixMultiply(MatrixScale(2, 3, 4), MatrixRotateXYZ(av));
    const Matrix right = MatrixTranslate(5, 6, 7);
    store_m(ma + 1, left); store_m(mb + 1, right);
    grm_vector3_transform(a + 1, ma + 1, out + 1); check_v(out, Vector3Transform(av, left));
    memset(out, 0xa5, sizeof(out));
    grm_matrix_identity(out + 1); check_m(out, MatrixIdentity());
    grm_matrix_translate(1, 2, 3, out + 1); check_m(out, MatrixTranslate(1, 2, 3));
    grm_matrix_scale(2, 3, 4, out + 1); check_m(out, MatrixScale(2, 3, 4));
    grm_matrix_rotate_xyz(a + 1, out + 1); check_m(out, MatrixRotateXYZ(av));
    grm_matrix_multiply(ma + 1, mb + 1, out + 1); check_m(out, MatrixMultiply(left, right));
    grm_matrix_invert(ma + 1, out + 1); check_m(out, MatrixInvert(left));
    grm_matrix_perspective(0.95, 1.777777777, 0.1, 1000, out + 1);
    check_m(out, MatrixPerspective(0.95, 1.777777777, 0.1, 1000));
    grm_matrix_ortho(-10, 20, -5, 15, 0.1, 100, out + 1);
    check_m(out, MatrixOrtho(-10, 20, -5, 15, 0.1, 100));
    const float up[3] = {0, 1, 0};
    memcpy(mb + 1, up, sizeof(up));
    grm_matrix_look_at(a + 1, b + 1, mb + 1, out + 1);
    check_m(out, MatrixLookAt(av, bv, (Vector3){0, 1, 0}));

    const Quaternion q1 = QuaternionFromAxisAngle(av, 0.75f), q2 = QuaternionFromAxisAngle(bv, 1.25f);
    const float q1f[4] = {q1.x, q1.y, q1.z, q1.w}, q2f[4] = {q2.x, q2.y, q2.z, q2.w};
    memcpy(qa + 1, q1f, sizeof(q1f)); memcpy(qb + 1, q2f, sizeof(q2f));
    memset(out, 0xa5, sizeof(out));
    grm_quaternion_identity(out + 1); check_q(out, QuaternionIdentity());
    grm_quaternion_normalize(qa + 1, out + 1); check_q(out, QuaternionNormalize(q1));
    grm_quaternion_multiply(qa + 1, qb + 1, out + 1); check_q(out, QuaternionMultiply(q1, q2));
    grm_quaternion_slerp(qa + 1, qb + 1, 0.25f, out + 1); check_q(out, QuaternionSlerp(q1, q2, 0.25f));
    grm_quaternion_from_axis_angle(a + 1, 0.75f, out + 1); check_q(out, q1);
    memset(out, 0xa5, sizeof(out));
    grm_quaternion_to_matrix(qa + 1, out + 1); check_m(out, QuaternionToMatrix(q1));
    const Matrix rotation = QuaternionToMatrix(q2);
    store_m(ma + 1, rotation);
    memset(out, 0xa5, sizeof(out));
    grm_quaternion_from_matrix(ma + 1, out + 1); check_q(out, QuaternionFromMatrix(rotation));
    puts("raymath adapter passed (25 operations, unaligned inputs and output canaries)");
    return 0;
}
