# API status: goose-raylib

Status values:
- `implemented`: implemented and tested
- `implemented-untested`: implemented, but not fully tested
- `blocked`: concrete technical limitation
- `planned`: not yet implemented

## Phase A — working minimal package

| raylib C API | Goose name | Module | Status | Note |
|---|---|---|---|---|
| `InitWindow` | `init_window` | window | implemented | tested under Xvfb (exit 0) |
| `CloseWindow` | `close_window` | window | implemented | tested under Xvfb (exit 0) |
| `WindowShouldClose` | `window_should_close` | window | implemented | tested under Xvfb (exit 0) |
| `SetTargetFPS` | `set_target_fps` | window | implemented | tested under Xvfb (exit 0) |
| `SetWindowTitle` | `set_window_title` | window | implemented | via C adapter (rl_set_window_title) |
| `ToggleFullscreen` | `toggle_fullscreen` | window | implemented-untested | declared, used in pong example |
| `HideCursor` | `hide_cursor` | window | implemented | tested under Xvfb |
| `ShowCursor` | `show_cursor` | window | implemented | tested under Xvfb |
| `IsCursorHidden` | `is_cursor_hidden` | window | implemented | tested under Xvfb |
| `BeginDrawing` | `begin_drawing` | draw | implemented | tested under Xvfb |
| `EndDrawing` | `end_drawing` | draw | implemented | tested under Xvfb |
| `ClearBackground` | `clear_background` | draw | implemented | Color by value, tested |
| `DrawPixel` | `draw_pixel` | draw | implemented | declared, tested under Xvfb |
| `DrawLine` | `draw_line` | draw | implemented | tested under Xvfb (shapes) |
| `DrawLineV` | `draw_line_v` | draw | implemented-untested | declared |
| `DrawRectangle` | `draw_rectangle` | draw | implemented | tested under Xvfb |
| `DrawRectangleRec` | `draw_rectangle_rec` | draw | implemented | Rectangle by value, tested |
| `DrawRectangleLines` | `draw_rectangle_lines` | draw | implemented | tested under Xvfb |
| `DrawRectangleLinesEx` | `draw_rectangle_lines_ex` | draw | implemented | tested under Xvfb |
| `DrawCircle` | `draw_circle` | draw | implemented | tested under Xvfb |
| `DrawCircleV` | `draw_circle_v` | draw | implemented | Vector2 by value, tested under Xvfb |
| `DrawCircleLines` | `draw_circle_lines` | draw | implemented | tested under Xvfb |
| `DrawTriangle` | `draw_triangle` | draw | implemented | 3× Vector2, tested under Xvfb |
| `DrawText` | `draw_text` | draw | implemented | via C adapter (rl_draw_text) |
| `MeasureText` | `measure_text` | draw | implemented | via C adapter (rl_measure_text) |
| `DrawFPS` | `draw_fps` | draw | implemented | tested under Xvfb |
| `IsKeyPressed` | `is_key_pressed` | input | implemented | tested under Xvfb |
| `IsKeyDown` | `is_key_down` | input | implemented | tested under Xvfb |
| `IsKeyReleased` | `is_key_released` | input | implemented | tested under Xvfb |
| `IsKeyUp` | `is_key_up` | input | implemented | tested under Xvfb |
| `IsMouseButtonPressed` | `is_mouse_button_pressed` | input | implemented | tested under Xvfb |
| `IsMouseButtonDown` | `is_mouse_button_down` | input | implemented | tested under Xvfb |
| `IsMouseButtonReleased` | `is_mouse_button_released` | input | implemented | tested under Xvfb |
| `IsMouseButtonUp` | `is_mouse_button_up` | input | implemented | tested under Xvfb |
| `GetMousePosition` | `get_mouse_position` | input | implemented | Vector2 return, tested |
| `GetMouseX` | `get_mouse_x` | input | implemented | tested |
| `GetMouseY` | `get_mouse_y` | input | implemented | tested |

## Constants (Phase A)

