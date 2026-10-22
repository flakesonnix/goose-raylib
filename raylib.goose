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

extern fn rl_init_window(width: i32, height: i32, title: const u8[:]);
extern fn IsWindowReady() -> bool;
extern fn SetConfigFlags(flags: u32);
extern fn WindowShouldClose() -> bool;
extern fn grl_close_window();
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
extern fn DrawRectangleLinesEx(rec: Rectangle, lineThick: f32, color: Color);

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
    rl_init_window(width, height, title);
}

fn is_window_ready() -> bool {
    return IsWindowReady();
}

fn set_config_flags(flags: u32) {
    SetConfigFlags(flags);
}

fn close_window() {
    grl_close_window();
}

// Compatibility spelling also respects managed resource cleanup.
fn CloseWindow() {
    close_window();
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

fn draw_rectangle_lines_ex(rec: Rectangle, line_thick: f32, color: Color) {
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

// ============================================================================
// Constants — PixelFormat (raylib)
// ============================================================================

const PIXELFORMAT_UNCOMPRESSED_GRAYSCALE: i32 = 1;
const PIXELFORMAT_UNCOMPRESSED_GRAY_ALPHA: i32 = 2;
const PIXELFORMAT_UNCOMPRESSED_R5G6B5: i32 = 3;
const PIXELFORMAT_UNCOMPRESSED_R8G8B8: i32 = 4;
const PIXELFORMAT_UNCOMPRESSED_R5G5B5A1: i32 = 5;
const PIXELFORMAT_UNCOMPRESSED_R4G4B4A4: i32 = 6;
const PIXELFORMAT_UNCOMPRESSED_R8G8B8A8: i32 = 7;
const PIXELFORMAT_UNCOMPRESSED_R32: i32 = 8;
const PIXELFORMAT_UNCOMPRESSED_R32G32B32: i32 = 9;
const PIXELFORMAT_UNCOMPRESSED_R32G32B32A32: i32 = 10;
const PIXELFORMAT_COMPRESSED_DXT1_RGB: i32 = 11;
const PIXELFORMAT_COMPRESSED_DXT1_RGBA: i32 = 12;
const PIXELFORMAT_COMPRESSED_DXT3_RGBA: i32 = 13;
const PIXELFORMAT_COMPRESSED_DXT5_RGBA: i32 = 14;
const PIXELFORMAT_COMPRESSED_ETC1_RGB: i32 = 15;
const PIXELFORMAT_COMPRESSED_ETC2_RGB: i32 = 16;
const PIXELFORMAT_COMPRESSED_ETC2_EAC_RGBA: i32 = 17;
const PIXELFORMAT_COMPRESSED_PVRT_RGB: i32 = 18;
const PIXELFORMAT_COMPRESSED_PVRT_RGBA: i32 = 19;
const PIXELFORMAT_COMPRESSED_ASTC_4x4_RGBA: i32 = 20;
const PIXELFORMAT_COMPRESSED_ASTC_8x8_RGBA: i32 = 21;

// ============================================================================
// Structs — Image and Texture2D (Phase B)
// ============================================================================

/*
 * Image — Goose-compatible copy of raylib Image without the void *data pointer.
 * Goose cannot hold raw C pointers, so only metadata is exposed.
 * Use rl_image_width/height/format to query image properties from file.
 */
struct Image { width: i32, height: i32, mipmaps: i32, format: i32 }

/*
 * Texture2D — 1:1 copy of raylib Texture2D (packed, no padding).
 * C layout: { u32 id, i32 width, i32 height, i32 mipmaps, i32 format }
 */
struct Texture2D { id: u32, width: i32, height: i32, mipmaps: i32, format: i32 }

/*
 * Sound — opaque handle (i32) managed by the C adapter.
 * raylib's Sound contains an AudioStream with pointer fields, so it cannot
 * be copied by value across the ABI.  The adapter keeps a static table of
 * loaded Sounds and hands out numeric handles.  Goose code only sees the
 * handle; use load_sound() to create one and unload_sound() to free it.
 */
struct Sound { id: i32 }

// ============================================================================
// Image metadata — via C adapter (Goose slice → null-terminated C string)
// ============================================================================

extern fn rl_image_width(file_name: const u8[:]) -> i32;
extern fn rl_image_height(file_name: const u8[:]) -> i32;
extern fn rl_image_format(file_name: const u8[:]) -> i32;

// ============================================================================
// Texture2D — via C adapter (Goose slice → null-terminated C string)
// ============================================================================

extern fn rl_load_texture(file_name: const u8[:]) -> Texture2D;
extern fn rl_unload_texture(texture: Texture2D);
extern fn rl_draw_texture(texture: Texture2D, pos_x: i32, pos_y: i32, tint: Color);
extern fn rl_draw_texture_ex(texture: Texture2D, pos_x: i32, pos_y: i32, rotation: f32, scale: f32, tint: Color);
extern fn rl_draw_texture_rec(texture: Texture2D, source_x: i32, source_y: i32, source_w: i32, source_h: i32, pos_x: i32, pos_y: i32, tint: Color);

// ============================================================================
// Goose wrappers — snake_case, idiomatic
// ============================================================================

fn image_width(file_name: const u8[:]) -> i32 {
    return rl_image_width(file_name);
}

fn image_height(file_name: const u8[:]) -> i32 {
    return rl_image_height(file_name);
}

fn image_format(file_name: const u8[:]) -> i32 {
    return rl_image_format(file_name);
}

fn load_texture(file_name: const u8[:]) -> Texture2D {
    return rl_load_texture(file_name);
}

fn unload_texture(texture: Texture2D) {
    rl_unload_texture(texture);
}

fn draw_texture(texture: Texture2D, pos_x: i32, pos_y: i32, tint: Color) {
    rl_draw_texture(texture, pos_x, pos_y, tint);
}

fn draw_texture_ex(texture: Texture2D, pos_x: i32, pos_y: i32, rotation: f32, scale: f32, tint: Color) {
    rl_draw_texture_ex(texture, pos_x, pos_y, rotation, scale, tint);
}

fn draw_texture_rec(texture: Texture2D, source_x: i32, source_y: i32, source_w: i32, source_h: i32, pos_x: i32, pos_y: i32, tint: Color) {
    rl_draw_texture_rec(texture, source_x, source_y, source_w, source_h, pos_x, pos_y, tint);
}

// ============================================================================
// Audio (Phase C)
// ============================================================================

extern fn rl_init_audio_device();
extern fn rl_close_audio_device();
extern fn rl_is_audio_device_ready() -> bool;
extern fn rl_load_sound(file_name: const u8[:]) -> i32;
extern fn rl_unload_sound(handle: i32);
extern fn rl_play_sound(handle: i32);
extern fn rl_stop_sound(handle: i32);
extern fn rl_pause_sound(handle: i32);
extern fn rl_resume_sound(handle: i32);
extern fn rl_is_sound_playing(handle: i32) -> bool;
extern fn rl_set_sound_volume(handle: i32, volume: f32);
extern fn rl_set_sound_pitch(handle: i32, pitch: f32);
extern fn rl_set_sound_pan(handle: i32, pan: f32);

// ============================================================================
// Goose wrappers — snake_case, idiomatic
// ============================================================================

fn init_audio_device() {
    rl_init_audio_device();
}

fn close_audio_device() {
    rl_close_audio_device();
}

fn is_audio_device_ready() -> bool {
    return rl_is_audio_device_ready();
}

fn load_sound(file_name: const u8[:]) -> Sound {
    return Sound { rl_load_sound(file_name) };
}

fn unload_sound(sound: Sound) {
    rl_unload_sound(sound.id);
}

fn play_sound(sound: Sound) {
    rl_play_sound(sound.id);
}

fn stop_sound(sound: Sound) {
    rl_stop_sound(sound.id);
}

fn pause_sound(sound: Sound) {
    rl_pause_sound(sound.id);
}

fn resume_sound(sound: Sound) {
    rl_resume_sound(sound.id);
}

fn is_sound_playing(sound: Sound) -> bool {
    return rl_is_sound_playing(sound.id);
}

fn set_sound_volume(sound: Sound, volume: f32) {
    rl_set_sound_volume(sound.id, volume);
}

fn set_sound_pitch(sound: Sound, pitch: f32) {
    rl_set_sound_pitch(sound.id, pitch);
}

fn set_sound_pan(sound: Sound, pan: f32) {
    rl_set_sound_pan(sound.id, pan);
}

// ============================================================================
// Constants — Camera projection (raylib)
// ============================================================================

const CAMERA_PERSPECTIVE: i32 = 0;
const CAMERA_ORTHOGRAPHIC: i32 = 1;

// ============================================================================
// Structs — 3D (Phase D)
// ============================================================================

// Value types stay in Goose. The adapter constructs native raylib structs;
// matching field names/sizes alone do not prove a by-value C calling ABI.
struct Vector3 { x: f32, y: f32, z: f32 }

struct Ray { position: Vector3, direction: Vector3 }

struct Camera3D { position: Vector3, target: Vector3, up: Vector3, fovy: f32, projection: i32 }

struct BoundingBox { min: Vector3, max: Vector3 }

// raylib's named fields are column-major, in this declaration order.
struct Matrix { m0: f32, m4: f32, m8: f32, m12: f32, m1: f32, m5: f32, m9: f32, m13: f32, m2: f32, m6: f32, m10: f32, m14: f32, m3: f32, m7: f32, m11: f32, m15: f32 }

// 3D ABI: primitive arguments plus borrowed fixed-size pointers. C uses
// memcpy for packed/possibly unaligned references, including out parameters.
extern fn grl_begin_mode_3d(camera: const Camera3D&);
extern fn grl_end_mode_3d();
extern fn grl_get_camera_matrix(camera: const Camera3D&, out: Matrix&);
extern fn grl_get_world_to_screen(x: f32, y: f32, z: f32, camera: const Camera3D&, out: Vector2&);
extern fn grl_get_screen_to_world_ray(x: f32, y: f32, camera: const Camera3D&, out: Ray&);
extern fn grl_update_camera_pro(camera: Camera3D&, mx: f32, my: f32, mz: f32, rx: f32, ry: f32, rz: f32, zoom: f32);
extern fn grl_draw_line_3d(ax: f32, ay: f32, az: f32, bx: f32, by: f32, bz: f32, rgba: u32);
extern fn grl_draw_point_3d(x: f32, y: f32, z: f32, rgba: u32);
extern fn grl_draw_triangle_3d(ax: f32, ay: f32, az: f32, bx: f32, by: f32, bz: f32, cx: f32, cy: f32, cz: f32, rgba: u32);
extern fn grl_draw_cube(x: f32, y: f32, z: f32, w: f32, h: f32, length: f32, rgba: u32);
extern fn grl_draw_cube_v(x: f32, y: f32, z: f32, w: f32, h: f32, length: f32, rgba: u32);
extern fn grl_draw_cube_wires(x: f32, y: f32, z: f32, w: f32, h: f32, length: f32, rgba: u32);
extern fn grl_draw_cube_wires_v(x: f32, y: f32, z: f32, w: f32, h: f32, length: f32, rgba: u32);
extern fn grl_draw_sphere(x: f32, y: f32, z: f32, radius: f32, rgba: u32);
extern fn grl_draw_sphere_ex(x: f32, y: f32, z: f32, radius: f32, rings: i32, slices: i32, rgba: u32);
extern fn grl_draw_sphere_wires(x: f32, y: f32, z: f32, radius: f32, rings: i32, slices: i32, rgba: u32);
extern fn grl_draw_cylinder(x: f32, y: f32, z: f32, top: f32, bottom: f32, height: f32, sides: i32, rgba: u32);
extern fn grl_draw_cylinder_ex(ax: f32, ay: f32, az: f32, bx: f32, by: f32, bz: f32, start_radius: f32, end_radius: f32, sides: i32, rgba: u32);
extern fn grl_draw_cylinder_wires(x: f32, y: f32, z: f32, top: f32, bottom: f32, height: f32, sides: i32, rgba: u32);
extern fn grl_draw_cylinder_wires_ex(ax: f32, ay: f32, az: f32, bx: f32, by: f32, bz: f32, start_radius: f32, end_radius: f32, sides: i32, rgba: u32);
extern fn grl_draw_capsule(ax: f32, ay: f32, az: f32, bx: f32, by: f32, bz: f32, radius: f32, rings: i32, slices: i32, rgba: u32);
extern fn grl_draw_capsule_wires(ax: f32, ay: f32, az: f32, bx: f32, by: f32, bz: f32, radius: f32, rings: i32, slices: i32, rgba: u32);
extern fn grl_draw_plane(x: f32, y: f32, z: f32, width: f32, length: f32, rgba: u32);
extern fn grl_draw_ray(x: f32, y: f32, z: f32, dx: f32, dy: f32, dz: f32, rgba: u32);
extern fn grl_draw_grid(slices: i32, spacing: f32);
extern fn grl_draw_bounding_box(ax: f32, ay: f32, az: f32, bx: f32, by: f32, bz: f32, rgba: u32);

fn color_rgba(color: Color) -> u32 {
    (color.r as u32 << 24) | (color.g as u32 << 16) | (color.b as u32 << 8) | color.a
}

fn begin_mode_3d(camera: Camera3D) {
    grl_begin_mode_3d(camera);
}

fn end_mode_3d() {
    grl_end_mode_3d();
}

fn get_camera_matrix(camera: Camera3D) -> Matrix {
    var out = Matrix { .. };
    grl_get_camera_matrix(camera, out);
    return out;
}

fn get_world_to_screen(position: Vector3, camera: Camera3D) -> Vector2 {
    var out = Vector2 { .. };
    grl_get_world_to_screen(position.x, position.y, position.z, camera, out);
    return out;
}

fn get_screen_to_world_ray(position: Vector2, camera: Camera3D) -> Ray {
    var out = Ray { .. };
    grl_get_screen_to_world_ray(position.x, position.y, camera, out);
    return out;
}

fn update_camera_pro(camera: Camera3D&, movement: Vector3, rotation: Vector3, zoom: f32) {
    grl_update_camera_pro(camera, movement.x, movement.y, movement.z, rotation.x, rotation.y, rotation.z, zoom);
}

fn draw_line_3d(start: Vector3, end: Vector3, color: Color) {
    grl_draw_line_3d(start.x, start.y, start.z, end.x, end.y, end.z, color_rgba(color));
}

fn draw_point_3d(position: Vector3, color: Color) {
    grl_draw_point_3d(position.x, position.y, position.z, color_rgba(color));
}

fn draw_triangle_3d(a: Vector3, b: Vector3, c: Vector3, color: Color) {
    grl_draw_triangle_3d(a.x, a.y, a.z, b.x, b.y, b.z, c.x, c.y, c.z, color_rgba(color));
}

fn draw_cube(x: f32, y: f32, z: f32, width: f32, height: f32, length: f32, color: Color) {
    grl_draw_cube(x, y, z, width, height, length, color_rgba(color));
}

fn draw_cube_v(position: Vector3, size: Vector3, color: Color) {
    grl_draw_cube_v(position.x, position.y, position.z, size.x, size.y, size.z, color_rgba(color));
}

fn draw_cube_wires(x: f32, y: f32, z: f32, width: f32, height: f32, length: f32, color: Color) {
    grl_draw_cube_wires(x, y, z, width, height, length, color_rgba(color));
}

fn draw_cube_wires_v(position: Vector3, size: Vector3, color: Color) {
    grl_draw_cube_wires_v(position.x, position.y, position.z, size.x, size.y, size.z, color_rgba(color));
}

fn draw_sphere(x: f32, y: f32, z: f32, radius: f32, color: Color) {
    grl_draw_sphere(x, y, z, radius, color_rgba(color));
}

fn draw_sphere_v(position: Vector3, radius: f32, color: Color) {
    draw_sphere(position.x, position.y, position.z, radius, color);
}

fn draw_sphere_ex(position: Vector3, radius: f32, rings: i32, slices: i32, color: Color) {
    grl_draw_sphere_ex(position.x, position.y, position.z, radius, rings, slices, color_rgba(color));
}

fn draw_sphere_wires(position: Vector3, radius: f32, rings: i32, slices: i32, color: Color) {
    grl_draw_sphere_wires(position.x, position.y, position.z, radius, rings, slices, color_rgba(color));
}

fn draw_cylinder(x: f32, y: f32, z: f32, radius_top: f32, radius_bottom: f32, height: f32, slices: i32, color: Color) {
    grl_draw_cylinder(x, y, z, radius_top, radius_bottom, height, slices, color_rgba(color));
}

fn draw_cylinder_v(position: Vector3, radius_top: f32, radius_bottom: f32, height: f32, slices: i32, color: Color) {
    draw_cylinder(position.x, position.y, position.z, radius_top, radius_bottom, height, slices, color);
}

fn draw_cylinder_ex(start: Vector3, end: Vector3, start_radius: f32, end_radius: f32, sides: i32, color: Color) {
    grl_draw_cylinder_ex(start.x, start.y, start.z, end.x, end.y, end.z, start_radius, end_radius, sides, color_rgba(color));
}

fn draw_cylinder_wires(x: f32, y: f32, z: f32, radius_top: f32, radius_bottom: f32, height: f32, slices: i32, color: Color) {
    grl_draw_cylinder_wires(x, y, z, radius_top, radius_bottom, height, slices, color_rgba(color));
}

fn draw_cylinder_wires_v(position: Vector3, radius_top: f32, radius_bottom: f32, height: f32, slices: i32, color: Color) {
    draw_cylinder_wires(position.x, position.y, position.z, radius_top, radius_bottom, height, slices, color);
}

fn draw_cylinder_wires_ex(start: Vector3, end: Vector3, start_radius: f32, end_radius: f32, sides: i32, color: Color) {
    grl_draw_cylinder_wires_ex(start.x, start.y, start.z, end.x, end.y, end.z, start_radius, end_radius, sides, color_rgba(color));
}

fn draw_capsule(start: Vector3, end: Vector3, radius: f32, rings: i32, slices: i32, color: Color) {
    grl_draw_capsule(start.x, start.y, start.z, end.x, end.y, end.z, radius, rings, slices, color_rgba(color));
}

fn draw_capsule_wires(start: Vector3, end: Vector3, radius: f32, rings: i32, slices: i32, color: Color) {
    grl_draw_capsule_wires(start.x, start.y, start.z, end.x, end.y, end.z, radius, rings, slices, color_rgba(color));
}

fn draw_plane(center: Vector3, size: Vector2, color: Color) {
    grl_draw_plane(center.x, center.y, center.z, size.x, size.y, color_rgba(color));
}

fn draw_ray(ray: Ray, color: Color) {
    grl_draw_ray(ray.position.x, ray.position.y, ray.position.z,
                 ray.direction.x, ray.direction.y, ray.direction.z, color_rgba(color));
}

fn draw_grid(slices: i32, spacing: f32) {
    grl_draw_grid(slices, spacing);
}

fn draw_bounding_box(box: BoundingBox, color: Color) {
    grl_draw_bounding_box(box.min.x, box.min.y, box.min.z, box.max.x, box.max.y, box.max.z, color_rgba(color));
}

// Managed models own their meshes and loaded material resources in C.
// Copies share one generation-checked token; unloading invalidates every copy.
struct Model { let id: u64 }
const MAX_MODELS: i32 = 64;

extern fn grl_load_model(path: const u8[:]) -> u64;
extern fn grl_gen_model_cube(width: f32, height: f32, length: f32) -> u64;
extern fn grl_is_model_valid(id: u64) -> bool;
extern fn grl_unload_model(id: u64) -> bool;
extern fn grl_unload_all_models() -> i32;
extern fn grl_model_mesh_count(id: u64) -> i32;
extern fn grl_model_material_count(id: u64) -> i32;
extern fn grl_get_model_bounding_box(id: u64, out: BoundingBox&) -> bool;
extern fn grl_draw_model(id: u64, x: f32, y: f32, z: f32, scale: f32, rgba: u32) -> bool;
extern fn grl_draw_model_ex(id: u64, x: f32, y: f32, z: f32, ax: f32, ay: f32, az: f32,
                            angle: f32, sx: f32, sy: f32, sz: f32, rgba: u32) -> bool;
extern fn grl_draw_model_wires(id: u64, x: f32, y: f32, z: f32, scale: f32, rgba: u32) -> bool;
extern fn grl_draw_model_wires_ex(id: u64, x: f32, y: f32, z: f32, ax: f32, ay: f32, az: f32,
                                  angle: f32, sx: f32, sy: f32, sz: f32, rgba: u32) -> bool;

// Loading requires an initialized window. id == 0 reports failure (including
// unavailable files, invalid paths, native load failure or the model limit).
fn load_model(path: const u8[:]) -> Model {
    return Model { grl_load_model(path) };
}
fn gen_model_cube(width: f32, height: f32, length: f32) -> Model {
    return Model { grl_gen_model_cube(width, height, length) };
}
fn is_model_valid(model: Model) -> bool {
    return grl_is_model_valid(model.id);
}
fn unload_model(model: Model) -> bool {
    return grl_unload_model(model.id);
}
fn unload_all_models() -> i32 {
    return grl_unload_all_models();
}
fn model_mesh_count(model: Model) -> i32 {
    return grl_model_mesh_count(model.id);
}
fn model_material_count(model: Model) -> i32 {
    return grl_model_material_count(model.id);
}
fn get_model_bounding_box(model: Model) -> BoundingBox, bool {
    var out = BoundingBox { .. };
    let valid = grl_get_model_bounding_box(model.id, out);
    return out, valid;
}
fn draw_model(model: Model, position: Vector3, scale: f32, tint: Color) -> bool {
    return grl_draw_model(model.id, position.x, position.y, position.z, scale, color_rgba(tint));
}
// DrawModelEx rotation angles are DEGREES, not raymath radians.
fn draw_model_ex(model: Model, position: Vector3, axis: Vector3, angle: f32, scale: Vector3, tint: Color) -> bool {
    return grl_draw_model_ex(model.id, position.x, position.y, position.z, axis.x, axis.y, axis.z,
                              angle, scale.x, scale.y, scale.z, color_rgba(tint));
}
fn draw_model_wires(model: Model, position: Vector3, scale: f32, tint: Color) -> bool {
    return grl_draw_model_wires(model.id, position.x, position.y, position.z, scale, color_rgba(tint));
}
fn draw_model_wires_ex(model: Model, position: Vector3, axis: Vector3, angle: f32, scale: Vector3, tint: Color) -> bool {
    return grl_draw_model_wires_ex(model.id, position.x, position.y, position.z, axis.x, axis.y, axis.z,
                                    angle, scale.x, scale.y, scale.z, color_rgba(tint));
}

// Standalone, uploaded meshes. Tokens are distinct from Model tokens.
// Copies alias one resource; unload or successful model transfer invalidates all.
struct Mesh { let id: u64 }
const MAX_MESHES: i32 = 64;
const MAX_MESH_SUBDIVISIONS: i32 = 128;

extern fn grl_gen_mesh_poly(sides: i32, radius: f32) -> u64;
extern fn grl_gen_mesh_plane(width: f32, length: f32, res_x: i32, res_z: i32) -> u64;
extern fn grl_gen_mesh_cube(width: f32, height: f32, length: f32) -> u64;
extern fn grl_gen_mesh_sphere(radius: f32, rings: i32, slices: i32) -> u64;
extern fn grl_gen_mesh_hemi_sphere(radius: f32, rings: i32, slices: i32) -> u64;
extern fn grl_gen_mesh_cylinder(radius: f32, height: f32, slices: i32) -> u64;
extern fn grl_gen_mesh_cone(radius: f32, height: f32, slices: i32) -> u64;
extern fn grl_is_mesh_valid(id: u64) -> bool;
extern fn grl_unload_mesh(id: u64) -> bool;
extern fn grl_unload_all_meshes() -> i32;
extern fn grl_mesh_vertex_count(id: u64) -> i32;
extern fn grl_mesh_triangle_count(id: u64) -> i32;
extern fn grl_get_mesh_bounding_box(id: u64, out: BoundingBox&) -> bool;
extern fn grl_draw_mesh(id: u64, transform: const Matrix&, rgba: u32) -> bool;
extern fn grl_load_model_from_mesh(id: u64) -> u64;

// Generation requires a window, positive finite dimensions and bounded
// subdivisions: planes 1..MAX_MESH_SUBDIVISIONS, other generators 3..limit.
fn gen_mesh_poly(sides: i32, radius: f32) -> Mesh {
    return Mesh { grl_gen_mesh_poly(sides, radius) };
}
fn gen_mesh_plane(width: f32, length: f32, res_x: i32, res_z: i32) -> Mesh {
    return Mesh { grl_gen_mesh_plane(width, length, res_x, res_z) };
}
fn gen_mesh_cube(width: f32, height: f32, length: f32) -> Mesh {
    return Mesh { grl_gen_mesh_cube(width, height, length) };
}
fn gen_mesh_sphere(radius: f32, rings: i32, slices: i32) -> Mesh {
    return Mesh { grl_gen_mesh_sphere(radius, rings, slices) };
}
fn gen_mesh_hemi_sphere(radius: f32, rings: i32, slices: i32) -> Mesh {
    return Mesh { grl_gen_mesh_hemi_sphere(radius, rings, slices) };
}
fn gen_mesh_cylinder(radius: f32, height: f32, slices: i32) -> Mesh {
    return Mesh { grl_gen_mesh_cylinder(radius, height, slices) };
}
fn gen_mesh_cone(radius: f32, height: f32, slices: i32) -> Mesh {
    return Mesh { grl_gen_mesh_cone(radius, height, slices) };
}
fn is_mesh_valid(mesh: Mesh) -> bool {
    return grl_is_mesh_valid(mesh.id);
}
fn unload_mesh(mesh: Mesh) -> bool {
    return grl_unload_mesh(mesh.id);
}
fn unload_all_meshes() -> i32 {
    return grl_unload_all_meshes();
}
fn mesh_vertex_count(mesh: Mesh) -> i32 {
    return grl_mesh_vertex_count(mesh.id);
}
fn mesh_triangle_count(mesh: Mesh) -> i32 {
    return grl_mesh_triangle_count(mesh.id);
}
fn get_mesh_bounding_box(mesh: Mesh) -> BoundingBox, bool {
    var out = BoundingBox { .. };
    let valid = grl_get_mesh_bounding_box(mesh.id, out);
    return out, valid;
}
// DrawMesh with a private default material. No borrowed Material API yet.
fn draw_mesh(mesh: Mesh, transform: Matrix, tint: Color) -> bool {
    return grl_draw_mesh(mesh.id, transform, color_rgba(tint));
}
// Move, not copy: success invalidates all Mesh aliases. Failure returns Model
// { 0 } and leaves a valid source intact, including when MAX_MODELS is reached.
fn load_model_from_mesh(mesh: Mesh) -> Model {
    return Model { grl_load_model_from_mesh(mesh.id) };
}
