# goose-raylib — raylib bindings for Goose

A standalone, reusable Goose package that exposes the [raylib](https://github.com/raysan5/raylib)
C-API to Goose via `extern fn`. raylib remains the native backend; only a small
C adapter bridges Goose slices to null-terminated C strings and marshals the
new 3D API without relying on packed-by-value C struct compatibility.

**Current milestone:** 3D cameras and primitives, not the complete raylib API.
The backend is raylib **6.2** (tag `6.2`, commit
`02566453880e06bec97f5b8160fa6fe1e98397ca`), pinned in both the Nix flake
and CMake's SHA256-checked source fallback.

## Package structure

```
goose-raylib/
├── raylib.goose          # Goose bindings, namespace raylib
├── raylib.build          # native package dependency, main-thread-only
├── CMakeLists.txt        # static adapter + raylib link dependencies
├── flake.nix             # Nix devShell, raylib 6.2, Xvfb, Python
├── flake.lock            # pinned nixpkgs (reproducible)
├── src/
│   ├── raylib_adapter.h  # C adapter header
│   ├── raylib_adapter.c  # C adapter impl (strings, textures)
│   └── raylib_3d.c/h     # scalar/borrowed-pointer 3D boundary
├── minimal.goose         # example: window + text (Phase A)
├── shapes.goose          # example: shapes, lines, circles (Phase A)
├── input.goose           # example: keyboard/mouse input (Phase A)
├── textures.goose        # example: texture metadata queries (Phase B)
├── cube3d.goose          # 3D camera, moving cube, sphere and grid (120 frames)
├── test_3d.goose         # headless Goose camera and value-layout tests
├── tests/               # C ABI, pixel readback, negative tests, test runner
├── test_window.goose     # test: window constants
├── test_shapes.goose     # test: colors, structs
├── test_strings.goose    # test: string conversion (with libraylib)
├── test_input.goose      # test: input (with libraylib)
├── test_resources.goose  # test: Phase B (planned)
├── test_textures.goose   # test: texture/Image structs + pixel formats (Phase B)
├── test_audio.goose      # test: Sound handle + audio device (Phase C)
├── docs/
│   ├── ARCHITECTURE.md   # architecture & ABI risks
│   └── API_STATUS.md     # implementation status
└── README.md             # this file
```

## Build & Run

### With Nix Flakes (recommended)

```bash
# From a checkout of this repository (Goose itself must be installed separately)
nix develop

# Compile and run (requires X11/Wayland display)
goose build minimal.goose && ./minimal
goose build shapes.goose && ./shapes
goose build input.goose && ./input
goose build cube3d.goose && ./cube3d
goose build textures.goose && ./textures

# Full Pong example (developed separately):
# https://github.com/flakesonnix/goose-pong

# Unit tests (with libraylib)
goose build test_strings.goose && ./test_strings
goose build test_input.goose && ./test_input
goose build test_textures.goose && ./test_textures
goose build test_audio.goose && ./test_audio

# Unit tests (without libraylib, pure logic)
goose build test_window.goose && ./test_window
goose build test_shapes.goose && ./test_shapes
goose build test_resources.goose && ./test_resources

# Typecheck only
goose check raylib.goose
```

### Without Nix

Install Goose, CMake >= 3.24, a C/C++ toolchain and raylib's Linux graphics
development dependencies. CMake uses an installed raylib 6.2 when available;
otherwise it fetches the pinned source archive. No local library paths are
embedded in the package. Then, from this checkout:

```bash
goose build minimal.goose && ./minimal
goose check raylib.goose
```

### With a virtual display (headless CI)

```bash
export GOOSE=/path/to/goose
nix develop --command python3 tests/run_3d.py
# Camera math + compile-failure tests only (no display):
nix develop --command python3 tests/run_3d.py --headless-only
```

The runner builds C and Goose tests, checks an external consumer with no
sidecar of its own, and runs real Xvfb/llvmpipe frames with framebuffer pixel
assertions. It forces X11 rather than accidentally using the host Wayland
session. Every graphics program has a finite frame count. Command failures
and timeouts fail the suite; full logs are under `build/tests-3d/`.

**JIT limitation:** the tested existing Goose build's embedded TinyCC cannot
find `stdint.h` on NixOS. Native builds and the package's native symbol library
work; in-process execution is not claimed as passing. With a properly
configured Goose/TinyCC installation, opt in using `tests/run_3d.py --jit`.

## Importing from another Goose program

Declare the package source in the root program (adjust the relative path):

```goose
import raylib from "../goose-raylib";

fn main() {
    raylib::init_window(800, 450, "Hello from Goose");
    raylib::set_target_fps(60);
    while !raylib::window_should_close() {
        raylib::begin_drawing();
        raylib::clear_background(raylib::RAYWHITE);
        raylib::draw_text("Hello!", 20, 20, 32, raylib::BLACK);
        raylib::end_drawing();
    }
    raylib::close_window();
}
```

`raylib.build` activates the package's CMake target for native linking and
symbol-library construction. Consumers do not copy C sources or add
`-lraylib` by hand. Within this checkout use `import raylib from ".";`.
Worker-thread calls are rejected: the package is `main_thread_only`.

## API

### Phase A — implemented and tested

```goose
import raylib;

raylib::init_window(800, 450, "Hello from Goose");
raylib::set_target_fps(60);

while !raylib::window_should_close() {
    raylib::begin_drawing();
    raylib::clear_background(raylib::RAYWHITE);
    raylib::draw_text("Hello from Goose!", 20, 20, 32, raylib::BLACK);
    raylib::end_drawing();
}

raylib::close_window();
```

- **Window:** `init_window`, `close_window`, `window_should_close`, `set_target_fps`,
  `set_window_title`, `toggle_fullscreen`, `hide_cursor`, `show_cursor`, `is_cursor_hidden`
- **Rendering:** `begin_drawing`, `end_drawing`, `clear_background`, `begin_mode_2d`, `end_mode_2d`
- **Drawing:** `draw_pixel`, `draw_line`, `draw_line_v`, `draw_rectangle`,
  `draw_rectangle_rec`, `draw_rectangle_lines`, `draw_rectangle_lines_ex`, `draw_circle`,
  `draw_circle_v`, `draw_circle_lines`, `draw_triangle`, `draw_text`, `measure_text`, `draw_fps`
- **Input:** `is_key_pressed/down/released/up`, `is_mouse_button_pressed/down/released/up`,
  `get_mouse_position`, `get_mouse_x`, `get_mouse_y`
- **Types:** `Vector2`, `Color`, `Rectangle`, `Camera2D` (packed, 1:1 C layout)
- **Constants:** `RAYWHITE`, `BLACK`, `WHITE`, `RED`, `GREEN`, `BLUE`, `YELLOW`, `ORANGE`,
  `PURPLE`, `GRAY`, `LIGHTGRAY`, `DARKGRAY`, `SKYBLUE`, `DARKBLUE`, `DARKGREEN`, `DARKRED`,
  `KEY_*` (A–Z, 0–9, F1–F12, arrow keys, …), `MOUSE_*`

### Phase B — partial resource bindings

```goose
import raylib;

// Query image metadata without keeping the C Image around
let w = raylib::image_width("assets/logo.png");
let h = raylib::image_height("assets/logo.png");

// Load, draw, unload a texture
let tex = raylib::load_texture("assets/logo.png");
raylib::draw_texture(tex, 100, 100, raylib::WHITE);
raylib::draw_texture_ex(tex, 200, 200, 45.0, 1.5, raylib::WHITE);
raylib::draw_texture_rec(tex, 0, 0, 64, 64, 300, 300, raylib::WHITE);
raylib::unload_texture(tex);
```

- **Image metadata:** `image_width`, `image_height`, `image_format` (loads + unloads
  the C image internally; only metadata is returned, since Goose cannot hold raw pointers)
- **Texture2D:** `load_texture`, `unload_texture`, `draw_texture`, `draw_texture_ex`,
  `draw_texture_rec`
- **Types:** `Image` (metadata only, no `void *data` pointer), `Texture2D`
  (packed, 1:1 C layout)
- **Constants:** `PIXELFORMAT_*` (UNCOMPRESSED_GRAYSCALE through COMPRESSED_ASTC_8x8_RGBA)

### Phase C — partial sound bindings

```goose
import raylib;

// Initialize and query the audio device
raylib::init_audio_device();
let ready = raylib::is_audio_device_ready();

// Load and play a sound (Sound is an opaque handle)
let snd = raylib::load_sound("assets/jump.wav");
raylib::play_sound(snd);
raylib::set_sound_volume(snd, 0.7);
raylib::set_sound_pitch(snd, 1.2);

// Clean up
raylib::unload_sound(snd);
raylib::close_audio_device();
```

- **Audio device:** `init_audio_device`, `close_audio_device`, `is_audio_device_ready`
- **Sound:** `load_sound`, `unload_sound`, `play_sound`, `stop_sound`, `pause_sound`,
  `resume_sound`, `is_sound_playing`, `set_sound_volume`, `set_sound_pitch`, `set_sound_pan`
- **Types:** `Sound` (opaque handle `Sound { id: i32 }`)

### Phase D — cameras and 3D primitives

See `cube3d.goose` for a complete, bounded example. Inside a drawing frame:

```goose
let camera = raylib::Camera3D {
    position: raylib::Vector3 { 4, 4, 4 }, target: raylib::Vector3 { .. },
    up: raylib::Vector3 { 0, 1, 0 }, fovy: 45,
    projection: raylib::CAMERA_PERSPECTIVE,
};
raylib::begin_mode_3d(camera);
raylib::draw_cube_v(raylib::Vector3 { 0, 1, 0 }, raylib::Vector3 { 1, 1, 1 }, raylib::RED);
raylib::draw_grid(20, 1);
raylib::end_mode_3d();
```

- **Camera:** `begin_mode_3d`, `end_mode_3d`, `get_camera_matrix`,
  `get_world_to_screen`, `get_screen_to_world_ray`, `update_camera_pro`.
  `update_camera_pro` takes a mutable `Camera3D&`, movement/rotation `Vector3`s
  and a zoom amount, preserving raylib's units and semantics.
- **Drawing:** 3D lines, points, triangles, cubes/wires, spheres/wires,
  cylinders/wires, capsules/wires, planes, rays, grids and bounding boxes.
  `draw_cube`, `draw_sphere` and `draw_cylinder` accept scalar x/y/z positions;
  `_v` conveniences accept `Vector3`. The latter do not invent C symbols.
- **Value types:** `Vector3`, `Ray`, `Camera3D`, `BoundingBox`, `Matrix`.
- **Still planned:** meshes/models, shaders/materials, render textures,
  automatic camera modes, raymath arithmetic/quaternions and public rlgl
  bindings. This is not a claim that Phase D is complete.

See `docs/API_STATUS.md` for the full implementation status.

## Examples

A separate **Pong** game is being developed here:

https://github.com/flakesonnix/goose-pong

## Important notes

- **No automatic resource cleanup:** Goose has no destructors/RAII.
  Resources (textures, sounds, …) must be explicitly released with `unload_*`.
- **Strings:** Goose `const u8[:]` is converted to null-terminated C strings
  via the C adapter (`src/raylib_adapter.c`).
- **Display:** Graphical programs need an X11/Wayland display.
  Without a display, `InitWindow` fails; for CI use `Xvfb`.
- **Legacy resource limitations:** the earlier texture/sound adapters are
  not yet generation-checked. Stale handles, raw texture IDs and failed
  loads still need hardening; the 3D milestone does not fix these APIs.
- **Platforms:** Linux x86_64 is tested; Windows and macOS are untested.

## Licenses

- goose-raylib: Apache-2.0, matching the original Goose repository license
  referenced by this package; see `LICENSE`.
- raylib: zlib/libpng license (upstream, https://github.com/raysan5/raylib)
- The C adapter is part of goose-raylib.
