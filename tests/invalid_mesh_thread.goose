import raylib from "..";

thread_fn load() {
    raylib::gen_mesh_cube(1, 1, 1);
}

fn main() {
    thread_wait(thread_spawn(load));
}
