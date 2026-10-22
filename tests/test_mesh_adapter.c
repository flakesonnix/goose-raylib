/* Real raylib oracles, GPU ownership and unaligned packed-value boundaries.
 * Include the adapter only to inspect native resources and generation limits. */
#include "raylib_models.c"
#include <assert.h>
#include <limits.h>
#include <stdio.h>

static void invalid_handles(void) {
    uint64_t invalid[] = {0, 1, UINT64_MAX, (UINT64_C(1) << 32) | MESH_TOKEN_TAG,
        (UINT64_C(1) << 32) | MESH_TOKEN_TAG | (GRL_MAX_MESHES + 1)};
    for (size_t i = 0; i < sizeof(invalid)/sizeof(invalid[0]); ++i) {
        unsigned char out[26];
        memset(out, 0xa5, sizeof(out));
        assert(!grl_is_mesh_valid(invalid[i]));
        assert(!grl_unload_mesh(invalid[i]));
        assert(grl_load_model_from_mesh(invalid[i]) == 0);
        assert(grl_mesh_vertex_count(invalid[i]) == 0);
        assert(grl_mesh_triangle_count(invalid[i]) == 0);
        assert(!grl_get_mesh_bounding_box(invalid[i], out + 1));
        assert(out[0] == 0xa5 && out[25] == 0xa5);
        for (int j = 1; j < 25; ++j) assert(out[j] == 0);
        assert(!grl_draw_mesh(invalid[i], NULL, UINT32_MAX));
    }
}

static void headless(void) {
    invalid_handles();
    assert(grl_gen_mesh_poly(8, 1) == 0);
    assert(grl_gen_mesh_plane(2, 3, 2, 3) == 0);
    assert(grl_gen_mesh_cube(1, 1, 1) == 0);
    assert(grl_gen_mesh_sphere(1, 8, 12) == 0);
    assert(grl_gen_mesh_hemi_sphere(1, 8, 12) == 0);
    assert(grl_gen_mesh_cylinder(1, 2, 12) == 0);
    assert(grl_gen_mesh_cone(1, 2, 12) == 0);
    assert(grl_unload_all_meshes() == 0);
    puts("mesh adapter headless validation passed");
}

static void oracle(uint64_t token, Mesh expected) {
    assert(grl_is_mesh_valid(token));
    Mesh actual = mesh_slot(token)->owner.meshes[0];
    assert(grl_mesh_vertex_count(token) == expected.vertexCount);
    assert(grl_mesh_triangle_count(token) == expected.triangleCount);
    assert(actual.vertexCount == expected.vertexCount && actual.triangleCount == expected.triangleCount);
    size_t vertex_bytes = (size_t)expected.vertexCount*3*sizeof(float);
    assert(memcmp(actual.vertices, expected.vertices, vertex_bytes) == 0);
    assert(memcmp(actual.normals, expected.normals, vertex_bytes) == 0);
    assert(memcmp(actual.texcoords, expected.texcoords, (size_t)expected.vertexCount*2*sizeof(float)) == 0);
    assert((actual.indices == NULL) == (expected.indices == NULL));
    if (expected.indices != NULL)
        assert(memcmp(actual.indices, expected.indices, (size_t)expected.triangleCount*3*sizeof(unsigned short)) == 0);
    BoundingBox box = GetMeshBoundingBox(expected);
    const float fields[6] = {box.min.x, box.min.y, box.min.z, box.max.x, box.max.y, box.max.z};
    unsigned char out[26];
    memset(out, 0xa5, sizeof(out));
    assert(grl_get_mesh_bounding_box(token, out + 1));
    assert(memcmp(out + 1, fields, sizeof(fields)) == 0);
    assert(out[0] == 0xa5 && out[25] == 0xa5);
    UnloadMesh(expected);
    assert(grl_unload_mesh(token));
}

static Image render(uint64_t token, Mesh native, Material material, Matrix expected, const void *packed) {
    Camera3D camera = {{7, 6, 7}, {0, 0, 0}, {0, 1, 0}, 50, CAMERA_PERSPECTIVE};
    BeginDrawing();
    ClearBackground(RAYWHITE);
    BeginMode3D(camera);
    if (token != 0) assert(grl_draw_mesh(token, packed, UINT32_C(0x17aed3ff)));
    else DrawMesh(native, material, expected);
    EndMode3D();
    rlDrawRenderBatchActive();
    Image result = LoadImageFromScreen();
    assert(IsImageValid(result));
    EndDrawing();
    return result;
}

