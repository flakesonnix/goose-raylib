// Real off-screen drawing, FBO orientation, compositing, 3D and resource guards.
import raylib from "..";
extern fn grl_test_pixel(x: i32, y: i32) -> u32;

fn dead(target: raylib::RenderTexture2D) {
    assert(!raylib::is_render_texture_valid(target));
    assert(!raylib::begin_texture_mode(target) && !raylib::unload_render_texture(target));
    assert(raylib::render_texture_width(target) == 0 && raylib::render_texture_height(target) == 0);
    assert(!raylib::draw_render_texture(target, 0, 0, raylib::WHITE));
    assert(!raylib::draw_render_texture_pro(target, raylib::Rectangle { 0, 0, 1, -1 },
        raylib::Rectangle { 0, 0, 1, 1 }, raylib::Vector2 { .. }, 0, raylib::WHITE));
}
fn main() {
    raylib::set_config_flags(0x80);
    raylib::init_window(320, 240, "managed render textures");
    assert(raylib::is_window_ready());
    dead(raylib::RenderTexture2D { 0xFFFFFFFFFFFFFFFF });
    dead(raylib::RenderTexture2D { 0x0000000140000041 });
    assert(raylib::load_render_texture(0, 24).id == 0);
    assert(raylib::load_render_texture(32, -1).id == 0);
    assert(raylib::load_render_texture(raylib::MAX_RENDER_TEXTURE_SIZE + 1, 1).id == 0);
    assert(!raylib::end_texture_mode());
    let first = raylib::load_render_texture(32, 24);
    let alias: raylib::RenderTexture = first;
    let second = raylib::load_render_texture(80, 40);
    assert(raylib::is_render_texture_valid(first) && raylib::is_render_texture_valid(second));
    assert(raylib::render_texture_width(first) == 32 && raylib::render_texture_height(first) == 24);
    assert(!raylib::is_model_valid(raylib::Model { first.id }));
    assert(!raylib::is_mesh_valid(raylib::Mesh { first.id }));
    let model = raylib::gen_model_cube(1, 1, 1);
    let mesh = raylib::gen_mesh_cube(1, 1, 1);
    dead(raylib::RenderTexture2D { model.id });
    dead(raylib::RenderTexture2D { mesh.id });
    assert(raylib::unload_model(model) && raylib::unload_mesh(mesh));

    assert(raylib::begin_texture_mode(first));
    assert(raylib::is_texture_mode_active());
    assert(!raylib::begin_texture_mode(second) && !raylib::begin_texture_mode(first));
    assert(!raylib::unload_render_texture(first) && !raylib::unload_render_texture(second));
    assert(raylib::unload_all_render_textures() == 0 && raylib::load_render_texture(8, 8).id == 0);
    assert(!raylib::draw_render_texture(first, 0, 0, raylib::WHITE));
    assert(!raylib::draw_render_texture_pro(first, raylib::Rectangle { 0, 0, 32, -24 },
        raylib::Rectangle { 0, 0, 32, 24 }, raylib::Vector2 { .. }, 0, raylib::WHITE));
    assert(raylib::is_texture_mode_active());
    raylib::clear_background(raylib::WHITE);
    raylib::draw_rectangle(0, 0, 32, 9, raylib::RED);
    raylib::draw_rectangle(0, 9, 32, 15, raylib::GREEN);
    raylib::draw_rectangle(24, 0, 8, 24, raylib::BLUE);
    assert(raylib::end_texture_mode() && !raylib::end_texture_mode());
    assert(!raylib::is_texture_mode_active());
    assert(raylib::begin_texture_mode(second));
    raylib::clear_background(raylib::BLACK);
    assert(raylib::draw_render_texture(first, 4, 6, raylib::WHITE));
    assert(raylib::end_texture_mode());

    raylib::begin_drawing();
    raylib::clear_background(raylib::RAYWHITE);
    assert(raylib::draw_render_texture(first, 4, 5, raylib::WHITE));  // convenience flips upright
    assert(raylib::draw_render_texture_pro(first, raylib::Rectangle { 0, 0, 32, -24 },
        raylib::Rectangle { 64, 16, 96, 72 }, raylib::Vector2 { .. }, 0, raylib::WHITE));
    assert(raylib::draw_render_texture_pro(first, raylib::Rectangle { 0, 0, 32, -24 },
        raylib::Rectangle { 220, 40, 64, 48 }, raylib::Vector2 { .. }, 90, raylib::WHITE));
    assert(raylib::draw_render_texture(second, 0, 120, raylib::WHITE));
    assert(grl_test_pixel(9, 8) == raylib::color_rgba(raylib::RED));
    assert(grl_test_pixel(9, 25) == raylib::color_rgba(raylib::GREEN));
    assert(grl_test_pixel(33, 8) == raylib::color_rgba(raylib::BLUE));
    assert(grl_test_pixel(79, 25) == raylib::color_rgba(raylib::RED));
    assert(grl_test_pixel(79, 76) == raylib::color_rgba(raylib::GREEN));
    assert(grl_test_pixel(151, 25) == raylib::color_rgba(raylib::BLUE));
    assert(grl_test_pixel(214, 50) == raylib::color_rgba(raylib::RED));
    assert(grl_test_pixel(180, 50) == raylib::color_rgba(raylib::GREEN));
    assert(grl_test_pixel(214, 98) == raylib::color_rgba(raylib::BLUE));
    assert(grl_test_pixel(9, 129) == raylib::color_rgba(raylib::RED));
    assert(grl_test_pixel(9, 146) == raylib::color_rgba(raylib::GREEN));
    assert(grl_test_pixel(70, 155) == raylib::color_rgba(raylib::BLACK));
    raylib::draw_rectangle(300, 220, 20, 20, raylib::YELLOW);  // default viewport/projection restored
    assert(grl_test_pixel(310, 230) == raylib::color_rgba(raylib::YELLOW));
    raylib::end_drawing();

    let tint = raylib::Color { 23, 174, 211, 255 };
    let camera = raylib::Camera3D {
        position: raylib::Vector3 { 0, 0, 5 }, target: raylib::Vector3 { .. },
        up: raylib::Vector3 { 0, 1, 0 }, fovy: 45, projection: raylib::CAMERA_PERSPECTIVE,
    };
    assert(raylib::begin_texture_mode(first));
    raylib::clear_background(raylib::BLACK);
    raylib::begin_mode_3d(camera);
    raylib::draw_cube(0, 0, 0, 2, 2, 2, tint);
    raylib::end_mode_3d();
    assert(raylib::end_texture_mode());
    raylib::begin_drawing();
    raylib::clear_background(raylib::RAYWHITE);
    assert(raylib::draw_render_texture(first, 20, 30, raylib::WHITE));
    assert(raylib::unload_render_texture(first));  // flush queued samples before deleting attachments
    assert(grl_test_pixel(36, 42) == raylib::color_rgba(tint));
    assert(grl_test_pixel(21, 31) == raylib::color_rgba(raylib::BLACK));
    dead(alias);
    assert(raylib::is_render_texture_valid(second));
    assert(raylib::draw_render_texture(second, 140, 100, raylib::WHITE));
    assert(raylib::unload_all_render_textures() == 1);
    assert(grl_test_pixel(149, 109) == raylib::color_rgba(raylib::RED));
    raylib::end_drawing();
    dead(second);
    let replacement = raylib::load_render_texture(1, 1);
    assert(replacement.id != alias.id && (replacement.id & 0xFFFFFFFF) == (alias.id & 0xFFFFFFFF));
    dead(alias);
    assert(raylib::unload_render_texture(replacement));
    assert(raylib::unload_all_render_textures() == 0);

    var full: raylib::RenderTexture2D[>..] = [];
    for i in 0..raylib::MAX_RENDER_TEXTURES { full.push(raylib::load_render_texture(1, 1)); }
    for target in full { assert(raylib::is_render_texture_valid(target)); }
    assert(raylib::load_render_texture(1, 1).id == 0);
    assert(raylib::unload_all_render_textures() == raylib::MAX_RENDER_TEXTURES);
    for target in full { dead(target); }
    let left = raylib::load_render_texture(8, 8);
    assert(raylib::begin_texture_mode(left));
    raylib::clear_background(raylib::RED);
    raylib::draw_rectangle(0, 0, 4, 4, raylib::BLUE);
    raylib::close_window();  // ends the active mode and frees all targets before destroying GL
    dead(left);
    assert(!raylib::is_texture_mode_active());
    raylib::init_window(320, 240, "render textures reopened");
    assert(raylib::is_window_ready() && !raylib::is_texture_mode_active());
    let reopened = raylib::load_render_texture(8, 8);
    assert(raylib::is_render_texture_valid(reopened) && reopened.id != left.id);
    dead(left);
    assert(raylib::begin_texture_mode(reopened)); raylib::clear_background(raylib::BLUE);
    assert(raylib::end_texture_mode());
    raylib::begin_drawing(); raylib::clear_background(raylib::WHITE);
    assert(raylib::draw_render_texture(reopened, 0, 0, raylib::WHITE));
    assert(grl_test_pixel(3, 3) == raylib::color_rgba(raylib::BLUE));
    raylib::end_drawing();
    raylib::CloseWindow();
    dead(reopened);
    print("render textures passed (upright/scaled/rotated pixels, 3D, compositing, mode guards, lifetime)");
}
