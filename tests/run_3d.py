#!/usr/bin/env python3
"""3D regression tests using the real Goose compiler and raylib backend."""

import argparse
import json
import os
from pathlib import Path
import shlex
import shutil
import struct
import subprocess
import sys
import zlib

ROOT = Path(__file__).resolve().parent.parent
BUILD = ROOT / "build" / "tests-3d"


def model_fixtures():
    """Real OBJ/MTL/PNG assets, without adding generated binaries to source."""
    assets = BUILD / "model-assets"
    assets.mkdir(exist_ok=True)
    for source in (ROOT / "tests" / "assets").iterdir():
        if source.suffix in (".obj", ".mtl"):
            shutil.copyfile(source, assets / source.name)

    def chunk(kind, data):
        return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data))

    # Uniform opaque RGBA (60, 120, 200); the graphics test asserts the pixel.
    rows = (b"\0" + bytes((60, 120, 200, 255)) * 2) * 2
    png = (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", 2, 2, 8, 6, 0, 0, 0))
           + chunk(b"IDAT", zlib.compress(rows)) + chunk(b"IEND", b""))
    (assets / "albedo.png").write_bytes(png)
    return assets


def run(name, command, *, expected_error=None, marker=None, env=None):
    print(f"{name}: {shlex.join(map(str, command))}", flush=True)
    result = subprocess.run(
        list(map(str, command)), cwd=ROOT, env=env, text=True,
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=300,
    )
    (BUILD / f"{name}.log").write_text(result.stdout)
    if expected_error is not None:
        ok = result.returncode != 0 and expected_error in result.stdout
    else:
        ok = result.returncode == 0 and (marker is None or marker in result.stdout)
    if not ok:
        sys.stdout.write(result.stdout)
        raise RuntimeError(f"{name}: unexpected exit {result.returncode}; see {BUILD / (name + '.log')}")
    print(f"PASS: {name}", flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--headless-only", action="store_true", help="skip OpenGL tests, not needed for camera math")
    parser.add_argument("--jit", action="store_true", help="also test in-process execution (requires configured TinyCC headers)")
    args = parser.parse_args()
    goose = shutil.which(os.environ.get("GOOSE", "goose"))
    if not goose:
        parser.error("set GOOSE to an existing Goose executable, or add goose to PATH")
    BUILD.mkdir(parents=True, exist_ok=True)

    run("cmake-configure", ["cmake", "-S", ROOT, "-B", BUILD / "native", "-DCMAKE_BUILD_TYPE=Debug"])
    run("cmake-build", ["cmake", "--build", BUILD / "native", "--parallel", "2"])
    run("c-adapter", ["ctest", "--test-dir", BUILD / "native", "--output-on-failure"], marker="100% tests passed")
    run("raymath-inventory", [sys.executable, "tools/raymath_inventory.py", "--check"])
    for source in ["raylib.goose", "raymath.goose", "cube3d.goose", "models.goose", "meshes.goose", "test_3d.goose",
                   "tests/math.goose", "tests/model_values.goose", "tests/models.goose", "tests/mesh_values.goose",
                   "tests/meshes.goose", "tests/graphics_3d.goose"]:
        run("check-" + source.removesuffix(".goose").replace("/", "-"), [goose, "check", source])
    run("wrong-vector", [goose, "check", "tests/invalid_3d.goose"], expected_error="cannot pass raylib::Vector2 as raylib::Vector3")
    run("wrong-thread", [goose, "check", "tests/invalid_3d_thread.goose"], expected_error="raylib runs on the main thread only")
    run("wrong-matrix", [goose, "check", "tests/invalid_math.goose"], expected_error="cannot pass raylib::Vector3 as raylib::Matrix")
    run("wrong-quaternion", [goose, "check", "tests/invalid_quaternion.goose"], expected_error="cannot pass raylib::Vector3 as raymath::Quaternion")
    run("wrong-model", [goose, "check", "tests/invalid_model.goose"], expected_error="cannot pass raylib::Sound as raylib::Model")
    run("readonly-model-id", [goose, "check", "tests/invalid_model_id.goose"], expected_error="cannot assign to let id")
    run("wrong-model-thread", [goose, "check", "tests/invalid_model_thread.goose"], expected_error="raylib runs on the main thread only")
    run("wrong-mesh", [goose, "check", "tests/invalid_mesh.goose"], expected_error="cannot pass raylib::Model as raylib::Mesh")
    run("readonly-mesh-id", [goose, "check", "tests/invalid_mesh_id.goose"], expected_error="cannot assign to let id")
    run("wrong-mesh-matrix", [goose, "check", "tests/invalid_mesh_matrix.goose"], expected_error="cannot pass raylib::Vector3 as raylib::Matrix")
    run("wrong-mesh-thread", [goose, "check", "tests/invalid_mesh_thread.goose"], expected_error="raylib runs on the main thread only")

    for flags, name in [([], "camera-native"), (["--debug"], "camera-debug")]:
        run(name + "-build", [goose, "build", *flags, "-o", BUILD / name, "test_3d.goose"])
        run(name, [BUILD / name], marker="test_3d passed")
    for flags, name in [([], "math-native"), (["--debug"], "math-debug")]:
        run(name + "-build", [goose, "build", *flags, "-o", BUILD / name, "tests/math.goose"])
        run(name, [BUILD / name], marker="raymath passed")
    for flags, name in [([], "model-values"), (["--debug"], "model-values-debug")]:
        run(name + "-build", [goose, "build", *flags, "-o", BUILD / name, "tests/model_values.goose"])
        run(name, [BUILD / name], marker="model values passed")
    for flags, name in [([], "mesh-values"), (["--debug"], "mesh-values-debug")]:
        run(name + "-build", [goose, "build", *flags, "-o", BUILD / name, "tests/mesh_values.goose"])
        run(name, [BUILD / name], marker="mesh values passed")

    # A consumer outside the package root, with no copied bindings or sidecar.
    consumer = BUILD / "consumer.goose"
    consumer.write_text(
        f"import raylib from {json.dumps(str(ROOT))};\n"
        "import raylib.raymath;\n"
        "fn main() {\n"
        "  let c = raylib::Camera3D { position: raylib::Vector3 { 0, 0, 5 },\n"
        "      target: raylib::Vector3 { .. }, up: raylib::Vector3 { 0, 1, 0 },\n"
        "      fovy: 45, projection: raylib::CAMERA_PERSPECTIVE };\n"
        "  assert(raylib::get_camera_matrix(c).m14 == -5);\n"
        "  assert(raymath::matrix_identity().m15 == 1);\n"
        "  assert(raymath::quaternion_identity().w == 1);\n"
        "  assert(!raylib::is_model_valid(raylib::gen_model_cube(1, 1, 1)));\n"
        "  let bounds, valid = raylib::get_model_bounding_box(raylib::Model { .. });\n"
        "  assert(!valid && bounds.min.x == 0);\n"
        "  let mesh = raylib::gen_mesh_cube(1, 1, 1);\n"
        "  assert(!raylib::is_mesh_valid(mesh) && mesh.id == 0);\n"
        "  assert(raylib::load_model_from_mesh(mesh).id == 0);\n"
        '  print("external consumer passed");\n}\n'
    )
    run("consumer-build", [goose, "build", "-o", BUILD / "consumer", consumer])
    run("consumer", [BUILD / "consumer"], marker="external consumer passed")
    if args.jit:
        run("camera-jit", [goose, "run", "test_3d.goose"], marker="test_3d passed")
        run("math-jit", [goose, "run", "tests/math.goose"], marker="raymath passed")
        run("model-values-jit", [goose, "run", "tests/model_values.goose"], marker="model values passed")
        run("mesh-values-jit", [goose, "run", "tests/mesh_values.goose"], marker="mesh values passed")
    else:
        print("NOT RUN: JIT (opt in with --jit; see README for the TinyCC limitation)")

    if args.headless_only:
        print("NOT RUN: graphics (--headless-only requested)")
        return
    if not shutil.which("xvfb-run"):
        parser.error("xvfb-run is required for graphics tests; enter nix develop or use --headless-only")
    env = os.environ.copy()
    for key in ("DISPLAY", "WAYLAND_DISPLAY", "WAYLAND_SOCKET"):
        env.pop(key, None)
    env.update(XDG_SESSION_TYPE="x11", LIBGL_ALWAYS_SOFTWARE="1", GALLIUM_DRIVER="llvmpipe")
    # Keep the server alive when GLFW closes its last X connection: otherwise
    # immediate window reopen can race Xvfb's automatic last-client reset.
    xvfb = ["xvfb-run", "-a", "-e", "/dev/stderr", "-s", "-screen 0 1024x768x24 +extension GLX -noreset"]
    assets = model_fixtures()
    run("model-c-lifecycle", [*xvfb, BUILD / "native" / "test_model_adapter", "--graphics", assets],
        env=env, marker="model adapter graphics passed")
    run("mesh-c-lifecycle", [*xvfb, BUILD / "native" / "test_mesh_adapter", "--graphics"],
        env=env, marker="mesh adapter graphics passed")
    for flags, name in [([], "models-native"), (["--debug"], "models-debug")]:
        run(name + "-build", [goose, "build", *flags, "-o", BUILD / name, "tests/models.goose"])
        run(name, [*xvfb, BUILD / name], env=env, marker="models passed")
    for flags, name in [([], "meshes-native"), (["--debug"], "meshes-debug")]:
        run(name + "-build", [goose, "build", *flags, "-o", BUILD / name, "tests/meshes.goose"])
        run(name, [*xvfb, BUILD / name], env=env, marker="meshes passed")
    run("graphics-build", [goose, "build", "-o", BUILD / "graphics", "tests/graphics_3d.goose"])
    run("graphics-native", [*xvfb, BUILD / "graphics"], env=env, marker="3d graphics passed")
    # Ensure that this did not accidentally connect to a user's Wayland display.
    graphics_log = (BUILD / "graphics-native.log").read_text()
    if "GLFW - X11" not in graphics_log or "llvmpipe" not in graphics_log:
        raise RuntimeError("graphics did not use the requested Xvfb/software rendering environment")
    if args.jit:
        run("graphics-jit", [*xvfb, goose, "run", "tests/graphics_3d.goose"], env=env, marker="3d graphics passed")
        run("models-jit", [*xvfb, goose, "run", "tests/models.goose"], env=env, marker="models passed")
        run("meshes-jit", [*xvfb, goose, "run", "tests/meshes.goose"], env=env, marker="meshes passed")
    run("cube-build", [goose, "build", "-o", BUILD / "cube3d", "cube3d.goose"])
    run("cube-example", [*xvfb, BUILD / "cube3d"], env=env, marker="Window closed successfully")
    for name in ("minimal", "shapes", "input", "models", "meshes", "textures"):
        run(name + "-build", [goose, "build", "-o", BUILD / name, name + ".goose"])
        run(name + "-regression", [*xvfb, BUILD / name], env=env, marker="Window closed successfully")
    print("3D native, adapter, external-import, compile-failure and graphics tests passed.")


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, subprocess.TimeoutExpired) as error:
        sys.exit(str(error))