static void render_oracle(uint64_t token) {
    /* Distinct scale/shear/translation elements detect transposition and any
     * confusion between Matrix declaration order and m0..m15 numeric order. */
    Matrix matrix = {.m0 = 0.8f, .m4 = 0.2f, .m8 = 0.1f, .m12 = 0.4f,
        .m1 = -0.1f, .m5 = 1.1f, .m9 = 0.3f, .m13 = -0.2f,
        .m2 = 0.2f, .m6 = -0.3f, .m10 = 0.7f, .m14 = 0.1f, .m15 = 1};
    float fields[16] = {0.8f, 0.2f, 0.1f, 0.4f, -0.1f, 1.1f, 0.3f, -0.2f,
        0.2f, -0.3f, 0.7f, 0.1f, 0, 0, 0, 1};
    unsigned char packed[66];
    memset(packed, 0xa5, sizeof(packed));
    memcpy(packed + 1, fields, sizeof(fields));
    Mesh native = mesh_slot(token)->owner.meshes[0];
    Material material = LoadMaterialDefault();
    material.maps[MATERIAL_MAP_ALBEDO].color = (Color){23, 174, 211, 255};
    Image actual = render(token, native, material, matrix, packed + 1);
    Image expected = render(0, native, material, matrix, NULL);
    assert(actual.width == expected.width && actual.height == expected.height);
    Color *a = LoadImageColors(actual);
    Color *b = LoadImageColors(expected);
    assert(a != NULL && b != NULL);
    size_t count = (size_t)actual.width*actual.height;
    assert(memcmp(a, b, count*sizeof(Color)) == 0);
    size_t colored = 0;
    for (size_t i = 0; i < count; ++i)
        if (a[i].r == 23 && a[i].g == 174 && a[i].b == 211 && a[i].a == 255) colored++;
    assert(colored > 100 && colored < count - 100);
    UnloadImageColors(a); UnloadImageColors(b);
    UnloadImage(actual); UnloadImage(expected);
    MemFree(material.maps);  // private maps only; default GPU resources are shared
    Color restored = mesh_slot(token)->owner.materials[0].maps[MATERIAL_MAP_ALBEDO].color;
    assert(restored.r == 255 && restored.g == 255 && restored.b == 255 && restored.a == 255);
    assert(packed[0] == 0xa5 && packed[65] == 0xa5);
    assert(memcmp(packed + 1, fields, sizeof(fields)) == 0);
    fields[5] = NAN;
    memcpy(packed + 1, fields, sizeof(fields));
    assert(!grl_draw_mesh(token, packed + 1, UINT32_MAX));
    fields[5] = INFINITY;
    memcpy(packed + 1, fields, sizeof(fields));
    assert(!grl_draw_mesh(token, packed + 1, UINT32_MAX));
}

