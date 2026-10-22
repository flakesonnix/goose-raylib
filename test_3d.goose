// test_3d.goose — Test: 3D API (Phase D)
// Headless tests: packed value layouts and real camera computations.
// Rendering is tested separately by tests/graphics_3d.goose.
//
// Build:
//   goose build test_3d.goose && ./test_3d

import raylib from ".";

fn main() {
    // Camera projection constants
    assert(raylib::CAMERA_PERSPECTIVE == 0);
    assert(raylib::CAMERA_ORTHOGRAPHIC == 1);

    // Vector3 struct
    let v = raylib::Vector3 { 1.0, 2.0, 3.0 };
    assert(v.x == 1.0 && v.y == 2.0 && v.z == 3.0);
    v.x = 9.9;
    assert(v.x == 9.9);

    // Ray struct
    let r = raylib::Ray {
        position: raylib::Vector3 { 0.0, 0.0, 0.0 },
        direction: raylib::Vector3 { 1.0, 0.0, 0.0 },
    };
    assert(r.position.x == 0.0 && r.direction.x == 1.0);

    // Camera3D struct
    let cam = raylib::Camera3D {
        position: raylib::Vector3 { 4.0, 4.0, 4.0 },
        target:   raylib::Vector3 { 0.0, 0.0, 0.0 },
        up:       raylib::Vector3 { 0.0, 1.0, 0.0 },
        fovy: 45.0,
        projection: raylib::CAMERA_PERSPECTIVE,
    };
    assert(cam.position.x == 4.0 && cam.position.y == 4.0 && cam.position.z == 4.0);
    assert(cam.target.x == 0.0 && cam.target.y == 0.0 && cam.target.z == 0.0);
    assert(cam.up.x == 0.0 && cam.up.y == 1.0 && cam.up.z == 0.0);
    assert(cam.fovy == 45.0);
    assert(cam.projection == raylib::CAMERA_PERSPECTIVE);

    // Matrix struct (16 floats)
    let m = raylib::Matrix {
        m0: 1.0, m4: 0.0, m8: 0.0, m12: 0.0,
        m1: 0.0, m5: 1.0, m9: 0.0, m13: 0.0,
        m2: 0.0, m6: 0.0, m10: 1.0, m14: 0.0,
        m3: 0.0, m7: 0.0, m11: 0.0, m15: 1.0,
    };
    assert(m.m0 == 1.0 && m.m5 == 1.0 && m.m10 == 1.0 && m.m15 == 1.0);

    assert(bytes_of([v]).len == 12);
    assert(bytes_of([r]).len == 24);
    assert(bytes_of([cam]).len == 44);
    assert(bytes_of([m]).len == 64);
    assert(raylib::color_rgba(raylib::Color { 1, 2, 3, 4 }) == 0x01020304);

    // This exercises the C adapter, not a dummy signature-only call.
    var camera = raylib::Camera3D {
        position: raylib::Vector3 { 0.0, 0.0, 5.0 },
        target:   raylib::Vector3 { 0.0, 0.0, 0.0 },
        up:       raylib::Vector3 { 0.0, 1.0, 0.0 },
        fovy: 45.0,
        projection: raylib::CAMERA_PERSPECTIVE,
    };
    let view = raylib::get_camera_matrix(camera);
    assert(view.m0 == 1 && view.m5 == 1 && view.m10 == 1 && view.m15 == 1);
    assert(view.m14 == -5);
    raylib::update_camera_pro(camera, raylib::Vector3 { 0, 1, 0 }, raylib::Vector3 { .. }, 0);
    assert(camera.position.x == 1 && camera.target.x == 1);
    assert(camera.position.z == 5 && camera.target.z == 0);
    assert(camera.fovy == 45 && camera.projection == raylib::CAMERA_PERSPECTIVE);
    let moved = raylib::get_camera_matrix(camera);
    assert(moved.m12 == -1 && moved.m14 == -5);

    print("test_3d passed");
}
