#!/usr/bin/env python3
"""3D regression tests using the real Goose compiler and raylib backend."""

import argparse
import json
import os
from pathlib import Path
import shlex
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parent.parent
BUILD = ROOT / "build" / "tests-3d"


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
    for source in ["raylib.goose", "cube3d.goose", "test_3d.goose", "tests/graphics_3d.goose"]:
        run("check-" + Path(source).stem, [goose, "check", source])
    run("wrong-vector", [goose, "check", "tests/invalid_3d.goose"], expected_error="cannot pass raylib::Vector2 as raylib::Vector3")
    run("wrong-thread", [goose, "check", "tests/invalid_3d_thread.goose"], expected_error="raylib runs on the main thread only")

    for flags, name in [([], "camera-native"), (["--debug"], "camera-debug")]:
        run(name + "-build", [goose, "build", *flags, "-o", BUILD / name, "test_3d.goose"])
        run(name, [BUILD / name], marker="test_3d passed")

    # A consumer outside the package root, with no copied bindings or sidecar.
    consumer = BUILD / "consumer.goose"
    consumer.write_text(
        f"import raylib from {json.dumps(str(ROOT))};\n"
        "fn main() {\n"
        "  let c = raylib::Camera3D { position: raylib::Vector3 { 0, 0, 5 },\n"
        "      target: raylib::Vector3 { .. }, up: raylib::Vector3 { 0, 1, 0 },\n"
        "      fovy: 45, projection: raylib::CAMERA_PERSPECTIVE };\n"
        "  assert(raylib::get_camera_matrix(c).m14 == -5);\n"
        '  print("external consumer passed");\n}\n'
    )
    run("consumer-build", [goose, "build", "-o", BUILD / "consumer", consumer])
    run("consumer", [BUILD / "consumer"], marker="external consumer passed")
    if args.jit:
        run("camera-jit", [goose, "run", "test_3d.goose"], marker="test_3d passed")
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
    xvfb = ["xvfb-run", "-a", "-e", "/dev/stderr", "-s", "-screen 0 1024x768x24 +extension GLX"]
    run("graphics-build", [goose, "build", "-o", BUILD / "graphics", "tests/graphics_3d.goose"])
    run("graphics-native", [*xvfb, BUILD / "graphics"], env=env, marker="3d graphics passed")
    # Ensure that this did not accidentally connect to a user's Wayland display.
    graphics_log = (BUILD / "graphics-native.log").read_text()
    if "GLFW - X11" not in graphics_log or "llvmpipe" not in graphics_log:
        raise RuntimeError("graphics did not use the requested Xvfb/software rendering environment")
    if args.jit:
        run("graphics-jit", [*xvfb, goose, "run", "tests/graphics_3d.goose"], env=env, marker="3d graphics passed")
    run("cube-build", [goose, "build", "-o", BUILD / "cube3d", "cube3d.goose"])
    run("cube-example", [*xvfb, BUILD / "cube3d"], env=env, marker="Window closed successfully")
    for name in ("minimal", "shapes", "input"):
        run(name + "-build", [goose, "build", "-o", BUILD / name, name + ".goose"])
        run(name + "-regression", [*xvfb, BUILD / name], env=env, marker="Window closed successfully")
    print("3D native, adapter, external-import, compile-failure and graphics tests passed.")


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, subprocess.TimeoutExpired) as error:
        sys.exit(str(error))
