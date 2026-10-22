// Real file/generated-model rendering and resource lifecycle, bounded frames.
// Run via tests/run_3d.py, which prepares the PNG/OBJ fixtures under build/.
import raylib from "..";

extern fn grl_test_pixel(x: i32, y: i32) -> u32;

fn dead(model: raylib::Model) {
    assert(!raylib::is_model_valid(model));
    assert(!raylib::unload_model(model));
    assert(!raylib::draw_model(model, raylib::Vector3 { .. }, 1, raylib::WHITE));
    assert(!raylib::draw_model_wires(model, raylib::Vector3 { .. }, 1, raylib::WHITE));
    assert(!raylib::draw_model_ex(model, raylib::Vector3 { .. }, raylib::Vector3 { 0, 1, 0 },
                                 0, raylib::Vector3 { 1, 1, 1 }, raylib::WHITE));
    assert(!raylib::draw_model_wires_ex(model, raylib::Vector3 { .. }, raylib::Vector3 { 0, 1, 0 },
                                       0, raylib::Vector3 { 1, 1, 1 }, raylib::WHITE));
}

fn main() {
    raylib::set_config_flags(0x80);  // FLAG_WINDOW_HIDDEN
    raylib::init_window(320, 240, "managed model tests");
    assert(raylib::is_window_ready());
    assert(raylib::load_model("build/tests-3d/model-assets/missing.obj").id == 0);
    for i in 0..raylib::MAX_MODELS + 1 {
        assert(raylib::load_model("build/tests-3d/model-assets/empty.obj").id == 0);
    }  // failed loads must not consume slots
    assert(raylib::load_model("build/tests-3d/model-assets/plain.obj\0suffix").id == 0);
    var long_path: u8[>..] = [];
    for i in 0..4096 { long_path.push('x'); }
    assert(raylib::load_model(long_path).id == 0);  // reject, do not truncate
    assert(raylib::gen_model_cube(0, 1, 1).id == 0);
    assert(raylib::gen_model_cube(1, -1, 1).id == 0);

    let wrapped = "!build/tests-3d/model-assets/plain.obj!";
    let plain = raylib::load_model(wrapped[1..wrapped.len - 1]);
    let alias = plain;
    assert(raylib::is_model_valid(plain));
    assert(raylib::model_mesh_count(plain) == 1);
    assert(raylib::model_material_count(plain) > 0);
    let bounds, valid = raylib::get_model_bounding_box(plain);
    assert(valid);
    assert(bounds.min.x == -1 && bounds.min.y == -1 && bounds.min.z == 0);
    assert(bounds.max.x == 1 && bounds.max.y == 1 && bounds.max.z == 0);
    let cube = raylib::gen_model_cube(2, 4, 6);
    assert(raylib::is_model_valid(cube));
    let cube_bounds, cube_valid = raylib::get_model_bounding_box(cube);
    assert(cube_valid && cube_bounds.min.x == -1 && cube_bounds.min.y == -2 && cube_bounds.min.z == -3);
    assert(cube_bounds.max.x == 1 && cube_bounds.max.y == 2 && cube_bounds.max.z == 3);

    let tex_a = raylib::load_model("build/tests-3d/model-assets/textured.obj");
    let tex_b = raylib::load_model("build/tests-3d/model-assets/textured.obj");
    assert(raylib::is_model_valid(tex_a) && raylib::is_model_valid(tex_b));
    let camera = raylib::Camera3D {
        position: raylib::Vector3 { 0, 0, 5 }, target: raylib::Vector3 { .. },
        up: raylib::Vector3 { 0, 1, 0 }, fovy: 45, projection: raylib::CAMERA_PERSPECTIVE,
    };
    let origin = raylib::Vector3 { .. };
    let axis = raylib::Vector3 { 0, 1, 0 };
    let scale = raylib::Vector3 { 1, 1, 1 };
    let tint = raylib::Color { 23, 174, 211, 255 };
    for frame in 0..3 {
        raylib::begin_drawing();
        raylib::clear_background(raylib::RAYWHITE);
        raylib::begin_mode_3d(camera);
        if frame == 0 {
            assert(raylib::draw_model(plain, origin, 1, tint));
        } else if frame == 1 {
            assert(raylib::draw_model_ex(plain, raylib::Vector3 { 0.1, -0.1, 0 },
                                         raylib::Vector3 { 0, 0, 1 }, 180,
                                         raylib::Vector3 { 0.8, 1.2, 1.4 }, tint));
        } else {
            assert(raylib::draw_model(tex_a, origin, 1, raylib::WHITE));
        }
        raylib::end_mode_3d();
        if frame < 2 {
            assert(grl_test_pixel(160, 120) == raylib::color_rgba(tint));
        } else {
            assert(grl_test_pixel(160, 120) == 0x3C78C8FF);  // fixture PNG
        }
        assert(grl_test_pixel(5, 5) == raylib::color_rgba(raylib::RAYWHITE));
        raylib::begin_mode_3d(camera);
        assert(raylib::draw_model_wires(cube, origin, 1, raylib::BLACK));
        assert(raylib::draw_model_wires_ex(cube, origin, axis, 30, scale, raylib::BLACK));
        raylib::end_mode_3d();
        raylib::end_drawing();
    }
    assert(raylib::unload_model(tex_a));
    dead(tex_a);
    raylib::begin_drawing();
    raylib::clear_background(raylib::RAYWHITE);
    raylib::begin_mode_3d(camera);
    assert(raylib::draw_model(tex_b, origin, 1, raylib::WHITE));
    raylib::end_mode_3d();
    assert(grl_test_pixel(160, 120) == 0x3C78C8FF);  // another model keeps its own texture
    raylib::end_drawing();
    assert(raylib::unload_model(plain));
    let replacement = raylib::gen_model_cube(1, 1, 1);
    assert(replacement.id != alias.id);
    assert((replacement.id & 0xFFFFFFFF) == (alias.id & 0xFFFFFFFF));
    dead(alias);  // same slot reused, but an old generation must stay invalid
    assert(raylib::is_model_valid(replacement));
    assert(raylib::unload_model(replacement));
    assert(raylib::unload_model(cube));
    assert(raylib::unload_model(tex_b));
    assert(raylib::unload_all_models() == 0);

    var full: raylib::Model[>..] = [];
    for i in 0..raylib::MAX_MODELS {
        let item = raylib::gen_model_cube(1, 1, 1);
        assert(raylib::is_model_valid(item));
        full.push(item);
    }
    assert(raylib::gen_model_cube(1, 1, 1).id == 0);
    assert(raylib::load_model("build/tests-3d/model-assets/plain.obj").id == 0);
    assert(raylib::unload_all_models() == raylib::MAX_MODELS);
    for item in full { dead(item); }
    let left_open = raylib::gen_model_cube(1, 1, 1);
    assert(raylib::is_model_valid(left_open));
    raylib::close_window();  // final explicit cleanup boundary, not a destructor
    assert(!raylib::is_window_ready());
    dead(left_open);
    raylib::init_window(320, 240, "managed models reopened");
    assert(raylib::is_window_ready());
    let reopened = raylib::gen_model_cube(1, 1, 1);
    assert(raylib::is_model_valid(reopened));
    dead(left_open);
    raylib::begin_drawing();
    raylib::clear_background(raylib::RAYWHITE);
    raylib::begin_mode_3d(camera);
    assert(raylib::draw_model(reopened, origin, 1, tint));
    raylib::end_mode_3d();
    assert(grl_test_pixel(160, 120) == raylib::color_rgba(tint));
    raylib::end_drawing();
    assert(raylib::unload_model(reopened));
    let compatibility = raylib::gen_model_cube(1, 1, 1);
    assert(raylib::is_model_valid(compatibility));
    raylib::CloseWindow();  // legacy spelling must not bypass managed cleanup
    dead(compatibility);
    raylib::close_window();
    print("models passed (file/PNG rendering, stale handles, capacity, shutdown/reopen)");
}
