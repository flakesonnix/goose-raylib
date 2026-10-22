# goose-raylib — raylib bindings for Goose

A standalone, reusable Goose package that exposes the [raylib](https://github.com/raysan5/raylib)
C-API to Goose via `extern fn`. raylib remains the native backend; only a small
C adapter bridges Goose slices to null-terminated C strings and marshals the
new 3D API without relying on packed-by-value C struct compatibility.

**Current milestone:** 3D cameras, primitives, raymath, managed models/meshes
and off-screen render textures, not the complete raylib API.
The backend is raylib **6.2** (tag `6.2`, commit
`02566453880e06bec97f5b8160fa6fe1e98397ca`), pinned in both the Nix flake
and CMake's SHA256-checked source fallback.

## Package structure

```
goose-raylib/
├── raylib.goose          # Goose bindings, namespace raylib
├── raymath.goose         # optional math module, namespace raymath
├── raylib.build          # native package dependency, main-thread-only
├── CMakeLists.txt        # static adapter + raylib link dependencies
├── flake.nix             # Nix devShell, raylib 6.2, Xvfb, Python
├── flake.lock            # pinned nixpkgs (reproducible)
├── src/
│   ├── raylib_adapter.h  # C adapter header
│   ├── raylib_adapter.c  # C adapter impl (strings, textures)
│   ├── raylib_3d.c/h     # scalar/borrowed-pointer 3D boundary
│   ├── raylib_math.c/h   # header-only raymath native wrappers
│   ├── raylib_models.c/h # generation-checked model/mesh ownership
│   └── raylib_render_textures.c/h # owned FBOs and checked texture modes
├── minimal.goose         # example: window + text (Phase A)
├── shapes.goose          # example: shapes, lines, circles (Phase A)
├── input.goose           # example: keyboard/mouse input (Phase A)
├── textures.goose        # example: texture metadata queries (Phase B)
├── cube3d.goose          # 3D camera, quaternion orbit, sphere/grid (120 frames)
├── models.goose          # managed generated cube, unload (120 frames)
├── meshes.goose          # generated meshes, exclusive model transfer (120 frames)
├── render_texture.goose  # off-screen 3D and scaled composition (120 frames)
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
goose build models.goose && ./models
goose build meshes.goose && ./meshes
goose build render_texture.goose && ./render_texture
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
development dependencies and pkg-config. CMake uses an installed raylib 6.2 when available;
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
# Camera/math/resource-value + compile-failure tests only (no display):
nix develop --command python3 tests/run_3d.py --headless-only
```

The runner builds C and Goose tests, checks an external consumer with no
sidecar of its own, and runs real Xvfb/llvmpipe frames with framebuffer pixel
assertions. It forces X11 rather than accidentally using the host Wayland
session. Every graphics program has a finite frame count. Command failures
and timeouts fail the suite; full logs are under `build/tests-3d/`.
The Nix shell exposes Mesa's GLX vendor library and DRI drivers explicitly,
including on non-NixOS CI hosts without `/run/opengl-driver`.
Model tests load real OBJ/MTL/PNG fixtures, assert rendered colors, and check
texture deletion through OpenGL. The runner generates the small PNG under
`build/`; no downloaded assets or replacement renderer are involved.
Mesh tests compare all seven generators' CPU data/bounds with direct raylib
calls, compare a complete transformed framebuffer with native `DrawMesh`,
and verify GPU-buffer ownership across mesh-to-model transfers.
Render-target tests compare complete framebuffers with direct native draws,
assert orientation/scale/rotation and off-screen 3D pixels, and check actual
FBO, color-texture and depth-renderbuffer deletion.

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
- **Still planned:** arbitrary mesh upload/editing and remaining generators,
  model animations, shaders/materials, additional render-target formats,
  automatic camera modes, remaining raymath operations and public rlgl bindings.
  Phase D is not complete.

### Managed models

`models.goose` is a bounded, asset-free example. Loading a file uses the same
handle API as generating a cube:

```goose
// After init_window(), before close_window():
let model = raylib::load_model("assets/model.obj");
// Or: let model = raylib::gen_model_cube(2, 2, 2);
assert(raylib::is_model_valid(model));
let bounds, valid = raylib::get_model_bounding_box(model);
assert(valid);

// Inside begin_drawing() / begin_mode_3d():
assert(raylib::draw_model(model, raylib::Vector3 { .. }, 1, raylib::WHITE));

// After drawing, while the window/context is still open:
assert(raylib::unload_model(model));
```

- `Model { let id: u64 }` contains a generation-checked token, not a native
  pointer or OpenGL ID. Copies alias one resource; unloading one invalidates
  all copies, including after its slot is reused or the window is reopened.
- Up to `MAX_MODELS` (64) models may be live. Load/generation failures return
  `Model { 0 }`. Loading requires an initialized window. Cube dimensions must
  be finite and positive. Paths are copied from slices; empty, embedded-NUL
  and overlong paths (4096 bytes or more) are rejected, not truncated.
- `draw_model`, `draw_model_ex`, `draw_model_wires`, `draw_model_wires_ex`
  return `false` for invalid/stale handles or non-finite transforms. A `true`
  result means the native draw call was issued, not that geometry is visible.
  Call them inside a drawing frame and 3D mode. `_ex` rotation is in **degrees**,
  unlike raymath. Finite zero/negative drawing scales keep raylib's semantics.
- `model_mesh_count` / `model_material_count` return zero for invalid handles.
  `get_model_bounding_box` returns `(BoundingBox, bool)`, with zeroed bounds
  and `false` on failure. Bounds do not include per-draw transforms.
- `unload_model` returns `false` for already-unloaded/invalid handles.
  `unload_all_models` returns the number released. Both meshes and owned
  material textures/shaders are released; shared IDs within a model are
  deleted once and raylib's default texture/shader are preserved. Raw native
  `UnloadModel` does not release those material GPU resources itself.
- Explicit `close_window()` (also `CloseWindow()`) releases remaining managed
  models, standalone meshes and render targets **before** destroying the
  graphics context.
  This is not RAII and does not clean up legacy texture/sound handles. Do not
  bypass it through raw C window calls. Model resources cannot yet be lent
  or replaced.
- File loading delegates to raylib's enabled native loaders. **OBJ/MTL/PNG
  and generated cubes are tested**; other file formats are not yet verified.
  Native loaders are not a sandbox for malformed/untrusted model files.
  Arbitrary mesh upload and animations remain planned; `gen_model_cube` owns
  its generated mesh internally without using a standalone mesh slot.

### Generated meshes and ownership transfer

`meshes.goose` draws a standalone sphere and transfers a cone into a model.
Declare `import raylib.raymath;` for the matrix helpers used below:

```goose
// After init_window():
let mesh = raylib::gen_mesh_sphere(1, 16, 24);
let alias = mesh;
assert(raylib::is_mesh_valid(mesh));
// Inside a drawing frame and 3D mode; default material, temporary tint:
assert(raylib::draw_mesh(mesh, raymath::matrix_identity(), raylib::BLUE));

// After drawing: a successful transfer consumes the mesh, not a deep copy.
let model = raylib::load_model_from_mesh(mesh);
assert(raylib::is_model_valid(model));
assert(!raylib::is_mesh_valid(alias));
assert(!raylib::unload_mesh(alias));  // cannot free the model's mesh
assert(raylib::unload_model(model));
```

- Generators: `gen_mesh_poly`, `gen_mesh_plane`, `gen_mesh_cube`,
  `gen_mesh_sphere`, `gen_mesh_hemi_sphere`, `gen_mesh_cylinder`, `gen_mesh_cone`.
  They call raylib's generators, including native GPU upload. A window is
  required. Dimensions/radii must be finite and positive; plane subdivisions
  are **1–128**, other side/ring/slice counts **3–128** (`MAX_MESH_SUBDIVISIONS`).
  The adapter rejects larger counts before native integer/index arithmetic
  or allocation. Invalid inputs or exhausted capacity return `Mesh { 0 }`.
- `Mesh { let id: u64 }` is a generation-checked token with a distinct kind
  tag, not a native pointer. Up to `MAX_MESHES` (64) meshes may be live,
  independently of the model table. Copies alias one resource; unloading or
  moving it invalidates every alias. Stale tokens never revive on slot reuse
  or window reopen. An alias's numeric `id` does not itself change to zero.
- `mesh_vertex_count` / `mesh_triangle_count` return zero for invalid tokens.
  `get_mesh_bounding_box` returns `(BoundingBox, bool)` with zeroed bounds on
  failure. Bounds are in local mesh space, excluding the drawing transform.
- `draw_mesh(mesh, transform, tint)` calls native `DrawMesh` with a private
  default material, not a by-value `Material` ABI. It returns `false` for
  invalid/stale handles or non-finite matrix elements. Finite matrices retain
  raylib's preconditions; a successful call does not imply visible geometry.
  Frame/3D-mode ordering is the caller's responsibility. Tints are temporary
  and do not carry over when the mesh is moved into a model.
- `load_model_from_mesh` moves the existing CPU/GPU resources without copying
  or re-uploading. **Only success consumes the source.** A full model table
  returns `Model { 0 }` and leaves a valid mesh intact so the call can be
  retried. All source aliases become invalid after success, even if their
  numeric IDs are retained. Neither double unload nor a second transfer is
  permitted; both fail safely.
- Use `unload_mesh` or transfer it to a model and later `unload_model`.
  `unload_all_meshes` returns the released standalone count; it cannot release
  already-transferred model meshes. `unload_all_models` leaves standalone
  meshes intact. Explicit window close releases both tables before GL closes.
- No borrowed model meshes/materials, arbitrary vertex access, buffer updates,
  instancing, tangents, exports, torus/knot, heightmap or cubicmap bindings yet.

### Render textures

`render_texture.goose` draws a 3D scene into a 320x180 target and composites
it into the window at 2x scale. No assets or replacement renderer are used.

```goose
// After init_window(), outside any texture mode:
let target = raylib::load_render_texture(160, 90);
assert(raylib::is_render_texture_valid(target));
assert(raylib::begin_texture_mode(target));
raylib::clear_background(raylib::BLACK);
raylib::draw_rectangle(0, 0, 160, 30, raylib::RED);
assert(raylib::end_texture_mode());

// Inside a window drawing frame: the convenience draw displays it upright.
assert(raylib::draw_render_texture(target, 20, 20, raylib::WHITE));
// After drawing, before close_window():
assert(raylib::unload_render_texture(target));
```

- `RenderTexture2D { let id: u64 }` (`RenderTexture` is an alias) is a checked
  generation/kind token, **not** the native struct or a raw framebuffer ID.
  It owns its FBO, RGBA8 color texture and depth renderbuffer in C. Attachments
  are not lent as legacy `Texture2D` values, preventing independent unloads.
- `load_render_texture` needs a live window, dimensions **1–4096** and a free
  slot among `MAX_RENDER_TEXTURES` (64). Invalid input, capacity exhaustion or
  an invalid/incomplete native FBO returns `RenderTexture2D { 0 }`. Dimension
  limits do not guarantee that a particular GPU can allocate every target.
  `render_texture_width` / `render_texture_height` return zero for stale or
  invalid tokens. Copies alias one target; generations survive window reopen.
- `begin_texture_mode` / `end_texture_mode` return bool. Modes **do not nest**;
  invalid/nested begins and an unmatched end fail without altering the current
  target. `is_texture_mode_active` reports the managed mode. Normal raylib
  frame/2D/3D ordering is still the caller's responsibility.
- All target creation/unload operations are rejected while any managed texture
  mode is active, even for another target: native loaders/unloaders change FBO
  bindings. `unload_all_render_textures` returns zero when blocked. Drawing
  another target into the active one is allowed; sampling the active target
  into itself is rejected to avoid an undefined GPU feedback loop.
- `draw_render_texture(target, x, y, tint)` calls `DrawTextureRec` with the
  whole target and an automatic vertical flip, upright at 1:1 scale.
  `draw_render_texture_pro(target, source, dest, origin, rotation, tint)`
  retains native `DrawTexturePro` rectangle/origin conventions: use a **negative
  source height** for upright FBO contents. Rotation is in **degrees**. It
  rejects non-finite parameters; other native drawing preconditions remain.
- `unload_render_texture` returns false for invalid/stale handles; bulk unload
  returns the released count. Pending texture draws are flushed before GPU
  attachments are deleted, including an unload before `end_drawing`. Explicit
  `close_window()` / `CloseWindow()` ends an active managed texture mode and
  releases all targets before destroying GL. There are still no destructors.
- Custom target formats (`LoadRenderTextureEx`), raw/borrowed attachments,
  attachment replacement, depth sampling and shader/material bindings remain
  planned. Raw C framebuffer/mode manipulation bypasses this ownership contract.

### raymath — vectors, matrices and quaternions

The optional `raylib.raymath` module has its own `raymath` namespace and uses
the actual header-only raymath implementation from the pinned raylib 6.2
release. It does not assume inline functions are exported by `libraylib`.

```goose
import raylib from "../goose-raylib";
import raylib.raymath;

fn main() {
    let point = raylib::Vector3 { 1, 0, 0 };
    let rotation = raymath::quaternion_from_axis_angle(
        raylib::Vector3 { 0, 0, 1 }, raymath::PI / 2,
    );
    let result = raymath::vector3_transform(point, raymath::quaternion_to_matrix(rotation));
    print(result);  // approximately Vector3 { 0, 1, 0 }
}
```

- **Vector3:** add, subtract, scale, dot, length, cross, normalize, transform,
  lerp (`vector3_*`). Vector3 and Matrix aliases reuse the raylib value types.
- **Matrix:** identity, translate, scale, rotate_xyz, multiply, invert,
  perspective, ortho, look_at (`matrix_*`). Composition order is exactly
  upstream raymath's order; tests include non-commuting transforms.
- **Quaternion:** identity, normalize, multiply, slerp, from_axis_angle,
  to_matrix, from_matrix (`quaternion_*`); packed x/y/z/w fields.
- Angles are **radians**. `matrix_perspective` / `matrix_ortho` retain the
  upstream f64 inputs; output matrices use f32. Existing upstream input
  preconditions apply, including for singular-matrix inversion.
- No display is needed, but the module currently inherits the package's
  main-thread-only restriction. JIT remains subject to the limitation above.

All 25 implemented operations are tested in C and Goose. The complete
[raymath function inventory](docs/RAYMATH_STATUS.md) lists all 146 RMAPI
functions, including the 121 still planned. Update/check it with:

```bash
nix develop --command python3 tools/raymath_inventory.py --check
# After implementing and testing another operation:
nix develop --command python3 tools/raymath_inventory.py --write
```

See `docs/API_STATUS.md` for the full implementation status.

## Examples

A separate **Pong** game is being developed here:

https://github.com/flakesonnix/goose-pong

## Important notes

- **No automatic resource cleanup:** Goose has no destructors/RAII.
  Resources (textures, sounds, …) must be explicitly released with `unload_*`.
  Managed models/meshes/render targets also have an explicit cleanup boundary
  at `close_window()`.
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
