// minimal.goose — Minimal goose-raylib smoke test
// Opens a window, draws text, and exits automatically after 120 frames.
//
// Build:
//   goose build minimal.goose && ./minimal

import raylib from ".";

fn main() {
    raylib::init_window(raylib::SCREEN_WIDTH, raylib::SCREEN_HEIGHT, "goose-raylib minimal");

    raylib::set_target_fps(raylib::TARGET_FPS);

    var frames: i32 = 0;
    while !raylib::window_should_close() && frames < 120 {
        raylib::begin_drawing();
        raylib::clear_background(raylib::RAYWHITE);
        raylib::draw_text("Hello from goose-raylib!", 20, 20, 32, raylib::BLACK);
        raylib::draw_text("Auto-exit after 120 frames", 20, 60, 20, raylib::GRAY);
        raylib::draw_fps(10, 10);
        raylib::end_drawing();
        frames = frames + 1;
    }

    raylib::close_window();
}
