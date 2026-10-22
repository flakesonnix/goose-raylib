// No window: all mesh operations fail safely, without touching GPU state.
import raylib from "..";

fn dead(mesh: raylib::Mesh) {
    assert(!raylib::is_mesh_valid(mesh));
    assert(!raylib::unload_mesh(mesh));
    assert(raylib::mesh_vertex_count(mesh) == 0);
    assert(raylib::mesh_triangle_count(mesh) == 0);
    let bounds, valid = raylib::get_mesh_bounding_box(mesh);
    assert(!valid);
    assert(bounds.min.x == 0 && bounds.min.y == 0 && bounds.min.z == 0);
    assert(bounds.max.x == 0 && bounds.max.y == 0 && bounds.max.z == 0);
    assert(!raylib::draw_mesh(mesh, raylib::Matrix { .. }, raylib::WHITE));
    assert(raylib::load_model_from_mesh(mesh).id == 0);
}

fn main() {
    let mesh = raylib::Mesh { .. };
    assert(bytes_of([mesh]).len == 8 && mesh.id == 0);
    dead(mesh);
    dead(raylib::Mesh { 1 });
    dead(raylib::Mesh { 0xFFFFFFFFFFFFFFFF });
    dead(raylib::Mesh { 0x0000000180000041 });
    assert(raylib::gen_mesh_poly(8, 1).id == 0);
    assert(raylib::gen_mesh_plane(2, 3, 2, 4).id == 0);
    assert(raylib::gen_mesh_cube(1, 1, 1).id == 0);
    assert(raylib::gen_mesh_sphere(1, 8, 12).id == 0);
    assert(raylib::gen_mesh_hemi_sphere(1, 8, 12).id == 0);
    assert(raylib::gen_mesh_cylinder(1, 2, 12).id == 0);
    assert(raylib::gen_mesh_cone(1, 2, 12).id == 0);
    assert(raylib::unload_all_meshes() == 0);
    raylib::close_window();
    print("mesh values passed (headless failures and distinct typed u64 handles)");
}
