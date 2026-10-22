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
| `CloseWindow` | `close_window`, `CloseWindow` | window | implemented | releases managed models before closing GL; repeated close and reopen tested |
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

These are incremental 3D milestones, **not all of Phase D**. The backend is
raylib **6.2**, tag `6.2`, commit `02566453880e06bec97f5b8160fa6fe1e98397ca`.
Both the Nix lock and CMake fallback select this revision. The tables below
inventory the added camera/primitive/model surface, not the entire public header.

| raylib C API | Goose name | Status | Coverage / difference |
|---|---|---|---|
| `Camera3D`, `Vector3`, `Ray`, `BoundingBox`, `Matrix` | same type names | implemented | Packed Goose values; C constructs its own native structs. Matrix follows named-field declaration order. |
| `CAMERA_PERSPECTIVE`, `CAMERA_ORTHOGRAPHIC` | same constants | implemented | Both projections rendered in graphics test. |
| `BeginMode3D`, `EndMode3D` | `begin_mode_3d`, `end_mode_3d` | implemented | Actual OpenGL frames, native builds. |
| `GetCameraMatrix` | `get_camera_matrix` | implemented | Real view-matrix calculation; checked against direct C calls with unaligned buffers and output canaries. |
| `GetWorldToScreen` | `get_world_to_screen` | implemented | Center point projection asserted for both camera projections. |
| `GetScreenToWorldRay` | `get_screen_to_world_ray` | implemented | Center ray direction asserted for both projections. |
| `UpdateCameraPro` | `update_camera_pro` | implemented | In/out `Camera3D&`; movement, rotation and zoom compared with direct C calls. |
| `DrawLine3D` | `draw_line_3d` | implemented | Called in a real frame. |
| `DrawPoint3D` | `draw_point_3d` | implemented | Called in a real frame. |
| `DrawTriangle3D` | `draw_triangle_3d` | implemented | Called in a real frame; preserves counter-clockwise vertex order. |
| `DrawCube` | `draw_cube` | implemented | Scalar x/y/z convenience API; framebuffer color/position assertions. |
| `DrawCubeV` | `draw_cube_v` | implemented | Vector3 position and size; called in a real frame. |
| `DrawCubeWires`, `DrawCubeWiresV` | `draw_cube_wires`, `draw_cube_wires_v` | implemented | Both called in a real frame. |
| `DrawSphere` | `draw_sphere`, `draw_sphere_v` | implemented | `_v` is a Goose convenience wrapper, **not** a C symbol. |
| `DrawSphereEx`, `DrawSphereWires` | `draw_sphere_ex`, `draw_sphere_wires` | implemented | Both called in a real frame. |
| `DrawCylinder` | `draw_cylinder`, `draw_cylinder_v` | implemented | `_v` is a Goose convenience wrapper, **not** a C symbol. |
| `DrawCylinderEx` | `draw_cylinder_ex` | implemented | Called in a real frame. |
| `DrawCylinderWires` | `draw_cylinder_wires`, `draw_cylinder_wires_v` | implemented | `_v` is a Goose convenience wrapper, **not** a C symbol. |
| `DrawCylinderWiresEx` | `draw_cylinder_wires_ex` | implemented | Called in a real frame. |
| `DrawCapsule`, `DrawCapsuleWires` | `draw_capsule`, `draw_capsule_wires` | implemented | Both called in a real frame. |
| `DrawPlane` | `draw_plane` | implemented | Called in a real frame. |
| `DrawRay` | `draw_ray` | implemented | Called in a real frame. |
| `DrawGrid` | `draw_grid` | implemented | Called in graphics test and bounded cube example. |
| `DrawBoundingBox` | `draw_bounding_box` | implemented | Called in a real frame. |
| `DrawCircle3D`, `DrawTriangleStrip3D` | — | planned | Remaining 3D primitive APIs. |
| `UpdateCamera`, `CameraMode` | — | planned | Automatic input-driven camera modes. Use `update_camera_pro` for explicit movement. |
| `GetWorldToScreenEx`, `GetScreenToWorldRayEx` | — | planned | Explicit viewport variants. |
| `Model` | `Model` | implemented | Read-only u64 generation token; native meshes/materials stay in C. |
| `LoadModel` | `load_model` | implemented | Real OBJ/MTL/PNG loading/rendering tested; checked slice paths and failure cleanup. Other native file formats are untested. |
| `GenMeshCube` + `LoadModelFromMesh` | `gen_model_cube` | implemented | Convenience that transfers a generated mesh into an owned model; not standalone mesh bindings. |
| `IsModelValid` | `is_model_valid` | implemented | Validates slot/generation/window before checking native model; stale/reused IDs rejected. |
| `UnloadModel` | `unload_model` | implemented | Returns bool; releases owned material GPU resources in addition to raw raylib model cleanup. |
| `GetModelBoundingBox` | `get_model_bounding_box` | implemented | Returns bounds and bool; unaligned output/canaries and known mesh bounds tested. |
| `DrawModel`, `DrawModelEx` | `draw_model`, `draw_model_ex` | implemented | Real framebuffer pixel assertions for file textures/tints and a nonuniform rotated transform. |
| `DrawModelWires`, `DrawModelWiresEx` | `draw_model_wires`, `draw_model_wires_ex` | implemented | Both invoked in real frames; stale-handle rejection tested. No exhaustive wireframe pixel oracle. |
| Model table helpers (no direct C counterparts) | `model_mesh_count`, `model_material_count`, `unload_all_models`, `MAX_MODELS` | implemented | 64-model capacity; cleanup count, aliases and generation retirement tested. |
| Standalone meshes, arbitrary mesh upload/generation, model animations | — | planned | No borrowed native mesh/material handles exposed. |
| Shaders, materials, render textures | — | planned | Not included here. |
| `raymath.h`, quaternions, matrix arithmetic | `raylib.raymath` module, `raymath::` namespace | implemented / planned | 25 tested functions; all 146 C functions inventoried separately in `RAYMATH_STATUS.md`. |
| `rlgl.h` public API | — | planned | Used internally for default-resource IDs and test framebuffer/GPU-resource checks; no Goose bindings. |

