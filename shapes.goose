// shapes.goose — goose-raylib: shapes, lines, circles, rectangles
// Draws various 2D primitives and exits automatically after 180 frames.
//
// Build:
//   goose build shapes.goose && ./shapes

import raylib from ".";

fn main() {
    raylib::init_window(raylib::SCREEN_WIDTH, raylib::SCREEN_HEIGHT, "goose-raylib shapes");

    raylib::set_target_fps(raylib::TARGET_FPS);

    var frames: i32 = 0;
    while !raylib::window_should_close() && frames < 180 {
        raylib::begin_drawing();
        raylib::clear_background(raylib::RAYWHITE);

        // lines
        raylib::draw_line(50, 50, 750, 50, raylib::RED);
        raylib::draw_line(50, 80, 750, 80, raylib::GREEN);
        raylib::draw_line(50, 110, 750, 110, raylib::BLUE);

        // rectangles (filled + outlined)
        raylib::draw_rectangle(100, 150, 120, 80, raylib::ORANGE);
        let box = raylib::Rectangle { 300, 150, 120, 80 };
        raylib::draw_rectangle_rec(box, raylib::PURPLE);
        raylib::draw_rectangle_lines(550, 150, 120, 80, raylib::BLUE);
        let box2 = raylib::Rectangle { 550, 150, 120, 80 };
        raylib::draw_rectangle_lines_ex(box2, 4, raylib::DARKBLUE);

        // circles (filled + outline)
        raylib::draw_circle(150, 300, 40, raylib::GREEN);
        raylib::draw_circle_v(raylib::Vector2 { 350, 300 }, 40, raylib::BLUE);
        raylib::draw_circle_lines(550, 300, 40, raylib::RED);

        // triangle
        raylib::draw_triangle(
            raylib::Vector2 { 700, 260 },
            raylib::Vector2 { 740, 340 },
            raylib::Vector2 { 660, 340 },
            raylib::YELLOW,
        );

        // text
        raylib::draw_text("goose-raylib shapes demo", 20, 390, 24, raylib::BLACK);
        raylib::draw_fps(10, 10);

        raylib::end_drawing();
        frames = frames + 1;
    }

    raylib::close_window();
}