static void graphics(void) {
    SetTraceLogLevel(LOG_WARNING);
    SetConfigFlags(FLAG_WINDOW_HIDDEN);
    InitWindow(320, 240, "mesh adapter oracle and ownership");
    assert(IsWindowReady());
    invalid_handles();  // exercise bounds/tag guards with a live context, too
    typedef unsigned char (*IsBuffer)(unsigned int);
    IsBuffer is_buffer = (IsBuffer)rlGetProcAddress("glIsBuffer");
    assert(is_buffer != NULL);

    assert(grl_gen_mesh_poly(2, 1) == 0);
    assert(grl_gen_mesh_poly(INT_MAX, 1) == 0);
    assert(grl_gen_mesh_poly(8, NAN) == 0);
    assert(grl_gen_mesh_plane(1, 1, 0, 1) == 0);
    assert(grl_gen_mesh_plane(1, 1, INT_MAX, INT_MAX) == 0);
    assert(grl_gen_mesh_plane(-1, 1, 1, 1) == 0);
    assert(grl_gen_mesh_cube(INFINITY, 1, 1) == 0);
    assert(grl_gen_mesh_cube(1, 0, 1) == 0);
    assert(grl_gen_mesh_sphere(1, 2, 12) == 0);
    assert(grl_gen_mesh_sphere(1, 8, GRL_MAX_MESH_SUBDIVISIONS + 1) == 0);
    assert(grl_gen_mesh_hemi_sphere(-1, 8, 12) == 0);
    assert(grl_gen_mesh_hemi_sphere(1, 8, INT_MAX) == 0);
    assert(grl_gen_mesh_cylinder(1, 0, 12) == 0);
    assert(grl_gen_mesh_cylinder(1, 1, INT_MIN) == 0);
    assert(grl_gen_mesh_cone(0, 1, 12) == 0);
    assert(grl_gen_mesh_cone(1, INFINITY, 12) == 0);
    assert(grl_gen_mesh_cone(1, 1, INT_MAX) == 0);
    oracle(grl_gen_mesh_poly(8, 1.5f), GenMeshPoly(8, 1.5f));
    oracle(grl_gen_mesh_plane(2, 3, 2, 4), GenMeshPlane(2, 3, 2, 4));
    oracle(grl_gen_mesh_cube(2, 4, 6), GenMeshCube(2, 4, 6));
    oracle(grl_gen_mesh_sphere(1.25f, 8, 12), GenMeshSphere(1.25f, 8, 12));
    oracle(grl_gen_mesh_hemi_sphere(0.75f, 7, 9), GenMeshHemiSphere(0.75f, 7, 9));
    oracle(grl_gen_mesh_cylinder(0.5f, 2, 12), GenMeshCylinder(0.5f, 2, 12));
    oracle(grl_gen_mesh_cone(0.8f, 1.5f, 10), GenMeshCone(0.8f, 1.5f, 10));
    oracle(grl_gen_mesh_plane(2, 3, 1, 1), GenMeshPlane(2, 3, 1, 1));
    oracle(grl_gen_mesh_plane(2, 3, GRL_MAX_MESH_SUBDIVISIONS, GRL_MAX_MESH_SUBDIVISIONS),
        GenMeshPlane(2, 3, GRL_MAX_MESH_SUBDIVISIONS, GRL_MAX_MESH_SUBDIVISIONS));
    oracle(grl_gen_mesh_sphere(1, 3, 3), GenMeshSphere(1, 3, 3));

    uint64_t mesh = grl_gen_mesh_cube(2, 4, 6);
    assert(mesh != 0 && !grl_is_model_valid(mesh) && !grl_unload_model(mesh));
    render_oracle(mesh);
    Mesh before = mesh_slot(mesh)->owner.meshes[0];
    MaterialMap *maps = mesh_slot(mesh)->owner.materials[0].maps;
    unsigned int buffer = before.vboId[0];
    assert(is_buffer(buffer));
    uint64_t model = grl_load_model_from_mesh(mesh);
    assert(grl_is_model_valid(model) && !grl_is_mesh_valid(model));
    assert(!grl_unload_mesh(model));
    assert(!grl_is_mesh_valid(mesh) && !grl_unload_mesh(mesh));
    assert(grl_load_model_from_mesh(mesh) == 0);
    assert(model_slot(model)->model.meshes[0].vertices == before.vertices);
    assert(model_slot(model)->model.meshes[0].vboId == before.vboId);
    assert(model_slot(model)->model.materials[0].maps == maps);
    assert(is_buffer(buffer));  // moved, not freed or re-uploaded
    uint64_t replacement = grl_gen_mesh_cube(1, 1, 1);
    assert(replacement != mesh && (uint32_t)replacement == (uint32_t)mesh);
    assert(grl_unload_all_meshes() == 1 && is_buffer(buffer));
    assert(grl_unload_model(model) && !is_buffer(buffer));

    mesh = grl_gen_mesh_sphere(1, 8, 12);
    before = mesh_slot(mesh)->owner.meshes[0];
    for (int i = 0; i < GRL_MAX_MODELS; ++i) assert(grl_gen_model_cube(1, 1, 1));
    assert(grl_load_model_from_mesh(mesh) == 0 && grl_is_mesh_valid(mesh));
    assert(mesh_slot(mesh)->owner.meshes[0].vertices == before.vertices);
    assert(is_buffer(before.vboId[0]));
    assert(grl_unload_all_models() == GRL_MAX_MODELS && grl_is_mesh_valid(mesh));
    model = grl_load_model_from_mesh(mesh);
    assert(model && !grl_is_mesh_valid(mesh));
    assert(grl_unload_model(model));

    for (int i = 0; i < GRL_MAX_MESHES; ++i) assert(grl_gen_mesh_cube(1, 1, 1));
    assert(grl_gen_mesh_cube(1, 1, 1) == 0);
    assert(grl_gen_mesh_sphere(1, 8, 12) == 0);
    model = grl_gen_model_cube(1, 1, 1);  // independent capacities
    assert(model && grl_unload_model(model));
    assert(grl_unload_all_meshes() == GRL_MAX_MESHES);
    assert(grl_unload_all_meshes() == 0);
    mesh_slots[0].generation = UINT32_MAX - 1;
    uint64_t last = grl_gen_mesh_cube(1, 1, 1);
    assert((last >> 32) == UINT32_MAX && (uint32_t)last == (MESH_TOKEN_TAG | 1));
    assert(grl_unload_mesh(last));
    mesh = grl_gen_mesh_cube(1, 1, 1);
    assert(mesh && (uint32_t)mesh != (uint32_t)last && !grl_is_mesh_valid(last));
    model = grl_load_model_from_mesh(mesh);
    mesh = grl_gen_mesh_cube(1, 1, 1);
    assert(model && mesh);
    grl_close_window();  // frees both ownership tables while GL is alive
    assert(!grl_is_mesh_valid(mesh) && !grl_is_model_valid(model));
    for (int i = 0; i < GRL_MAX_MESHES; ++i) assert(!mesh_slots[i].in_use);
    InitWindow(320, 240, "mesh context reopened");
    assert(IsWindowReady());
    replacement = grl_gen_mesh_cube(1, 1, 1);
    assert(replacement && replacement != mesh && !grl_is_mesh_valid(mesh));
    assert(!grl_is_model_valid(model));
    assert(grl_unload_all_meshes() == 1);
    grl_close_window();
    puts("mesh adapter graphics passed (7 native oracles, framebuffer oracle, move ownership, limits, retirement)");
}

int main(int argc, char **argv) {
    headless();
    if (argc == 2 && strcmp(argv[1], "--graphics") == 0) graphics();
    else assert(argc == 1);
    return 0;
}
