// test_input.goose — Test: keyboard & mouse API (constants + signatures)
// Checks input constants and that is_* / get_* functions exist.
// Real mouse/keyboard input requires a window with a display; this test
// covers the API signatures and constants.
//
// Build:
//   goose build test_input.goose && ./test_input

import raylib;

fn main() {
    // key API signatures (calls with dummy values, return bool)
    let _p: bool = raylib::is_key_pressed(raylib::KEY_SPACE);
    let _d: bool = raylib::is_key_down(raylib::KEY_A);
    let _r: bool = raylib::is_key_released(raylib::KEY_ESCAPE);
    let _u: bool = raylib::is_key_up(raylib::KEY_F);

    // mouse API
    let _mbp: bool = raylib::is_mouse_button_pressed(raylib::MOUSE_LEFT);
    let _mbd: bool = raylib::is_mouse_button_down(raylib::MOUSE_RIGHT);
    let _mbr: bool = raylib::is_mouse_button_released(raylib::MOUSE_MIDDLE);
    let _mbu: bool = raylib::is_mouse_button_up(raylib::MOUSE_LEFT);

    // mouse position (Vector2)
    let mpos = raylib::get_mouse_position();
    let _mx: f32 = mpos.x;
    let _my: f32 = mpos.y;

    // mouse X / mouse Y (i32)
    let _x: i32 = raylib::get_mouse_x();
    let _y: i32 = raylib::get_mouse_y();

    // cursor
    raylib::hide_cursor();
    let _hidden: bool = raylib::is_cursor_hidden();
    raylib::show_cursor();

    assert(_p == _p);   // dummy, to avoid unused variable warnings
    assert(_d == _d);
    assert(_r == _r);
    assert(_u == _u);
    assert(_mbp == _mbp);
    assert(_mbd == _mbd);
    assert(_mbr == _mbr);
    assert(_mbu == _mbu);
    assert(_mx == _mx);
    assert(_my == _my);
    assert(_x == _x);
    assert(_y == _y);
    assert(_hidden == _hidden);

    print("test_input passed");
}
