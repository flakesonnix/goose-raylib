// cube3d.goose — goose-raylib: 3D cube (Phase D)
// Orbits a colored cube with raymath quaternion/matrix transforms.
// Exits automatically after 120 frames.
//
// Build:
//   goose build cube3d.goose && ./cube3d

import raylib from ".";
import raylib.raymath;

fn main() {
    raylib::init_window(raylib::SCREEN_WIDTH, raylib::SCREEN_HEIGHT, "goose-raylib 3D cube");
    assert(raylib::is_window_ready());

    raylib::set_target_fps(raylib::TARGET_FPS);

    // 3D camera
    let camera = raylib::Camera3D {
        position: raylib::Vector3 { 4.0, 4.0, 4.0 },
        target:   raylib::Vector3 { 0.0, 0.0, 0.0 },
        up:       raylib::Vector3 { 0.0, 1.0, 0.0 },
        fovy: 45.0,
        projection: raylib::CAMERA_PERSPECTIVE,
    };

    var frames: i32 = 0;
    while !raylib::window_should_close() && frames < 120 {
        raylib::begin_drawing();
        raylib::clear_background(raylib::RAYWHITE);

        raylib::begin_mode_3d(camera);

        // Grid on the floor
        raylib::draw_grid(20, 1.0);

        // Quaternion rotation of a point around the Y axis (radians).
        let angle: f32 = frames * 0.03;
        let orbit = raymath::quaternion_from_axis_angle(raylib::Vector3 { 0, 1, 0 }, angle);
        let cube_pos = raymath::vector3_transform(
            raylib::Vector3 { 2, 1, 0 }, raymath::quaternion_to_matrix(orbit),
        );
        let cube_size = raylib::Vector3 { 1.0, 1.0, 1.0 };
        raylib::draw_cube_v(cube_pos, cube_size, raylib::RED);

        // Wireframe cube at origin
        raylib::draw_cube_wires_v(
            raylib::Vector3 { 0.0, 0.0, 0.0 },
            raylib::Vector3 { 2.0, 2.0, 2.0 },
            raylib::BLUE,
        );

        // Sphere
        raylib::draw_sphere_v(
            raylib::Vector3 { 3.0, 1.0, 0.0 },
            0.8,
            raylib::GREEN,
        );

        raylib::end_mode_3d();

        // UI text
        raylib::draw_text("goose-raylib 3D demo", 20, 20, 20, raylib::BLACK);
        raylib::draw_text("Quaternion orbit + grid", 20, 50, 20, raylib::GRAY);
        raylib::draw_fps(10, 10);

        raylib::end_drawing();
        frames = frames + 1;
    }

    raylib::close_window();
}
