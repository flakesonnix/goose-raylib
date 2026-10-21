# goose-raylib — raylib bindings for Goose

A standalone, reusable Goose package that exposes the [raylib](https://github.com/raysan5/raylib)
C-API to Goose via `extern fn`. raylib remains the native backend; only a small
C adapter (`src/raylib_adapter.c`) bridges Goose slices to null-terminated C strings.

## Package structure

```
goose-raylib/
├── raylib.goose          # Goose bindings, namespace raylib (Phase A)
├── raylib.build          # Goose C sidecar (for raylib.goose itself)
├── *.build               # C sidecars for examples and tests
├── flake.nix             # Nix devShell (cmake, gcc, raylib, git)
├── flake.lock            # pinned nixpkgs (reproducible)
├── src/
│   ├── raylib_adapter.h  # C adapter header
│   └── raylib_adapter.c  # C adapter impl (string conversion)
├── minimal.goose         # example: window + text (Phase A)
├── shapes.goose          # example: shapes, lines, circles (Phase A)
├── input.goose           # example: keyboard/mouse input (Phase A)
├── test_window.goose     # test: window constants
├── test_shapes.goose     # test: colors, structs
├── test_strings.goose    # test: string conversion (with libraylib)
├── test_input.goose      # test: input (with libraylib)
├── test_resources.goose  # test: Phase B (planned)
├── examples/             # see your Pong repo for a full game example
├── docs/
│   ├── ARCHITECTURE.md   # architecture & ABI risks
│   └── API_STATUS.md     # implementation status
└── README.md             # this file
```

## Build & Run

### With Nix Flakes (recommended)

```bash
nix develop goose-raylib/                 # devShell: cmake, gcc, raylib, git

# Compile and run (requires X11/Wayland display)
goose build minimal.goose && ./minimal
goose build shapes.goose && ./shapes
goose build input.goose && ./input
# Full Pong example: see your Pong repo (replace with your repo URL)
# goose build <your-pong-main>.goose && ./<your-pong-main>

# Unit tests (with libraylib)
goose build test_strings.goose && ./test_strings
goose build test_input.goose && ./test_input

# Unit tests (without libraylib, pure logic)
goose build test_window.goose && ./test_window
goose build test_shapes.goose && ./test_shapes
goose build test_resources.goose && ./test_resources

# Typecheck only
goose check raylib.goose
```

### Without Nix

Make sure `libraylib` + `raylib.h` are installed, then:

```bash
goose build minimal.goose && ./minimal
goose check raylib.goose
```

### With a virtual display (headless CI)

```bash
Xvfb :99 -screen 0 800x450x16 & export DISPLAY=:99
# Full Pong example: see your Pong repo (replace with your repo URL)
# goose build <your-pong-main>.goose && ./<your-pong-main>
```

## API (Phase A — implemented and tested)

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

See `docs/API_STATUS.md` for the full implementation status.

## Examples

A full **Pong** game built with goose-raylib lives in your Pong repo:

https://github.com/flakesonnix/goose-pong

## Important notes
  Resources (textures, sounds, …) must be explicitly released with `unload_*`.
- **Strings:** Goose `const u8[:]` is converted to null-terminated C strings
  via the C adapter (`src/raylib_adapter.c`).
- **Display:** Graphical programs need an X11/Wayland display.
  Without a display, `InitWindow` fails; for CI use `Xvfb`.
- **raylib version:** Via Nix, `raylib` is taken from `nixpkgs`
  (see `flake.lock` for the pin).

## Licenses

- goose-raylib: see `LICENSE` (repository root)
- raylib: zlib/libpng license (upstream, https://github.com/raysan5/raylib)
- The C adapter is part of goose-raylib.
