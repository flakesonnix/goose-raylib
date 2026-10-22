#ifndef GOOSE_RAYLIB_MATH_H
#define GOOSE_RAYLIB_MATH_H

/* Borrowed packed inputs / outputs: Vector3 = 3 floats, Quaternion = 4,
 * Matrix = 16 floats in Goose/raylib declaration order. Never retain these
 * pointers or cast them to native struct pointers (they may be unaligned). */
void grm_vector3_add(const void *a, const void *b, void *out);
void grm_vector3_subtract(const void *a, const void *b, void *out);
void grm_vector3_scale(const void *v, float scale, void *out);
float grm_vector3_dot(const void *a, const void *b);
float grm_vector3_length(const void *v);
void grm_vector3_cross(const void *a, const void *b, void *out);
void grm_vector3_normalize(const void *v, void *out);
void grm_vector3_transform(const void *v, const void *m, void *out);
void grm_vector3_lerp(const void *a, const void *b, float amount, void *out);

void grm_matrix_identity(void *out);
void grm_matrix_translate(float x, float y, float z, void *out);
void grm_matrix_scale(float x, float y, float z, void *out);
void grm_matrix_rotate_xyz(const void *angles, void *out);
void grm_matrix_multiply(const void *left, const void *right, void *out);
void grm_matrix_invert(const void *m, void *out);
void grm_matrix_perspective(double fovy, double aspect, double near_plane, double far_plane, void *out);
void grm_matrix_ortho(double left, double right, double bottom, double top, double near_plane, double far_plane, void *out);
void grm_matrix_look_at(const void *eye, const void *target, const void *up, void *out);

void grm_quaternion_identity(void *out);
void grm_quaternion_normalize(const void *q, void *out);
void grm_quaternion_multiply(const void *a, const void *b, void *out);
void grm_quaternion_slerp(const void *a, const void *b, float amount, void *out);
void grm_quaternion_from_axis_angle(const void *axis, float angle, void *out);
void grm_quaternion_to_matrix(const void *q, void *out);
void grm_quaternion_from_matrix(const void *m, void *out);

#endif
