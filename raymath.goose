// Public module: import raylib.raymath; (declare the raylib package in the root).
// Actual raymath.h functions, exposed through a scalar / borrowed-pointer ABI.
// Angles are radians, unlike raylib's degree-based Camera3D.fovy.
namespace raymath;
import raylib;

type Vector3 = raylib::Vector3;
type Matrix = raylib::Matrix;
struct Quaternion { x: f32, y: f32, z: f32, w: f32 }

const PI: f32 = 3.14159265358979323846;
const DEG2RAD: f32 = PI / 180.0;
const RAD2DEG: f32 = 180.0 / PI;

extern fn grm_vector3_add(a: const Vector3&, b: const Vector3&, out: Vector3&);
extern fn grm_vector3_subtract(a: const Vector3&, b: const Vector3&, out: Vector3&);
extern fn grm_vector3_scale(v: const Vector3&, scale: f32, out: Vector3&);
extern fn grm_vector3_dot(a: const Vector3&, b: const Vector3&) -> f32;
extern fn grm_vector3_length(v: const Vector3&) -> f32;
extern fn grm_vector3_cross(a: const Vector3&, b: const Vector3&, out: Vector3&);
extern fn grm_vector3_normalize(v: const Vector3&, out: Vector3&);
extern fn grm_vector3_transform(v: const Vector3&, m: const Matrix&, out: Vector3&);
extern fn grm_vector3_lerp(a: const Vector3&, b: const Vector3&, amount: f32, out: Vector3&);
extern fn grm_matrix_identity(out: Matrix&);
extern fn grm_matrix_translate(x: f32, y: f32, z: f32, out: Matrix&);
extern fn grm_matrix_scale(x: f32, y: f32, z: f32, out: Matrix&);
extern fn grm_matrix_rotate_xyz(angles: const Vector3&, out: Matrix&);
extern fn grm_matrix_multiply(left: const Matrix&, right: const Matrix&, out: Matrix&);
extern fn grm_matrix_invert(m: const Matrix&, out: Matrix&);
extern fn grm_matrix_perspective(fovy: f64, aspect: f64, near_plane: f64, far_plane: f64, out: Matrix&);
extern fn grm_matrix_ortho(left: f64, right: f64, bottom: f64, top: f64, near_plane: f64, far_plane: f64, out: Matrix&);
extern fn grm_matrix_look_at(eye: const Vector3&, target: const Vector3&, up: const Vector3&, out: Matrix&);
extern fn grm_quaternion_identity(out: Quaternion&);
extern fn grm_quaternion_normalize(q: const Quaternion&, out: Quaternion&);
extern fn grm_quaternion_multiply(a: const Quaternion&, b: const Quaternion&, out: Quaternion&);
extern fn grm_quaternion_slerp(a: const Quaternion&, b: const Quaternion&, amount: f32, out: Quaternion&);
extern fn grm_quaternion_from_axis_angle(axis: const Vector3&, angle: f32, out: Quaternion&);
extern fn grm_quaternion_to_matrix(q: const Quaternion&, out: Matrix&);
extern fn grm_quaternion_from_matrix(m: const Matrix&, out: Quaternion&);

fn vector3_add(a: Vector3, b: Vector3) -> Vector3 {
    var out = Vector3 { .. }; grm_vector3_add(a, b, out); return out;
}
fn vector3_subtract(a: Vector3, b: Vector3) -> Vector3 {
    var out = Vector3 { .. }; grm_vector3_subtract(a, b, out); return out;
}
fn vector3_scale(v: Vector3, scale: f32) -> Vector3 {
    var out = Vector3 { .. }; grm_vector3_scale(v, scale, out); return out;
}
fn vector3_dot(a: Vector3, b: Vector3) -> f32 { grm_vector3_dot(a, b) }
fn vector3_length(v: Vector3) -> f32 { grm_vector3_length(v) }
fn vector3_cross(a: Vector3, b: Vector3) -> Vector3 {
    var out = Vector3 { .. }; grm_vector3_cross(a, b, out); return out;
}
fn vector3_normalize(v: Vector3) -> Vector3 {
    var out = Vector3 { .. }; grm_vector3_normalize(v, out); return out;
}
fn vector3_transform(v: Vector3, matrix: Matrix) -> Vector3 {
    var out = Vector3 { .. }; grm_vector3_transform(v, matrix, out); return out;
}
fn vector3_lerp(a: Vector3, b: Vector3, amount: f32) -> Vector3 {
    var out = Vector3 { .. }; grm_vector3_lerp(a, b, amount, out); return out;
}

fn matrix_identity() -> Matrix {
    var out = Matrix { .. }; grm_matrix_identity(out); return out;
}
fn matrix_translate(x: f32, y: f32, z: f32) -> Matrix {
    var out = Matrix { .. }; grm_matrix_translate(x, y, z, out); return out;
}
fn matrix_scale(x: f32, y: f32, z: f32) -> Matrix {
    var out = Matrix { .. }; grm_matrix_scale(x, y, z, out); return out;
}
fn matrix_rotate_xyz(angles: Vector3) -> Matrix {
    var out = Matrix { .. }; grm_matrix_rotate_xyz(angles, out); return out;
}
fn matrix_multiply(left: Matrix, right: Matrix) -> Matrix {
    var out = Matrix { .. }; grm_matrix_multiply(left, right, out); return out;
}
fn matrix_invert(matrix: Matrix) -> Matrix {
    var out = Matrix { .. }; grm_matrix_invert(matrix, out); return out;
}
fn matrix_perspective(fovy: f64, aspect: f64, near_plane: f64, far_plane: f64) -> Matrix {
    var out = Matrix { .. }; grm_matrix_perspective(fovy, aspect, near_plane, far_plane, out); return out;
}
fn matrix_ortho(left: f64, right: f64, bottom: f64, top: f64, near_plane: f64, far_plane: f64) -> Matrix {
    var out = Matrix { .. }; grm_matrix_ortho(left, right, bottom, top, near_plane, far_plane, out); return out;
}
fn matrix_look_at(eye: Vector3, target: Vector3, up: Vector3) -> Matrix {
    var out = Matrix { .. }; grm_matrix_look_at(eye, target, up, out); return out;
}

fn quaternion_identity() -> Quaternion {
    var out = Quaternion { .. }; grm_quaternion_identity(out); return out;
}
fn quaternion_normalize(q: Quaternion) -> Quaternion {
    var out = Quaternion { .. }; grm_quaternion_normalize(q, out); return out;
}
fn quaternion_multiply(a: Quaternion, b: Quaternion) -> Quaternion {
    var out = Quaternion { .. }; grm_quaternion_multiply(a, b, out); return out;
}
fn quaternion_slerp(a: Quaternion, b: Quaternion, amount: f32) -> Quaternion {
    var out = Quaternion { .. }; grm_quaternion_slerp(a, b, amount, out); return out;
}
fn quaternion_from_axis_angle(axis: Vector3, angle: f32) -> Quaternion {
    var out = Quaternion { .. }; grm_quaternion_from_axis_angle(axis, angle, out); return out;
}
fn quaternion_to_matrix(q: Quaternion) -> Matrix {
    var out = Matrix { .. }; grm_quaternion_to_matrix(q, out); return out;
}
fn quaternion_from_matrix(matrix: Matrix) -> Quaternion {
    var out = Quaternion { .. }; grm_quaternion_from_matrix(matrix, out); return out;
}
