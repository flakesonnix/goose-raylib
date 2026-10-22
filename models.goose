// Managed generated model: no external assets required. Auto-exit at 120 frames.
import raylib from ".";

fn main() {
    raylib::init_window(800, 450, "goose-raylib managed models");
    assert(raylib::is_window_ready());
    raylib::set_target_fps(60);
    let model = raylib::gen_model_cube(2, 2, 2);
    assert(raylib::is_model_valid(model));
    let camera = raylib::Camera3D {
        position: raylib::Vector3 { 4, 4, 4 }, target: raylib::Vector3 { .. },
        up: raylib::Vector3 { 0, 1, 0 }, fovy: 45, projection: raylib::CAMERA_PERSPECTIVE,
    };
    var frames: i32 = 0;
    while !raylib::window_should_close() && frames < 120 {
        let angle: f32 = frames * 1.0;  // DrawModelEx takes degrees
        raylib::begin_drawing();
        raylib::clear_background(raylib::RAYWHITE);
        raylib::begin_mode_3d(camera);
        raylib::draw_grid(20, 1);
        assert(raylib::draw_model_ex(model, raylib::Vector3 { .. }, raylib::Vector3 { 0, 1, 0 },
                                     angle, raylib::Vector3 { 1, 1, 1 }, raylib::BLUE));
        assert(raylib::draw_model_wires_ex(model, raylib::Vector3 { .. }, raylib::Vector3 { 0, 1, 0 },
                                           angle, raylib::Vector3 { 1.01, 1.01, 1.01 }, raylib::BLACK));
        raylib::end_mode_3d();
        raylib::draw_text("Managed model: explicit unload, rotation in degrees", 20, 20, 20, raylib::BLACK);
        raylib::end_drawing();
        frames += 1;
    }
    assert(raylib::unload_model(model));
    raylib::close_window();
}
