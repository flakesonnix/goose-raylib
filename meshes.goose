// Real generated meshes: draw directly, or move into a model. 120 frames.
import raylib from ".";
import raylib.raymath;

fn main() {
    raylib::init_window(800, 450, "goose-raylib generated meshes");
    assert(raylib::is_window_ready());
    raylib::set_target_fps(60);
    let sphere = raylib::gen_mesh_sphere(1, 16, 24);
    let cone_mesh = raylib::gen_mesh_cone(0.8, 2, 16);
    assert(raylib::is_mesh_valid(sphere) && raylib::is_mesh_valid(cone_mesh));
    let cone = raylib::load_model_from_mesh(cone_mesh);
    assert(raylib::is_model_valid(cone) && !raylib::is_mesh_valid(cone_mesh));
    let camera = raylib::Camera3D {
        position: raylib::Vector3 { 5, 4, 6 }, target: raylib::Vector3 { 0, 1, 0 },
        up: raylib::Vector3 { 0, 1, 0 }, fovy: 45, projection: raylib::CAMERA_PERSPECTIVE,
    };
    var frames: i32 = 0;
    while !raylib::window_should_close() && frames < 120 {
        let rotation = raymath::matrix_rotate_xyz(raylib::Vector3 { 0, frames * 0.01, 0 });
        let transform = raymath::matrix_multiply(rotation, raymath::matrix_translate(-1.5, 1, 0));
        raylib::begin_drawing();
        raylib::clear_background(raylib::RAYWHITE);
        raylib::begin_mode_3d(camera);
        raylib::draw_grid(20, 1);
        assert(raylib::draw_mesh(sphere, transform, raylib::BLUE));
        assert(raylib::draw_model(cone, raylib::Vector3 { 1.5, 0, 0 }, 1, raylib::RED));
        raylib::end_mode_3d();
        raylib::draw_text("Mesh -> Model transfers ownership; aliases become invalid", 20, 20, 20, raylib::BLACK);
        raylib::end_drawing();
        frames += 1;
    }
    assert(raylib::unload_mesh(sphere));
    assert(raylib::unload_model(cone));
    raylib::close_window();
}
