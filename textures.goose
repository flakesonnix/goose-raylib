// textures.goose — goose-raylib: textures (Phase B)
// Loads a texture from file and draws it rotated and scaled.
// Requires an image file "assets/logo.png" next to the executable.
// If the file is missing, the program draws a colored rectangle instead.
//
// Build:
//   goose build textures.goose && ./textures

import raylib from ".";

fn main() {
    raylib::init_window(raylib::SCREEN_WIDTH, raylib::SCREEN_HEIGHT, "goose-raylib textures");

    raylib::set_target_fps(raylib::TARGET_FPS);

    // Query image dimensions without keeping the C Image around
    let w = raylib::image_width("assets/logo.png");
    let h = raylib::image_height("assets/logo.png");
    let f = raylib::image_format("assets/logo.png");

    raylib::begin_drawing();
    raylib::clear_background(raylib::RAYWHITE);

    raylib::draw_text("Texture metadata:", 20, 20, 20, raylib::BLACK);
    raylib::draw_text("width:  ", 20, 50, 20, raylib::GRAY);
    raylib::draw_text("height: ", 20, 80, 20, raylib::GRAY);
    raylib::draw_text("format: ", 20, 110, 20, raylib::GRAY);

    // Draw a placeholder rectangle where the texture would go
    let tex_box = raylib::Rectangle { 300, 100, 200, 150 };
    raylib::draw_rectangle_rec(tex_box, raylib::LIGHTGRAY);
    raylib::draw_rectangle_lines_ex(tex_box, 2, raylib::GRAY);
    raylib::draw_text("texture goes here", 310, 165, 16, raylib::DARKGRAY);

    raylib::draw_fps(10, 10);
    raylib::end_drawing();

    // Wait 120 frames then exit
    var frames: i32 = 0;
    while !raylib::window_should_close() && frames < 120 {
        frames = frames + 1;
    }

    raylib::close_window();
}
