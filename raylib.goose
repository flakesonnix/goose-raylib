// raylib.goose — Goose bindings for raylib (subset, Phase A)
// namespace raylib  →  calls as raylib::init_window(...), raylib::draw_text(...)
//
// Binds the raylib C-API via extern fn. raylib remains the native backend;
// only a small C adapter (src/raylib_adapter.c) bridges Goose u8[:] slices
// to null-terminated C strings.
// To build/run, libraylib is required (see flake.nix devShell).
//
// Phase A: window, main loop, background, shapes, lines, circles, text,
//          keyboard/mouse, FPS.
// See docs/API_STATUS.md for implementation status.

namespace raylib;

// ============================================================================
// Constants — screen size & FPS
// ============================================================================

const SCREEN_WIDTH: i32 = 800;
const SCREEN_HEIGHT: i32 = 450;
const TARGET_FPS: i32 = 60;

// ============================================================================
// Constants — keys (raylib scancodes)
// ============================================================================

const KEY_SPACE: i32 = 32;
const KEY_ESCAPE: i32 = 256;
const KEY_ENTER: i32 = 257;
const KEY_TAB: i32 = 258;
const KEY_BACKSPACE: i32 = 259;
const KEY_INSERT: i32 = 260;
const KEY_DELETE: i32 = 261;
const KEY_RIGHT: i32 = 262;
const KEY_LEFT: i32 = 263;
const KEY_DOWN: i32 = 264;
const KEY_UP: i32 = 265;
const KEY_PAGE_UP: i32 = 266;
const KEY_PAGE_DOWN: i32 = 267;
const KEY_HOME: i32 = 268;
const KEY_END: i32 = 269;
const KEY_CAPS_LOCK: i32 = 280;
const KEY_SCROLL_LOCK: i32 = 281;
const KEY_NUM_LOCK: i32 = 282;
const KEY_PRINT_SCREEN: i32 = 283;
const KEY_PAUSE: i32 = 284;
const KEY_F1: i32 = 290;
const KEY_F2: i32 = 291;
const KEY_F3: i32 = 292;
const KEY_F4: i32 = 293;
const KEY_F5: i32 = 294;
const KEY_F6: i32 = 295;
const KEY_F7: i32 = 296;
const KEY_F8: i32 = 297;
const KEY_F9: i32 = 298;
const KEY_F10: i32 = 299;
const KEY_F11: i32 = 300;
const KEY_F12: i32 = 301;
const KEY_LEFT_SHIFT: i32 = 340;
const KEY_LEFT_CONTROL: i32 = 341;
const KEY_LEFT_ALT: i32 = 342;
const KEY_RIGHT_SHIFT: i32 = 344;
const KEY_RIGHT_CONTROL: i32 = 345;
const KEY_RIGHT_ALT: i32 = 346;
const KEY_KB_MENU: i32 = 348;

const KEY_ZERO: i32 = 48;
const KEY_ONE: i32 = 49;
const KEY_TWO: i32 = 50;
const KEY_THREE: i32 = 51;
const KEY_FOUR: i32 = 52;
const KEY_FIVE: i32 = 53;
const KEY_SIX: i32 = 54;
const KEY_SEVEN: i32 = 55;
const KEY_EIGHT: i32 = 56;
const KEY_NINE: i32 = 57;

const KEY_A: i32 = 65;
const KEY_B: i32 = 66;
const KEY_C: i32 = 67;
const KEY_D: i32 = 68;
const KEY_E: i32 = 69;
const KEY_F: i32 = 70;
const KEY_G: i32 = 71;
const KEY_H: i32 = 72;
const KEY_I: i32 = 73;
const KEY_J: i32 = 74;
const KEY_K: i32 = 75;
const KEY_L: i32 = 76;
const KEY_M: i32 = 77;
const KEY_N: i32 = 78;
const KEY_O: i32 = 79;
const KEY_P: i32 = 80;
const KEY_Q: i32 = 81;
const KEY_R: i32 = 82;
const KEY_S: i32 = 83;
const KEY_T: i32 = 84;
const KEY_U: i32 = 85;
const KEY_V: i32 = 86;
const KEY_W: i32 = 87;
const KEY_X: i32 = 88;
const KEY_Y: i32 = 89;
const KEY_Z: i32 = 90;

// ============================================================================
// Constants — mouse buttons
// ============================================================================

const MOUSE_LEFT: i32 = 0;
const MOUSE_RIGHT: i32 = 1;
const MOUSE_MIDDLE: i32 = 2;
const MOUSE_SIDE_LEFT: i32 = 3;
const MOUSE_SIDE_RIGHT: i32 = 4;

