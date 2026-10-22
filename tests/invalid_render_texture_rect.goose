import raylib from "..";
fn main() {
    raylib::draw_render_texture_pro(raylib::RenderTexture2D { 0 }, raylib::Vector3 { .. },
        raylib::Rectangle { .. }, raylib::Vector2 { .. }, 0, raylib::WHITE);
}
