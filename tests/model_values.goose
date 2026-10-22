// No display/context: invalid handles and unavailable-window failures are safe.
import raylib from "..";

fn dead(model: raylib::Model) {
    assert(!raylib::is_model_valid(model));
    assert(!raylib::unload_model(model));
    assert(raylib::model_mesh_count(model) == 0);
    assert(raylib::model_material_count(model) == 0);
    let bounds, valid = raylib::get_model_bounding_box(model);
    assert(!valid);
    assert(bounds.min.x == 0 && bounds.min.y == 0 && bounds.min.z == 0);
    assert(bounds.max.x == 0 && bounds.max.y == 0 && bounds.max.z == 0);
    assert(!raylib::draw_model(model, raylib::Vector3 { .. }, 1, raylib::WHITE));
}

fn main() {
    let model = raylib::Model { .. };
    assert(bytes_of([model]).len == 8);
    assert(model.id == 0);
    dead(model);
    dead(raylib::Model { 1 });
    dead(raylib::Model { 0xFFFFFFFFFFFFFFFF });
    dead(raylib::Model { 0x0000000100000041 });  // slot 65, out of range
    assert(raylib::load_model("no-window.obj").id == 0);
    assert(raylib::gen_model_cube(1, 1, 1).id == 0);
    assert(raylib::unload_all_models() == 0);
    raylib::close_window();  // no initialized window: safe no-op
    print("model values passed (headless failures and typed u64 handles)");
}
