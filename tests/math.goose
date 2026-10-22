// Real headless raymath calls across the generated Goose/native ABI.
import raylib from "..";
import raylib.raymath;

fn near(actual: f32, expected: f32) {
    assert(actual > expected - 0.0001 && actual < expected + 0.0001);
}
fn vec(actual: raylib::Vector3, x: f32, y: f32, z: f32) {
    near(actual.x, x); near(actual.y, y); near(actual.z, z);
}

fn main() {
    let a = raylib::Vector3 { 1, 2, 3 };
    let b = raymath::Vector3 { 4, 5, 6 };  // alias, not a duplicate nominal type
    vec(raymath::vector3_add(a, b), 5, 7, 9);
    vec(raymath::vector3_subtract(a, b), -3, -3, -3);
    vec(raymath::vector3_scale(a, -2), -2, -4, -6);
    near(raymath::vector3_dot(a, b), 32);
    near(raymath::vector3_length(raylib::Vector3 { 3, 4, 0 }), 5);
    vec(raymath::vector3_cross(a, b), -3, 6, -3);
    vec(raymath::vector3_normalize(raylib::Vector3 { 0, 3, 4 }), 0, 0.6, 0.8);
    vec(raymath::vector3_normalize(raylib::Vector3 { .. }), 0, 0, 0);
    vec(raymath::vector3_lerp(a, b, 0.5), 2.5, 3.5, 4.5);

    let identity = raymath::matrix_identity();
    assert(identity.m0 == 1 && identity.m5 == 1 && identity.m10 == 1 && identity.m15 == 1);
    vec(raymath::vector3_transform(a, identity), 1, 2, 3);
    let translation = raymath::matrix_translate(1, 2, 3);
    let scale = raymath::matrix_scale(2, 3, 4);
    // Non-commuting transforms: preserve raymath's MatrixMultiply order.
    let st = raymath::matrix_multiply(scale, translation);
    let ts = raymath::matrix_multiply(translation, scale);
    vec(raymath::vector3_transform(raylib::Vector3 { 1, 1, 1 }, st), 3, 5, 7);
    vec(raymath::vector3_transform(raylib::Vector3 { 1, 1, 1 }, ts), 4, 9, 16);
    let inverted = raymath::matrix_invert(st);
    vec(raymath::vector3_transform(raymath::vector3_transform(a, st), inverted), 1, 2, 3);
    let rotated = raymath::matrix_rotate_xyz(raylib::Vector3 { 0, 0, raymath::PI / 2 });
    vec(raymath::vector3_transform(raylib::Vector3 { 1, 0, 0 }, rotated), 0, 1, 0);

    let view = raymath::matrix_look_at(raylib::Vector3 { 0, 0, 5 }, raylib::Vector3 { .. }, raylib::Vector3 { 0, 1, 0 });
    near(view.m14, -5);
    let projection = raymath::matrix_perspective(1.5707963267948966, 1, 1, 10);
    near(projection.m0, 1); near(projection.m5, 1); near(projection.m11, -1);
    let ortho = raymath::matrix_ortho(-2, 2, -4, 4, 1, 11);
    near(ortho.m0, 0.5); near(ortho.m5, 0.25); near(ortho.m10, -0.2); near(ortho.m15, 1);

    let qi = raymath::quaternion_identity();
    assert(qi.x == 0 && qi.y == 0 && qi.z == 0 && qi.w == 1);
    assert(bytes_of([qi]).len == 16);
    let normalized = raymath::quaternion_normalize(raymath::Quaternion { 0, 0, 0, 2 });
    near(normalized.w, 1);
    let q = raymath::quaternion_from_axis_angle(raylib::Vector3 { 0, 0, 1 }, raymath::PI / 2);
    let qm = raymath::quaternion_to_matrix(q);
    vec(raymath::vector3_transform(raylib::Vector3 { 1, 0, 0 }, qm), 0, 1, 0);
    let orbit = raymath::quaternion_from_axis_angle(raylib::Vector3 { 0, 1, 0 }, raymath::PI / 2);
    vec(raymath::vector3_transform(raylib::Vector3 { 2, 1, 0 }, raymath::quaternion_to_matrix(orbit)), 0, 1, -2);
    let round_trip = raymath::quaternion_from_matrix(qm);
    near(round_trip.z, q.z); near(round_trip.w, q.w);
    let twice = raymath::quaternion_multiply(q, q);
    vec(raymath::vector3_transform(raylib::Vector3 { 1, 0, 0 }, raymath::quaternion_to_matrix(twice)), -1, 0, 0);
    let half = raymath::quaternion_slerp(qi, q, 0.5);
    let half_twice = raymath::quaternion_multiply(half, half);
    near(half_twice.z, q.z); near(half_twice.w, q.w);
    near(raymath::DEG2RAD * 180, raymath::PI);
    near(raymath::RAD2DEG * raymath::PI, 180);

    print("raymath passed (vectors, matrices, quaternion rotation, radians)");
}
