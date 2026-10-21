// test_window.goose — Smoke test: window API
// Checks window constants and that extern declarations exist.
// Opening a real window requires a display (Xvfb); this test typechecks
// the API and runs without a window as long as no window_* function that
// needs a display is called.
//
// Build:
//   goose build test_window.goose && ./test_window

import raylib;

fn main() {
    // window constants
    assert(raylib::SCREEN_WIDTH == 800);
    assert(raylib::SCREEN_HEIGHT == 450);
    assert(raylib::TARGET_FPS == 60);

    // key constants (samples)
    assert(raylib::KEY_ESCAPE == 256);
    assert(raylib::KEY_SPACE == 32);
    assert(raylib::KEY_F == 70);
    assert(raylib::KEY_A == 65);
    assert(raylib::KEY_Z == 90);
    assert(raylib::KEY_F1 == 290);
    assert(raylib::KEY_F12 == 301);
    assert(raylib::KEY_LEFT == 263);
    assert(raylib::KEY_RIGHT == 262);
    assert(raylib::KEY_UP == 265);
    assert(raylib::KEY_DOWN == 264);

    // mouse buttons
    assert(raylib::MOUSE_LEFT == 0);
    assert(raylib::MOUSE_RIGHT == 1);
    assert(raylib::MOUSE_MIDDLE == 2);

    print("test_window passed");
}
