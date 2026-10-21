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
├── pong.goose            # example: Pong (Definition of Done)
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
| Structs | Goose `struct` is packed, no padding guarantees like C | Goose structs declared exactly like C (same order, same types); `pad` where needed |
| bool | Goose `bool` vs. C `int` | Adapter uses `int` internally, converts where needed |
| Resources | Complex raylib resources (`Texture2D`, `Sound`, …) are C structs, not opaque pointers in Goose | Passed as Goose `struct` by value (packed, 1:1 C layout); `unload_*` is explicit |
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

- `goose build` uses `raylib.build` with `c_libs = ["raylib"]` (provided via Nix).
- `goose run` builds the C adapter into an in-process loaded library.
- `nix develop goose-raylib/` provides `cmake`, `gcc`, `raylib`, `git`.

## 8. Out of scope (for now)

- No automatic resource cleanup (no RAII/destructors in Goose).
- No changes to the Goose compiler.
- No `goose_gfx`-based design.
- No Windows/macOS guarantees without actual testing.
