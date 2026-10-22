# goose-raylib — Architecture and technical limitations

## 1. Goal

A standalone, reusable Goose package `goose-raylib` that exposes the raylib
C-API to Goose via `extern fn`. raylib remains the native backend (no
reimplementation of the rendering engine). Only as much native adapter code
as needed for safe ABI transitions is written.

## 2. Package structure (repository root)

```
goose-raylib/
├── raylib.goose          # Goose bindings, namespace raylib
├── raylib.build          # Goose C sidecar (c_libs, c_sources)
├── flake.nix             # Nix devShell (cmake, gcc, raylib, git)
├── src/
│   ├── raylib_adapter.h  # C adapter header
│   └── raylib_adapter.c  # C adapter impl (strings, handles)
├── minimal.goose         # example: window + text (Phase A)
├── shapes.goose          # example: shapes, lines, circles (Phase A)
├── input.goose           # example: keyboard/mouse input (Phase A)
├── cube3d.goose          # bounded 3D example; Pong lives in flakesonnix/goose-pong
├── test_window.goose     # test: window smoke test
├── test_shapes.goose     # test: shapes / colors
├── test_strings.goose    # test: string conversion
├── test_input.goose      # test: input
├── test_resources.goose  # test: resources load/free
├── docs/
│   ├── ARCHITECTURE.md   # this file
│   └── API_STATUS.md     # implementation status per API element
└── README.md             # build, import, usage guide
```

## 3. ABI risks and solutions

| Problem | Cause | Solution |
|---|---|---|
| Strings | Goose `const u8[:]` is a `{ data, len }` slice, not a null-terminated `const char *` | C adapter `rl_text(const u8[:])` copies into a buffer and appends `\0` before calling raylib |
| 3D structs | Goose `struct` is packed; matching fields alone do not prove a C calling ABI | New 3D calls pass scalars or borrowed fixed-size pointers. The adapter reconstructs native structs. |
| bool | This Goose compiler emits `uint8_t` for `bool` | New test-support boolean functions return `uint8_t`. Legacy audio wrappers still return C `int` and need separate ABI cleanup. |
| Resources | Native resources can contain C pointers | `Sound` uses an adapter handle. Legacy `Texture2D` is passed by value; generation/lifetime validation is still outstanding. |
| Callbacks | Goose has no runtime-generated function pointers | Not supported (documented openly); static C trampolines only if needed |
| Return values | Goose allows one scalar or flat fixed-size value | raylib functions returning complex structs use out-parameters via adapter |

## 4. String conversion (adapter)

Goose passes strings as slices `{ data: *u8, len: i64 }`. raylib expects
null-terminated `const char *` strings. The adapter:

1. Takes `data` and `len`.
2. Copies `len` bytes into a static buffer.
3. Sets `buffer[len] = '\0'`.
4. Calls raylib with `buffer`.

Lifetime: the buffer is valid only during the C call, which is sufficient
because raylib copies strings internally where it needs to keep them.

## 5. Naming conventions

- raylib C names: `InitWindow`, `DrawText`, … (PascalCase)
- Goose names: `init_window`, `draw_text`, … (snake_case)
- Namespace: `raylib` → calls as `raylib::init_window(...)`
- Constants: `RAYWHITE`, `BLACK`, … (uppercase, as in raylib)
- Documentation: each Goose function names the original raylib C counterpart.

## 6. Development phases (see docs/API_STATUS.md)

Phase A (current): window, main loop, background, shapes, lines, circles,
text, keyboard/mouse, FPS.
Phase B: images, textures, fonts.
Phase C: audio, gamepads.
Phase D: 3D (cameras, vectors, meshes, models, shaders).
Phase E: remaining public API (file I/O, logging, collision, …).

## 7. Build

- `import raylib from "path-or-pinned-repository";` assigns the declarations
  to the raylib package. A bare local import loads declarations only; it does
  not automatically activate another file's sidecar.
- `raylib.build` names the static CMake target `goose_raylib` and marks it
  main-thread-only. CMake carries raylib's native link dependencies; consumers
  need neither copied adapter sources nor per-program `-lraylib` settings.
- CMake uses an installed raylib 6.2 or a commit-and-SHA256-pinned archive.
  The Nix flake builds that same upstream source from its locked input.
- Goose can build a package symbol library for JIT. Actual JIT execution is
  not yet verified: the local embedded TinyCC lacks NixOS system-header paths.
  `C_INCLUDE_PATH` is consumed by the TinyCC CLI, not by Goose's libtcc runner.
- From this repository: `nix develop` provides the native compiler, CMake,
  raylib 6.2, Python and Xvfb. Goose itself is supplied by the caller.

### 3D boundary (`src/raylib_3d.c`)

- Scalar coordinates, dimensions and an unsigned `0xRRGGBBAA` color avoid
  platform-dependent by-value struct passing entirely for the new draw calls.
- `const Camera3D&` is a borrowed pointer to ten f32 values and one i32
  projection (44 bytes). C decodes the fields with `memcpy`, never by casting
  to a native `Camera3D*`. The pointer is never retained.
- View matrices (64 bytes), rays (24 bytes) and screen coordinates (8 bytes)
  are written into typed Goose out parameters, field by field in declaration
  order. Camera updates use the same representation in both directions.
- C tests compare real raylib results for both projections using deliberately
  unaligned input/output buffers and canaries. Goose tests exercise the actual
  generated calling convention and pixel readback, not just typechecking.
- `init_window` now uses the existing string conversion adapter too. The
  graphics test uses a non-NUL-terminated title subslice. The pre-existing
  4096-byte conversion limit remains; improving that is separate work.

### raymath boundary (`src/raylib_math.c`)

`raymath.goose` is an optional module of the same native package, declaring
the flat namespace `raymath`. Vector3 and Matrix are aliases of the existing
Goose types; Quaternion is x/y/z/w f32 (16 bytes).

The adapter defines `RAYMATH_STATIC_INLINE` and includes the unchanged
upstream `raymath.h`, rather than looking up nonexistent exported inline
symbols or reimplementing formulas. The CMake target includes this adapter
and propagates libm where needed. All borrowed packed inputs are decoded
with `memcpy`; vector/quaternion/matrix results use typed Goose out
parameters. Matrix reads and writes both follow the explicit named-field
declaration order, with no native struct pointer cast.

Angles are radians and projection scalar inputs preserve upstream f64.
These stateless calculations do not need an initialized window, although
the current package-level main-thread restriction still applies. The
header-based inventory covers every RMAPI C function; only tested wrappers
are marked implemented.

## 8. Out of scope (for now)

- No automatic resource cleanup (no RAII/destructors in Goose).
- No changes to the Goose compiler.
- No `goose_gfx`-based design.
- No Windows/macOS guarantees without actual testing.
