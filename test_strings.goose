// test_strings.goose — Test: string conversion (Goose slice → C string)
// Checks that text functions can be called with Goose string literals.
// The actual C adapter (rl_draw_text etc.) converts the slice into a
// null-terminated C string.
//
// Build:
//   goose build test_strings.goose && ./test_strings

import raylib;

fn main() {
    // string literals are const u8[:] and can be passed directly to
    // draw_text (via the C adapter rl_draw_text).
    raylib::draw_text("Hello from goose-raylib", 10, 10, 20, raylib::BLACK);
    raylib::draw_text("String conversion works", 10, 40, 20, raylib::RED);

    // measure_text returns a width (i32)
    let w = raylib::measure_text("test", 20);
    assert(w >= 0);

    // set_window_title takes a string
    raylib::set_window_title("goose-raylib test");

    print("test_strings passed");
}