### Model ownership and failures

`Model { let id: u64 }` is an 8-byte value. The high 32 bits hold a generation,
the low 32 bits a one-based slot; zero is invalid. Copies alias one model.
An unloaded token never becomes valid again when that slot is reused. Slots
retire rather than wrap an exhausted generation. Tokens are checked handles,
not a security boundary against code deliberately reconstructing a live ID.

Models require an initialized window and remain main-thread-only. `load_model`
returns `Model { 0 }` for missing/invalid paths, failed native loads or capacity
exhaustion. Empty paths, embedded NULs and paths at least 4096 bytes long are
rejected. `gen_model_cube` also rejects non-positive/non-finite dimensions.
Invalid/stale draw and unload calls return `false`, counts return zero, and
`get_model_bounding_box` returns zeroed bounds with `false`. Drawing rejects
non-finite transforms; frame/mode ordering remains the caller's responsibility.
The `_ex` angle is **degrees**, while raymath angles are radians. Bounds follow
the model's stored transform, not per-draw position/scale/rotation.

The adapter owns the model's meshes and resources referenced by its material
maps. Unlike raw `UnloadModel`, it also releases non-default textures/shaders,
deduplicating IDs shared within the model. There is no API to attach external
materials/textures or borrow its meshes. Explicit `close_window()` and its
`CloseWindow()` compatibility spelling release models before destroying GL;
generations survive context recreation. This does not add destructors or
repair legacy texture/sound lifetimes. Raw C window manipulation bypasses
this contract and is unsupported.

Tests cover actual file loading, slice subslices, rejected paths, empty OBJ
failure cleanup, table exhaustion, slot reuse, generation exhaustion, context
shutdown/reopen, and deletion of real mesh buffers, material textures and a
shared test shader while another model and raylib defaults survive. Only
OBJ/MTL/PNG and generated cubes have format coverage; other raylib loaders
and malformed-file robustness are not claimed.

### Verification limits

- `tests/run_3d.py` separates headless computations, compiler rejection tests,
  external-package imports, and real Xvfb/llvmpipe rendering. Every new drawing
  wrapper is invoked in a frame; per-primitive visual correctness beyond the
  cube's pixel assertions is not exhaustively checked.
- Primitive graphics tests run for three frames; model tests use bounded
  frames plus a context reopen. Both 3D examples end after 120 frames.
- `main_thread_only = true` is enforced by a negative compiler test.
- **JIT remains blocked in the existing local Goose build:** its embedded
  TinyCC cannot find `stdint.h` on NixOS. Package symbol-library construction
  works, but that is not a successful in-process program run. `--jit` opts
  into the tests and fails rather than hiding this problem.
- Linux x86_64 is the tested platform. Windows/macOS are untested.
- Earlier Phase A–C labels predate these tests. They must not be interpreted
  as full API coverage or exhaustive resource-lifetime verification.

### raymath module

Declare `import raylib from "...";` in the root, then load
`import raylib.raymath;`. The compiler supports one namespace qualifier, so
the API is `raymath::matrix_identity()`, not `raylib::math::matrix_identity()`.
No new native package or compiler support is needed.

| Types / constants | Status | Notes |
|---|---|---|
| `raymath::Vector3` | implemented | Alias of `raylib::Vector3`, not a second nominal type. |
| `raymath::Matrix` | implemented | Alias of `raylib::Matrix`, same 16-float declaration order. |
| `raymath::Quaternion` | implemented | Packed x/y/z/w f32 fields (16 bytes). Use `quaternion_identity()` for the identity rotation. |
| `PI`, `DEG2RAD`, `RAD2DEG` | implemented | f32 constants matching the upstream conventions. |
| `EPSILON`, `Vector2`, `Vector4`, `float3`, `float16` | planned | Not exposed as raymath module declarations yet. |
| Other macros / C++ operators | blocked | No direct C ABI or Goose runtime operator-overload mapping; ordinary math wrappers are the supported interface. |

[RAYMATH_STATUS.md](RAYMATH_STATUS.md) inventories **every RMAPI C function**
from the pinned header: 25 implemented, 121 planned. The checker compares
the inventory with the installed header, Goose wrapper declarations and
native implementation/oracle calls. It does not generate bindings or turn
untested declarations into an implementation claim.

All 25 operations have direct C oracle checks with unaligned inputs and
output canaries, plus headless native Goose release/debug tests. These cover
non-commuting matrix multiplication, inversion, transform round trips,
perspective/orthographic matrices, zero-vector normalization and quaternion
rotations/interpolation. Invalid vector-to-matrix/quaternion calls are
rejected by the actual compiler.

Angles follow raymath's **radians**, not Camera3D's degree-based `fovy`.
Projection inputs retain upstream **f64** precision; resulting matrices
remain f32. Functions retain upstream preconditions and degenerate-input
behavior (for example, inverting a singular matrix is not a checked error).
The module does not require a window/display, but currently inherits the
raylib package's main-thread-only restriction. JIT has the same documented
TinyCC header limitation as the rest of the package.

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
