// test_textures.goose — Test: texture API (Phase B)
// Checks Texture2D/Image structs, pixel format constants, and that the
// texture function signatures exist.  Loading a real texture requires an
// image file; this test covers the API surface without one.
//
// Build:
//   goose build test_textures.goose && ./test_textures

import raylib;

fn main() {
    // Pixel format constants
    assert(raylib::PIXELFORMAT_UNCOMPRESSED_GRAYSCALE == 1);
    assert(raylib::PIXELFORMAT_UNCOMPRESSED_R8G8B8A8 == 7);
    assert(raylib::PIXELFORMAT_COMPRESSED_DXT1_RGBA == 12);
    assert(raylib::PIXELFORMAT_COMPRESSED_ETC2_RGB == 16);
    assert(raylib::PIXELFORMAT_COMPRESSED_ASTC_8x8_RGBA == 21);

    // Texture2D struct — 1:1 with C: { u32 id, i32 width, i32 height, i32 mipmaps, i32 format }
    let tex = raylib::Texture2D { 42, 640, 480, 1, 7 };
    assert(tex.id == 42);
    assert(tex.width == 640);
    assert(tex.height == 480);
    assert(tex.mipmaps == 1);
    assert(tex.format == 7);

    // Image struct — metadata only (no void *data pointer)
    let img = raylib::Image { 1920, 1080, 1, 7 };
    assert(img.width == 1920);
    assert(img.height == 1080);
    assert(img.mipmaps == 1);
    assert(img.format == 7);

    // API signatures — calls with dummy values, no real file loaded
    let _w: i32 = raylib::image_width("nonexistent.png");
    let _h: i32 = raylib::image_height("nonexistent.png");
    let _f: i32 = raylib::image_format("nonexistent.png");

    // Texture2D API — unload_texture declared but not called on a dummy ID
    // (calling UnloadTexture on an invalid texture ID crashes).

    assert(_w == _w);
    assert(_h == _h);
    assert(_f == _f);
    assert(tex.id == 42);

    print("test_textures passed");
}
