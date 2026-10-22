#include "raylib_3d.h"
#include <raylib.h>
#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <string.h>

static void check_camera(int projection) {
    /* Deliberately unaligned buffers, with canaries around all outputs. */
    unsigned char camera[46], matrix[66];
    memset(camera, 0xa5, sizeof(camera));
    memset(matrix, 0xa5, sizeof(matrix));
    const float fields[10] = { 3, 2, 5, 0, 1, 0, 0, 1, 0, 45 };
    int32_t p = projection;
    memcpy(camera + 1, fields, sizeof(fields));
    memcpy(camera + 41, &p, sizeof(p));
    Camera3D native = { {3, 2, 5}, {0, 1, 0}, {0, 1, 0}, 45, projection };
    Matrix expected = GetCameraMatrix(native);
    float expected_fields[16] = {
        expected.m0, expected.m4, expected.m8, expected.m12,
        expected.m1, expected.m5, expected.m9, expected.m13,
        expected.m2, expected.m6, expected.m10, expected.m14,
        expected.m3, expected.m7, expected.m11, expected.m15 };
    grl_get_camera_matrix(camera + 1, matrix + 1);
    float actual[16];
    memcpy(actual, matrix + 1, sizeof(actual));
    for (int i = 0; i < 16; i++) assert(fabsf(actual[i] - expected_fields[i]) < 0.00001f);
    assert(matrix[0] == 0xa5 && matrix[65] == 0xa5);

    grl_update_camera_pro(camera + 1, 0.3f, -0.2f, 0.1f, 2, -1, 0, 0.2f);
    UpdateCameraPro(&native, (Vector3){0.3f, -0.2f, 0.1f}, (Vector3){2, -1, 0}, 0.2f);
    const float moved[10] = { native.position.x, native.position.y, native.position.z,
        native.target.x, native.target.y, native.target.z,
        native.up.x, native.up.y, native.up.z, native.fovy };
    float result[10];
    memcpy(result, camera + 1, sizeof(result));
    for (int i = 0; i < 10; i++) assert(fabsf(result[i] - moved[i]) < 0.00001f);
    memcpy(&p, camera + 41, sizeof(p));
    assert(p == projection);
    assert(camera[0] == 0xa5 && camera[45] == 0xa5);
}

int main(void) {
    check_camera(CAMERA_PERSPECTIVE);
    check_camera(CAMERA_ORTHOGRAPHIC);
    puts("3d adapter passed (unaligned camera/matrix, both projections)");
    return 0;
}
