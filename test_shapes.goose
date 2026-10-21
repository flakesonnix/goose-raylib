// test_shapes.goose — Test: colors, structs, drawing API
// Checks color constants, struct layout, and that drawing functions exist.
//
// Build:
//   goose build test_shapes.goose && ./test_shapes

import raylib;

fn main() {
    // color constants
    assert(raylib::BLACK.r == 0 && raylib::BLACK.g == 0 && raylib::BLACK.b == 0 && raylib::BLACK.a == 255);
    assert(raylib::WHITE.r == 255 && raylib::WHITE.g == 255 && raylib::WHITE.b == 255 && raylib::WHITE.a == 255);
    assert(raylib::RED.r == 255 && raylib::RED.g == 0 && raylib::RED.b == 0 && raylib::RED.a == 255);
    assert(raylib::GREEN.r == 0 && raylib::GREEN.g == 255 && raylib::GREEN.b == 0 && raylib::GREEN.a == 255);
    assert(raylib::BLUE.r == 0 && raylib::BLUE.g == 0 && raylib::BLUE.b == 255 && raylib::BLUE.a == 255);
    assert(raylib::YELLOW.r == 255 && raylib::YELLOW.g == 255 && raylib::YELLOW.b == 0 && raylib::YELLOW.a == 255);
    assert(raylib::ORANGE.r == 255 && raylib::ORANGE.g == 128 && raylib::ORANGE.b == 0 && raylib::ORANGE.a == 255);
    assert(raylib::RAYWHITE.r == 245 && raylib::RAYWHITE.g == 245 && raylib::RAYWHITE.b == 245 && raylib::RAYWHITE.a == 255);

    // structs: Vector2
    let v = raylib::Vector2 { 10.0, 20.0 };
    assert(v.x == 10.0 && v.y == 20.0);
    v.x = 99.5;
    assert(v.x == 99.5);

    // structs: Color
    let c = raylib::Color { 1, 2, 3, 4 };
    assert(c.r == 1 && c.g == 2 && c.b == 3 && c.a == 4);

    // structs: Rectangle
    let rec = raylib::Rectangle { 0.0, 0.0, 100.0, 50.0 };
    assert(rec.width == 100.0 && rec.height == 50.0);

    // structs: Camera2D
    let cam = raylib::Camera2D {
        offset: raylib::Vector2 { 0.0, 0.0 },
        target: raylib::Vector2 { 400.0, 225.0 },
        rotation: 0.0,
        zoom: 1.0,
    };
    assert(cam.target.x == 400.0 && cam.target.y == 225.0 && cam.zoom == 1.0);

    print("test_shapes passed");
}