| Name | Value | Status |
|---|---|---|
| `RAYWHITE` | {245,245,245,255} | implemented |
| `BLACK` | {0,0,0,255} | implemented |
| `WHITE` | {255,255,255,255} | implemented |
| `RED` | {255,0,0,255} | implemented |
| `GREEN` | {0,255,0,255} | implemented |
| `BLUE` | {0,0,255,255} | implemented |
| `YELLOW` | {255,255,0,255} | implemented |
| `ORANGE` | {255,128,0,255} | implemented |
| `PURPLE` | {128,0,128,255} | implemented |
| `GRAY` | {130,130,130,255} | implemented |
| `LIGHTGRAY` | {200,200,200,255} | implemented |
| `DARKGRAY` | {80,80,80,255} | implemented |
| `SKYBLUE` | {135,206,235,255} | implemented |
| `DARKBLUE` | {0,0,139,255} | implemented |
| `DARKGREEN` | {0,100,0,255} | implemented |
| `DARKRED` | {139,0,0,255} | implemented |
| `KEY_*` | raylib scancodes | implemented |
| `MOUSE_*` | 0,1,2,… | implemented |

## Phase B — 2D and resources

| raylib C API | Goose name | Status | Note |
|---|---|---|---|
| `LoadTexture` | `load_texture` | implemented | via C adapter (rl_load_texture) |
| `UnloadTexture` | `unload_texture` | implemented | declared; not called on dummy ID (crash risk) |
| `DrawTexture` | `draw_texture` | implemented | via C adapter (rl_draw_texture) |
| `DrawTextureEx` | `draw_texture_ex` | implemented | via C adapter (rl_draw_texture_ex) |
| `DrawTextureRec` | `draw_texture_rec` | implemented | via C adapter (rl_draw_texture_rec) |
| `LoadImage` | — | blocked | void *data pointer not representable in Goose |
| `UnloadImage` | — | blocked | void *data pointer not representable in Goose |
| `LoadFont` | `load_font` | planned | Font struct has pointer fields |
| `UnloadFont` | `unload_font` | planned | |

### Image metadata queries

| raylib C API | Goose name | Status | Note |
|---|---|---|---|
| `LoadImage` + read width | `image_width` | implemented | loads + unloads image, returns width |
| `LoadImage` + read height | `image_height` | implemented | loads + unloads image, returns height |
| `LoadImage` + read format | `image_format` | implemented | loads + unloads image, returns format |

## Phase C — audio and input

| raylib C API | Goose name | Status | Note |
|---|---|---|---|
| `InitAudioDevice` | `init_audio_device` | implemented | tested |
| `CloseAudioDevice` | `close_audio_device` | implemented | tested |
| `IsAudioDeviceReady` | `is_audio_device_ready` | implemented | tested |
| `LoadSound` | `load_sound` | implemented | returns Sound handle (i32), via C adapter |
| `UnloadSound` | `unload_sound` | implemented | via C adapter handle table |
| `PlaySound` | `play_sound` | implemented | via C adapter handle table |
| `StopSound` | `stop_sound` | implemented | via C adapter handle table |
| `PauseSound` | `pause_sound` | implemented | via C adapter handle table |
| `ResumeSound` | `resume_sound` | implemented | via C adapter handle table |
| `IsSoundPlaying` | `is_sound_playing` | implemented | via C adapter handle table |
| `SetSoundVolume` | `set_sound_volume` | implemented | via C adapter handle table |
| `SetSoundPitch` | `set_sound_pitch` | implemented | via C adapter handle table |
| `SetSoundPan` | `set_sound_pan` | implemented | via C adapter handle table |
| `LoadMusicStream` | `load_music_stream` | planned | Music struct has pointer fields |
| `UnloadMusicStream` | `unload_music_stream` | planned | Music struct has pointer fields |
| `PlayMusicStream` | `play_music_stream` | planned | |
| `UpdateMusicStream` | `update_music_stream` | planned | |
| Gamepad APIs | `is_gamepad_available`, etc. | planned | |

### Sound handle system

`Sound` is an opaque handle (`Sound { id: i32 }`) managed by the C adapter.
raylib's `Sound` struct contains an `AudioStream` with pointer fields, so it
cannot be copied by value across the Goose/C ABI.  The adapter keeps a static
table of up to 64 loaded Sounds and hands out numeric handles.

## Phase D — 3D

| Area | Status |
|---|---|
| Cameras (Camera3D) | planned |
| Vectors/matrices (raymath) | planned |
| 3D primitives | planned |
| Meshes/models | planned |
| Shaders | planned |

## Phase E — remaining public API

| Area | Status |
|---|---|
| File I/O | planned |
| Logging | planned |
| Collision | planned |
| Image operations | planned |

## Not supported (blocked)

| Element | Reason |
|---|---|
| Callbacks (C function pointers) | Goose has no runtime function pointers; static trampolines possible, not planned |
| Automatic resource cleanup | Goose has no destructors/RAII |
