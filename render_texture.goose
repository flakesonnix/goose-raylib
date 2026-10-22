// Native off-screen 3D, composited into a window. No assets; 120 frames.
import raylib from ".";
fn main() {
    raylib::init_window(800, 450, "goose-raylib render texture");
    assert(raylib::is_window_ready());
    raylib::set_target_fps(60);
    let target = raylib::load_render_texture(320, 180);
    assert(raylib::is_render_texture_valid(target));
    let camera = raylib::Camera3D {
        position: raylib::Vector3 { 4, 4, 4 }, target: raylib::Vector3 { .. },
        up: raylib::Vector3 { 0, 1, 0 }, fovy: 45, projection: raylib::CAMERA_PERSPECTIVE,
    };
    var frames: i32 = 0;
    while !raylib::window_should_close() && frames < 120 {
        raylib::begin_drawing();
        assert(raylib::begin_texture_mode(target));
        raylib::clear_background(raylib::RAYWHITE);
        raylib::begin_mode_3d(camera);
        raylib::draw_grid(10, 1);
        raylib::draw_cube(0, 0.5, 0, 1, 1, 1, raylib::RED);
        raylib::end_mode_3d();
        raylib::draw_text("Off-screen 3D", 10, 10, 16, raylib::BLACK);
        assert(raylib::end_texture_mode());
        raylib::clear_background(raylib::DARKGRAY);
        assert(raylib::draw_render_texture_pro(target, raylib::Rectangle { 0, 0, 320, -180 },
            raylib::Rectangle { 80, 60, 640, 360 }, raylib::Vector2 { .. }, 0, raylib::WHITE));
        raylib::draw_text("320x180 render texture, displayed at 2x", 80, 20, 20, raylib::WHITE);
        raylib::end_drawing();
        frames += 1;
    }
    assert(raylib::unload_render_texture(target));
    raylib::close_window();
}