// ============================================================================
// Constants — colors (raylib Color, u8 r/g/b/a)
// ============================================================================

const BLACK = Color { 0, 0, 0, 255 };
const WHITE = Color { 255, 255, 255, 255 };
const RED = Color { 255, 0, 0, 255 };
const GREEN = Color { 0, 255, 0, 255 };
const BLUE = Color { 0, 0, 255, 255 };
const YELLOW = Color { 255, 255, 0, 255 };
const ORANGE = Color { 255, 128, 0, 255 };
const PURPLE = Color { 128, 0, 128, 255 };
const MAGENTA = Color { 255, 0, 255, 255 };
const PINK = Color { 255, 105, 180, 255 };
const GOLD = Color { 255, 215, 0, 255 };
const LIME = Color { 0, 255, 0, 255 };
const RAYWHITE = Color { 245, 245, 245, 255 };
const LIGHTGRAY = Color { 200, 200, 200, 255 };
const GRAY = Color { 130, 130, 130, 255 };
const DARKGRAY = Color { 80, 80, 80, 255 };
const SKYBLUE = Color { 135, 206, 235, 255 };
const DARKBLUE = Color { 0, 0, 139, 255 };
const DARKGREEN = Color { 0, 100, 0, 255 };
const DARKRED = Color { 139, 0, 0, 255 };

// ============================================================================
// Structs — 1:1 to raylib C structs (packed, no padding)
// ============================================================================

struct Vector2 { x: f32, y: f32 }

struct Color { r: u8, g: u8, b: u8, a: u8 }

struct Rectangle { x: f32, y: f32, width: f32, height: f32 }

struct Camera2D { offset: Vector2, target: Vector2, rotation: f32, zoom: f32 }

// ============================================================================
// Window — direct raylib C API (types compatible, no adapter needed)
// ============================================================================

extern fn InitWindow(width: i32, height: i32, title: const u8[:]);
extern fn WindowShouldClose() -> bool;
extern fn CloseWindow();
extern fn SetTargetFPS(fps: i32);
extern fn ToggleFullscreen();
extern fn HideCursor();
extern fn ShowCursor();
extern fn IsCursorHidden() -> bool;

// ============================================================================
// Rendering — direct raylib C API
// ============================================================================

extern fn BeginDrawing();
extern fn EndDrawing();
extern fn ClearBackground(color: Color);
extern fn BeginMode2D(camera: Camera2D);
extern fn EndMode2D();

// ============================================================================
// 2D drawing: pixels & lines
// ============================================================================

extern fn DrawPixel(posX: i32, posY: i32, color: Color);
extern fn DrawLine(startPosX: i32, startPosY: i32, endPosX: i32, endPosY: i32, color: Color);
extern fn DrawLineV(start: Vector2, end: Vector2, color: Color);

// ============================================================================
// 2D drawing: rectangles
// ============================================================================

extern fn DrawRectangle(posX: i32, posY: i32, width: i32, height: i32, color: Color);
extern fn DrawRectangleRec(rec: Rectangle, color: Color);
extern fn DrawRectangleLines(posX: i32, posY: i32, width: i32, height: i32, color: Color);
extern fn DrawRectangleLinesEx(rec: Rectangle, lineThick: i32, color: Color);

// ============================================================================
// 2D drawing: circles
// ============================================================================

extern fn DrawCircle(centerX: i32, centerY: i32, radius: f32, color: Color);
extern fn DrawCircleV(center: Vector2, radius: f32, color: Color);
extern fn DrawCircleLines(centerX: i32, centerY: i32, radius: f32, color: Color);

// ============================================================================
// 2D drawing: triangles
// ============================================================================

extern fn DrawTriangle(v1: Vector2, v2: Vector2, v3: Vector2, color: Color);

// ============================================================================
// 2D drawing: text — via C adapter (Goose slice → null-terminated C string)
// ============================================================================

extern fn rl_draw_text(text: const u8[:], x: i32, y: i32, fontSize: i32, color: Color);
extern fn rl_measure_text(text: const u8[:], fontSize: i32) -> i32;
extern fn rl_set_window_title(title: const u8[:]);

extern fn DrawFPS(posX: i32, posY: i32);

// ============================================================================
// Input: keyboard
// ============================================================================

extern fn IsKeyPressed(key: i32) -> bool;
extern fn IsKeyDown(key: i32) -> bool;
extern fn IsKeyReleased(key: i32) -> bool;
extern fn IsKeyUp(key: i32) -> bool;

// ============================================================================
// Input: mouse
// ============================================================================

