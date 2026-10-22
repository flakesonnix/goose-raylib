import raylib from "..";
thread_fn load() {
    raylib::load_render_texture(16, 16);
}
fn main() {
    thread_wait(thread_spawn(load));
}
