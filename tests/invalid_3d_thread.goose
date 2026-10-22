import raylib from "..";

thread_fn render() {
    raylib::draw_grid(10, 1);
}

fn main() {
    thread_wait(thread_spawn(render));
}
