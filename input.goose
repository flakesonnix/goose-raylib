// input.goose — goose-raylib: keyboard & mouse input
// Arrow keys move a rectangle, mouse follows a circle, F = fullscreen,
// ESC quits. Exits automatically after 300 frames.
//
// Build:
//   goose build input.goose && ./input

import raylib;

fn main() {
    raylib::init_window(raylib::SCREEN_WIDTH, raylib::SCREEN_HEIGHT, "goose-raylib input");

    raylib::set_target_fps(raylib::TARGET_FPS);
    raylib::hide_cursor();

    var px: i32 = raylib::SCREEN_WIDTH / 2 - 25;
    var py: i32 = raylib::SCREEN_HEIGHT / 2 - 25;
    const pw: i32 = 50;
    const ph: i32 = 50;
    const pspeed: i32 = 5;

    var cx: i32 = raylib::SCREEN_WIDTH / 2;
    var cy: i32 = raylib::SCREEN_HEIGHT / 2;
    const cr: f32 = 30.0;

    var frames: i32 = 0;
    while !raylib::window_should_close() && frames < 300 {
        if raylib::is_key_down(raylib::KEY_LEFT) { px = px - pspeed; }
        if raylib::is_key_down(raylib::KEY_RIGHT) { px = px + pspeed; }
        if raylib::is_key_down(raylib::KEY_UP) { py = py - pspeed; }
        if raylib::is_key_down(raylib::KEY_DOWN) { py = py + pspeed; }

        if px < 0 { px = 0; }
        if px > raylib::SCREEN_WIDTH - pw { px = raylib::SCREEN_WIDTH - pw; }
        if py < 0 { py = 0; }
        if py > raylib::SCREEN_HEIGHT - ph { py = raylib::SCREEN_HEIGHT - ph; }

        let mpos = raylib::get_mouse_position();
        cx = mpos.x as i32;
        cy = mpos.y as i32;

        if raylib::is_key_pressed(raylib::KEY_F) { raylib::toggle_fullscreen(); }

        raylib::begin_drawing();
        raylib::clear_background(raylib::RAYWHITE);

        let prec = raylib::Rectangle { px, py, pw, ph };
        raylib::draw_rectangle_rec(prec, raylib::ORANGE);
        raylib::draw_rectangle_lines_ex(prec, 2, raylib::RED);

        raylib::draw_circle_v(raylib::Vector2 { cx, cy }, cr, raylib::BLUE);
        raylib::draw_circle_lines(cx, cy, cr, raylib::DARKBLUE);

        raylib::draw_text("Arrow keys: move | F: fullscreen | ESC: quit",
                          10, raylib::SCREEN_HEIGHT - 30, 20, raylib::GRAY);
        raylib::draw_fps(10, 10);

        raylib::end_drawing();
        frames = frames + 1;

        if raylib::is_key_pressed(raylib::KEY_ESCAPE) { break; }
    }

    raylib::show_cursor();
    raylib::close_window();
}
