// Real OpenGL smoke test; never run without a display. Bounded to three frames.
import raylib from "..";

extern fn grl_test_pixel(x: i32, y: i32) -> u32;
extern fn grl_test_title(title: const u8[:]) -> bool;

fn main() {
    raylib::set_config_flags(0x80);  // FLAG_WINDOW_HIDDEN
    let title = "3D ABI test!";
    assert(grl_test_title(title[0..11]));
    raylib::init_window(320, 240, title[0..11]);
    assert(raylib::is_window_ready());

    var camera = raylib::Camera3D {
        position: raylib::Vector3 { 0, 0, 5 }, target: raylib::Vector3 { .. },
        up: raylib::Vector3 { 0, 1, 0 }, fovy: 45, projection: raylib::CAMERA_PERSPECTIVE,
    };
    let origin = raylib::Vector3 { .. };
    let size = raylib::Vector3 { 1, 1, 1 };
    let color = raylib::Color { 23, 174, 211, 255 };

    for frame in 0..3 {
        // Perspective and orthographic projection, plus native out parameters.
        camera.projection = if frame == 1 { raylib::CAMERA_ORTHOGRAPHIC } else { raylib::CAMERA_PERSPECTIVE };
        camera.fovy = if frame == 1 { 4 } else { 45 };
        let screen = raylib::get_world_to_screen(origin, camera);
        assert(screen.x > 159.9 && screen.x < 160.1);
        assert(screen.y > 119.9 && screen.y < 120.1);
        let ray = raylib::get_screen_to_world_ray(raylib::Vector2 { 160, 120 }, camera);
        assert(ray.direction.x > -0.001 && ray.direction.x < 0.001);
        assert(ray.direction.y > -0.001 && ray.direction.y < 0.001);
        assert(ray.direction.z < -0.999);

        raylib::begin_drawing();
        raylib::clear_background(raylib::RAYWHITE);
        raylib::begin_mode_3d(camera);
        raylib::draw_cube(0, 0, 0, 1, 1, 1, color);
        raylib::end_mode_3d();
        // Detect incorrect scalar order, color packing, or camera/struct ABI.
        assert(grl_test_pixel(160, 120) == raylib::color_rgba(color));
        assert(grl_test_pixel(5, 5) == raylib::color_rgba(raylib::RAYWHITE));

        // Exercise every remaining drawing entry point inside a real 3D frame.
        raylib::begin_mode_3d(camera);
        raylib::draw_line_3d(origin, size, color);
        raylib::draw_point_3d(size, color);
        raylib::draw_triangle_3d(origin, raylib::Vector3 { 0, 1, 0 }, size, color);
        raylib::draw_cube_v(origin, size, color);
        raylib::draw_cube_wires(0, 0, 0, 1, 1, 1, color);
        raylib::draw_cube_wires_v(origin, size, color);
        raylib::draw_sphere(0, 0, 0, 0.5, color);
        raylib::draw_sphere_v(origin, 0.5, color);
        raylib::draw_sphere_ex(origin, 0.5, 8, 8, color);
        raylib::draw_sphere_wires(origin, 0.5, 8, 8, color);
        raylib::draw_cylinder(0, 0, 0, 0.5, 0.3, 1, 8, color);
        raylib::draw_cylinder_v(origin, 0.5, 0.3, 1, 8, color);
        raylib::draw_cylinder_ex(origin, size, 0.5, 0.3, 8, color);
        raylib::draw_cylinder_wires(0, 0, 0, 0.5, 0.3, 1, 8, color);
        raylib::draw_cylinder_wires_v(origin, 0.5, 0.3, 1, 8, color);
        raylib::draw_cylinder_wires_ex(origin, size, 0.5, 0.3, 8, color);
        raylib::draw_capsule(origin, size, 0.2, 8, 8, color);
        raylib::draw_capsule_wires(origin, size, 0.2, 8, 8, color);
        raylib::draw_plane(origin, raylib::Vector2 { 2, 2 }, color);
        raylib::draw_ray(raylib::Ray { origin, size }, color);
        raylib::draw_grid(10, 1);
        raylib::draw_bounding_box(raylib::BoundingBox { origin, size }, color);
        raylib::end_mode_3d();
        raylib::draw_text("3D rendering test", 10, 10, 16, raylib::BLACK);
        raylib::end_drawing();
    }
    raylib::close_window();
    assert(!raylib::is_window_ready());
    print("3d graphics passed (3 frames, framebuffer assertions)");
}
