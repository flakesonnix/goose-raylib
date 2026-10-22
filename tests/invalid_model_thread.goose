import raylib from "..";

thread_fn load() {
    raylib::gen_model_cube(1, 1, 1);
}

fn main() {
    thread_wait(thread_spawn(load));
}
