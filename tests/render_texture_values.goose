// No display/context: typed handles and all failure paths are safe.
import raylib from "..";

fn dead(target: raylib::RenderTexture2D) {
    assert(!raylib::is_render_texture_valid(target));
    assert(raylib::render_texture_width(target) == 0 && raylib::render_texture_height(target) == 0);
    assert(!raylib::begin_texture_mode(target));
    assert(!raylib::unload_render_texture(target));
    assert(!raylib::draw_render_texture(target, 0, 0, raylib::WHITE));
    assert(!raylib::draw_render_texture_pro(target, raylib::Rectangle { 0, 0, 1, -1 },
        raylib::Rectangle { 0, 0, 1, 1 }, raylib::Vector2 { .. }, 0, raylib::WHITE));
}
fn main() {
    let target: raylib::RenderTexture = raylib::RenderTexture2D { .. };
    assert(bytes_of([target]).len == 8 && target.id == 0);
    dead(target);
    dead(raylib::RenderTexture2D { 1 });
    dead(raylib::RenderTexture2D { 0xFFFFFFFFFFFFFFFF });
    dead(raylib::RenderTexture2D { 0x0000000140000041 });
    assert(raylib::load_render_texture(32, 24).id == 0);
    assert(!raylib::is_texture_mode_active() && !raylib::end_texture_mode());
    assert(raylib::unload_all_render_textures() == 0);
    raylib::close_window();
    print("render texture values passed (headless guards and typed handles)");
}