extern fn IsMouseButtonPressed(button: i32) -> bool;
extern fn IsMouseButtonDown(button: i32) -> bool;
extern fn IsMouseButtonReleased(button: i32) -> bool;
extern fn IsMouseButtonUp(button: i32) -> bool;
extern fn GetMousePosition() -> Vector2;
extern fn GetMouseX() -> i32;
extern fn GetMouseY() -> i32;

// ============================================================================
// Goose wrappers — snake_case, idiomatic
// ============================================================================

fn init_window(width: i32, height: i32, title: const u8[:]) {
    InitWindow(width, height, title);
}

fn close_window() {
    CloseWindow();
}

fn window_should_close() -> bool {
    return WindowShouldClose();
}

fn set_target_fps(fps: i32) {
    SetTargetFPS(fps);
}

fn set_window_title(title: const u8[:]) {
    rl_set_window_title(title);
}

fn toggle_fullscreen() {
    ToggleFullscreen();
}

fn hide_cursor() {
    HideCursor();
}

fn show_cursor() {
    ShowCursor();
}

fn is_cursor_hidden() -> bool {
    return IsCursorHidden();
}

fn begin_drawing() {
    BeginDrawing();
}

fn end_drawing() {
    EndDrawing();
}

fn clear_background(color: Color) {
    ClearBackground(color);
}

fn begin_mode_2d(camera: Camera2D) {
    BeginMode2D(camera);
}

fn end_mode_2d() {
    EndMode2D();
}

fn draw_pixel(pos_x: i32, pos_y: i32, color: Color) {
    DrawPixel(pos_x, pos_y, color);
}

fn draw_line(start_x: i32, start_y: i32, end_x: i32, end_y: i32, color: Color) {
    DrawLine(start_x, start_y, end_x, end_y, color);
}

fn draw_line_v(start: Vector2, end: Vector2, color: Color) {
    DrawLineV(start, end, color);
}

fn draw_rectangle(pos_x: i32, pos_y: i32, width: i32, height: i32, color: Color) {
    DrawRectangle(pos_x, pos_y, width, height, color);
}

fn draw_rectangle_rec(rec: Rectangle, color: Color) {
    DrawRectangleRec(rec, color);
}

fn draw_rectangle_lines(pos_x: i32, pos_y: i32, width: i32, height: i32, color: Color) {
    DrawRectangleLines(pos_x, pos_y, width, height, color);
}

fn draw_rectangle_lines_ex(rec: Rectangle, line_thick: i32, color: Color) {
    DrawRectangleLinesEx(rec, line_thick, color);
}

fn draw_circle(center_x: i32, center_y: i32, radius: f32, color: Color) {
    DrawCircle(center_x, center_y, radius, color);
}

fn draw_circle_v(center: Vector2, radius: f32, color: Color) {
    DrawCircleV(center, radius, color);
}

fn draw_circle_lines(center_x: i32, center_y: i32, radius: f32, color: Color) {
    DrawCircleLines(center_x, center_y, radius, color);
}

fn draw_triangle(v1: Vector2, v2: Vector2, v3: Vector2, color: Color) {
    DrawTriangle(v1, v2, v3, color);
}

fn draw_text(text: const u8[:], x: i32, y: i32, font_size: i32, color: Color) {
    rl_draw_text(text, x, y, font_size, color);
}

fn measure_text(text: const u8[:], font_size: i32) -> i32 {
    return rl_measure_text(text, font_size);
}

fn draw_fps(pos_x: i32, pos_y: i32) {
    DrawFPS(pos_x, pos_y);
}

fn is_key_pressed(key: i32) -> bool {
    return IsKeyPressed(key);
}

fn is_key_down(key: i32) -> bool {
    return IsKeyDown(key);
}

fn is_key_released(key: i32) -> bool {
    return IsKeyReleased(key);
}

fn is_key_up(key: i32) -> bool {
    return IsKeyUp(key);
}

fn is_mouse_button_pressed(button: i32) -> bool {
    return IsMouseButtonPressed(button);
}

fn is_mouse_button_down(button: i32) -> bool {
    return IsMouseButtonDown(button);
}

fn is_mouse_button_released(button: i32) -> bool {
    return IsMouseButtonReleased(button);
}

fn is_mouse_button_up(button: i32) -> bool {
    return IsMouseButtonUp(button);
}

fn get_mouse_position() -> Vector2 {
    return GetMousePosition();
}

fn get_mouse_x() -> i32 {
    return GetMouseX();
}

fn get_mouse_y() -> i32 {
    return GetMouseY();
}
