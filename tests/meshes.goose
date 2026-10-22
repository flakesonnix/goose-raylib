// Real generated mesh rendering and exclusive model ownership transfer.
import raylib from "..";
import raylib.raymath;

extern fn grl_test_pixel(x: i32, y: i32) -> u32;

fn dead(mesh: raylib::Mesh) {
    assert(!raylib::is_mesh_valid(mesh));
    assert(!raylib::unload_mesh(mesh));
    assert(raylib::mesh_vertex_count(mesh) == 0 && raylib::mesh_triangle_count(mesh) == 0);
    let bounds, valid = raylib::get_mesh_bounding_box(mesh);
    assert(!valid && bounds.min.x == 0 && bounds.max.z == 0);
    assert(!raylib::draw_mesh(mesh, raymath::matrix_identity(), raylib::WHITE));
    assert(raylib::load_model_from_mesh(mesh).id == 0);
}

fn main() {
    raylib::set_config_flags(0x80);  // FLAG_WINDOW_HIDDEN
    raylib::init_window(320, 240, "managed meshes");
    assert(raylib::is_window_ready());
    dead(raylib::Mesh { 0xFFFFFFFFFFFFFFFF });
    dead(raylib::Mesh { 0x0000000180000041 });
    assert(raylib::gen_mesh_poly(2, 1).id == 0);
    assert(raylib::gen_mesh_plane(2, 3, 0, 1).id == 0);
    assert(raylib::gen_mesh_plane(2, 3, raylib::MAX_MESH_SUBDIVISIONS + 1, 1).id == 0);
    assert(raylib::gen_mesh_cube(1, 0, 1).id == 0);
    assert(raylib::gen_mesh_sphere(1, 2, 12).id == 0);
    assert(raylib::gen_mesh_hemi_sphere(-1, 8, 12).id == 0);
    assert(raylib::gen_mesh_cylinder(1, -1, 12).id == 0);
    assert(raylib::gen_mesh_cone(1, 2, raylib::MAX_MESH_SUBDIVISIONS + 1).id == 0);

    let shapes = [raylib::gen_mesh_poly(8, 1), raylib::gen_mesh_plane(2, 3, 2, 4),
        raylib::gen_mesh_cube(1, 1, 1), raylib::gen_mesh_sphere(1, 8, 12),
        raylib::gen_mesh_hemi_sphere(1, 8, 12), raylib::gen_mesh_cylinder(0.7, 2, 12),
        raylib::gen_mesh_cone(0.7, 2, 12)];
    assert(raylib::mesh_vertex_count(shapes[0]) == 24 && raylib::mesh_triangle_count(shapes[0]) == 8);
    assert(raylib::mesh_vertex_count(shapes[1]) == 15 && raylib::mesh_triangle_count(shapes[1]) == 16);
    assert(raylib::mesh_vertex_count(shapes[2]) == 24 && raylib::mesh_triangle_count(shapes[2]) == 12);
    let plane_bounds, plane_ok = raylib::get_mesh_bounding_box(shapes[1]);
    assert(plane_ok && plane_bounds.min.x == -1 && plane_bounds.min.z == -1.5);
    assert(plane_bounds.max.x == 1 && plane_bounds.max.z == 1.5);
    let tint = raylib::Color { 23, 174, 211, 255 };
    for mesh in shapes {
        assert(raylib::is_mesh_valid(mesh));
        assert(raylib::mesh_vertex_count(mesh) > 0 && raylib::mesh_triangle_count(mesh) > 0);
        let bounds, valid = raylib::get_mesh_bounding_box(mesh);
        assert(valid);
        let center = raymath::vector3_scale(raymath::vector3_add(bounds.min, bounds.max), 0.5);
        let camera = raylib::Camera3D {
            position: raymath::vector3_add(center, raylib::Vector3 { 3, 4, 5 }), target: center,
            up: raylib::Vector3 { 0, 1, 0 }, fovy: 45, projection: raylib::CAMERA_PERSPECTIVE,
        };
        raylib::begin_drawing();
        raylib::clear_background(raylib::RAYWHITE);
        raylib::begin_mode_3d(camera);
        assert(raylib::draw_mesh(mesh, raymath::matrix_identity(), tint));
        raylib::end_mode_3d();
        assert(grl_test_pixel(160, 120) == raylib::color_rgba(tint));
        assert(grl_test_pixel(5, 5) == raylib::color_rgba(raylib::RAYWHITE));
        raylib::end_drawing();
    }

    let cube = shapes[2];
    assert(!raylib::is_model_valid(raylib::Model { cube.id }));  // reject the other token kind
    assert(!raylib::unload_model(raylib::Model { cube.id }));
    var transform = raymath::matrix_identity();
    transform.m0 = 0.5; transform.m5 = 1.25; transform.m10 = 0.75; transform.m12 = 1.5;
    let camera = raylib::Camera3D {
        position: raylib::Vector3 { 0, 0, 5 }, target: raylib::Vector3 { .. },
        up: raylib::Vector3 { 0, 1, 0 }, fovy: 45, projection: raylib::CAMERA_PERSPECTIVE,
    };
    raylib::begin_drawing();
    raylib::clear_background(raylib::RAYWHITE);
    raylib::begin_mode_3d(camera);
    assert(raylib::draw_mesh(cube, transform, tint));
    raylib::end_mode_3d();
    assert(grl_test_pixel(247, 120) == raylib::color_rgba(tint));
    assert(grl_test_pixel(160, 120) == raylib::color_rgba(raylib::RAYWHITE));
    raylib::end_drawing();

    let moved = raylib::load_model_from_mesh(cube);
    assert(raylib::is_model_valid(moved));
    dead(cube);
    dead(raylib::Mesh { moved.id });
    let replacement = raylib::gen_mesh_cube(1, 1, 1);
    assert(replacement.id != cube.id && (replacement.id & 0xFFFFFFFF) == (cube.id & 0xFFFFFFFF));
    dead(cube);  // even after slot reuse, an alias cannot unload the model's mesh
    assert(raylib::unload_mesh(replacement));
    assert(raylib::unload_all_meshes() == 6);
    assert(raylib::is_model_valid(moved));
    let model_bounds, model_valid = raylib::get_model_bounding_box(moved);
    assert(model_valid && model_bounds.min.x == -0.5 && model_bounds.max.x == 0.5);
    raylib::begin_drawing();
    raylib::clear_background(raylib::RAYWHITE);
    raylib::begin_mode_3d(camera);
    assert(raylib::draw_model(moved, raylib::Vector3 { .. }, 1, raylib::WHITE));
    raylib::end_mode_3d();
    assert(grl_test_pixel(160, 120) == raylib::color_rgba(raylib::WHITE));  // no old mesh tint retained
    raylib::end_drawing();
    assert(raylib::unload_model(moved));

    var full: raylib::Mesh[>..] = [];
    for i in 0..raylib::MAX_MESHES { full.push(raylib::gen_mesh_cube(1, 1, 1)); }
    for mesh in full { assert(raylib::is_mesh_valid(mesh)); }
    assert(raylib::gen_mesh_cube(1, 1, 1).id == 0);
    assert(raylib::gen_mesh_plane(2, 2, 2, 2).id == 0);
    let independent = raylib::gen_model_cube(1, 1, 1);
    assert(raylib::is_model_valid(independent));
    let from_full = raylib::load_model_from_mesh(full[0]);
    assert(raylib::is_model_valid(from_full));
    dead(full[0]);
    let reused = raylib::gen_mesh_cube(1, 1, 1);
    assert(raylib::is_mesh_valid(reused));
    dead(full[0]);
    assert(raylib::unload_all_meshes() == raylib::MAX_MESHES);
    assert(raylib::is_model_valid(from_full));
    assert(raylib::unload_model(from_full) && raylib::unload_model(independent));
    for mesh in full { dead(mesh); }

    for i in 0..raylib::MAX_MODELS { assert(raylib::is_model_valid(raylib::gen_model_cube(1, 1, 1))); }
    let pending = raylib::gen_mesh_sphere(1, 8, 12);
    assert(raylib::is_mesh_valid(pending));
    assert(raylib::load_model_from_mesh(pending).id == 0);  // reserve destination before moving
    assert(raylib::is_mesh_valid(pending));
    assert(raylib::unload_all_models() == raylib::MAX_MODELS);
    let after_full = raylib::load_model_from_mesh(pending);
    assert(raylib::is_model_valid(after_full));
    dead(pending);
    assert(raylib::unload_model(after_full));

    let left_mesh = raylib::gen_mesh_cube(1, 1, 1);
    let left_model = raylib::load_model_from_mesh(raylib::gen_mesh_sphere(1, 8, 12));
    assert(raylib::is_mesh_valid(left_mesh) && raylib::is_model_valid(left_model));
    raylib::close_window();
    assert(!raylib::is_window_ready() && !raylib::is_model_valid(left_model));
    dead(left_mesh);
    raylib::init_window(320, 240, "managed meshes reopened");
    assert(raylib::is_window_ready());
    let reopened = raylib::gen_mesh_cube(1, 1, 1);
    assert(raylib::is_mesh_valid(reopened) && reopened.id != left_mesh.id);
    dead(left_mesh);
    assert(!raylib::is_model_valid(left_model));
    raylib::begin_drawing();
    raylib::clear_background(raylib::RAYWHITE);
    raylib::begin_mode_3d(camera);
    assert(raylib::draw_mesh(reopened, raymath::matrix_identity(), tint));
    raylib::end_mode_3d();
    assert(grl_test_pixel(160, 120) == raylib::color_rgba(tint));
    raylib::end_drawing();
    raylib::CloseWindow();
    dead(reopened);
    assert(raylib::unload_all_meshes() == 0);
    print("meshes passed (7 generated shapes, pixels, matrices, exclusive transfer, limits, reopen)");
}
