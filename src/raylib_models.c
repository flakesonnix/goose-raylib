#include "raylib_models.h"
#include "raylib_render_textures.h"
#include <rlgl.h>
#include <math.h>

_Static_assert(sizeof(float) == 4, "Goose f32 requires 32-bit float");

typedef struct {
    Model model;
    uint32_t generation;
    uint8_t in_use;
} ModelSlot;

static ModelSlot model_slots[GRL_MAX_MODELS];

typedef struct {
    /* One native mesh plus its private default material, using raylib's own
     * ownership container. Moving this into a model needs no new allocation. */
    Model owner;
    uint32_t generation;
    uint8_t in_use;
} MeshSlot;

#define MESH_TOKEN_TAG UINT32_C(0x80000000)
static MeshSlot mesh_slots[GRL_MAX_MESHES];

static int free_model_slot(void) {
    for (int i = 0; i < GRL_MAX_MODELS; ++i) {
        /* Retire exhausted slots, never wrap a generation back to an old ID. */
        if (!model_slots[i].in_use && model_slots[i].generation != UINT32_MAX) return i;
    }
    return -1;
}

static ModelSlot *model_slot(uint64_t token) {
    uint32_t slot = (uint32_t)token;
    uint32_t generation = (uint32_t)(token >> 32);
    if (!IsWindowReady() || slot == 0 || slot > GRL_MAX_MODELS || generation == 0) return NULL;
    ModelSlot *entry = &model_slots[slot - 1];
    return entry->in_use && entry->generation == generation ? entry : NULL;
}

/* Unlike raw raylib, this API never lends/replaces a model's materials.
 * Textures/shaders loaded by LoadModel therefore belong to this model.
 * UnloadModel only frees material map arrays, not those GPU resources. */
static void dispose_model(Model model) {
    const unsigned int default_texture = rlGetTextureIdDefault();
    const unsigned int default_shader = rlGetShaderIdDefault();
    for (int i = 0; i < model.materialCount; ++i) {
        Material *material = &model.materials[i];
        if (material->shader.id != 0 && material->shader.id != default_shader) {
            unsigned int id = material->shader.id;
            UnloadShader(material->shader);
            for (int j = i; j < model.materialCount; ++j) {
                if (model.materials[j].shader.id == id) model.materials[j].shader = (Shader){0};
            }
        }
        if (material->maps == NULL) continue;
        /* Public map indices in pinned raylib 6.2 run from ALBEDO to BRDF.
         * Do not assume padding/reserved map entries contain owned resources. */
        for (int map = MATERIAL_MAP_ALBEDO; map <= MATERIAL_MAP_BRDF; ++map) {
            Texture2D texture = material->maps[map].texture;
            if (texture.id == 0 || texture.id == default_texture) continue;
            UnloadTexture(texture);
            /* Maps/materials may share one texture. Remove every alias before
             * continuing so no native resource is unloaded more than once. */
            for (int j = i; j < model.materialCount; ++j) {
                if (model.materials[j].maps == NULL) continue;
                for (int k = MATERIAL_MAP_ALBEDO; k <= MATERIAL_MAP_BRDF; ++k) {
                    if (model.materials[j].maps[k].texture.id == texture.id)
                        model.materials[j].maps[k].texture = (Texture2D){0};
                }
            }
        }
    }
    UnloadModel(model);
}

static int valid_native_model(Model model) {
    int sane = model.meshCount > 0 && model.materialCount > 0 &&
               model.meshes != NULL && model.materials != NULL && model.meshMaterial != NULL;
    for (int i = 0; sane && i < model.meshCount; ++i) {
        sane = model.meshes[i].vertexCount > 0 && model.meshes[i].triangleCount > 0 &&
               model.meshes[i].vertices != NULL && model.meshes[i].vboId != NULL &&
               model.meshMaterial[i] >= 0 && model.meshMaterial[i] < model.materialCount;
    }
    for (int i = 0; sane && i < model.materialCount; ++i)
        sane = model.materials[i].maps != NULL && model.materials[i].shader.locs != NULL;
    return sane && IsModelValid(model);
}

static uint64_t store_model(int slot, Model model) {
    ModelSlot *entry = &model_slots[slot];
    entry->generation++;
    entry->model = model;
    entry->in_use = 1;
    return ((uint64_t)entry->generation << 32) | (uint64_t)(slot + 1);
}

static uint64_t retain_model(int slot, Model model) {
    if (!valid_native_model(model)) {
        /* Even failed LoadModel calls may allocate a default material. */
        dispose_model(model);
        return 0;
    }
    return store_model(slot, model);
}

uint64_t grl_load_model(goose_slice_u8 path) {
    if (!IsWindowReady()) return 0;
    int slot = free_model_slot();
    char filename[RL_ADAPTER_MAX_STR];
    if (slot < 0 || path.len <= 0 || path.len >= (int64_t)sizeof(filename) || path.data == NULL) return 0;
    if (memchr(path.data, 0, (size_t)path.len) != NULL) return 0;
    memcpy(filename, path.data, (size_t)path.len);
    filename[path.len] = 0;
    if (!FileExists(filename)) return 0;
    return retain_model(slot, LoadModel(filename));
}

uint64_t grl_gen_model_cube(float width, float height, float length) {
    if (!IsWindowReady() || !isfinite(width) || !isfinite(height) || !isfinite(length) ||
        width <= 0 || height <= 0 || length <= 0) return 0;
    int slot = free_model_slot();
    if (slot < 0) return 0;
    /* LoadModelFromMesh takes ownership of this generated mesh. */
    return retain_model(slot, LoadModelFromMesh(GenMeshCube(width, height, length)));
}

uint8_t grl_is_model_valid(uint64_t token) {
    ModelSlot *entry = model_slot(token);
    return entry != NULL && IsModelValid(entry->model);
}

uint8_t grl_unload_model(uint64_t token) {
    ModelSlot *entry = model_slot(token);
    if (entry == NULL) return 0;
    Model model = entry->model;
    entry->in_use = 0;
    entry->model = (Model){0};
    dispose_model(model);
    return 1;
}

int32_t grl_unload_all_models(void) {
    int32_t count = 0;
    if (!IsWindowReady()) return 0;
    for (int i = 0; i < GRL_MAX_MODELS; ++i) {
        if (model_slots[i].in_use) {
            uint64_t token = ((uint64_t)model_slots[i].generation << 32) | (uint64_t)(i + 1);
            count += grl_unload_model(token);
        }
    }
    return count;
}

void grl_close_window(void) {
    if (!IsWindowReady()) return;
    grl_shutdown_render_textures();
    grl_unload_all_models();
    grl_unload_all_meshes();
    CloseWindow();
}

int32_t grl_model_mesh_count(uint64_t token) {
    ModelSlot *entry = model_slot(token);
    return entry != NULL ? entry->model.meshCount : 0;
}
int32_t grl_model_material_count(uint64_t token) {
    ModelSlot *entry = model_slot(token);
    return entry != NULL ? entry->model.materialCount : 0;
}
uint8_t grl_get_model_bounding_box(uint64_t token, void *out) {
    ModelSlot *entry = model_slot(token);
    BoundingBox box = entry != NULL ? GetModelBoundingBox(entry->model) : (BoundingBox){0};
    float fields[6] = {box.min.x, box.min.y, box.min.z, box.max.x, box.max.y, box.max.z};
    memcpy(out, fields, sizeof(fields));
    return entry != NULL;
}

static Color model_color(uint32_t c) {
    return (Color){(unsigned char)(c >> 24), (unsigned char)(c >> 16),
                   (unsigned char)(c >> 8), (unsigned char)c};
}
static int finite3(float x, float y, float z) { return isfinite(x) && isfinite(y) && isfinite(z); }

uint8_t grl_draw_model(uint64_t token, float x, float y, float z, float scale, uint32_t rgba) {
    ModelSlot *entry = model_slot(token);
    if (entry == NULL || !finite3(x, y, z) || !isfinite(scale)) return 0;
    DrawModel(entry->model, (Vector3){x, y, z}, scale, model_color(rgba));
    return 1;
}
uint8_t grl_draw_model_wires(uint64_t token, float x, float y, float z, float scale, uint32_t rgba) {
    ModelSlot *entry = model_slot(token);
    if (entry == NULL || !finite3(x, y, z) || !isfinite(scale)) return 0;
    DrawModelWires(entry->model, (Vector3){x, y, z}, scale, model_color(rgba));
    return 1;
}
uint8_t grl_draw_model_ex(uint64_t token, float x, float y, float z,
                          float ax, float ay, float az, float angle,
                          float sx, float sy, float sz, uint32_t rgba) {
    ModelSlot *entry = model_slot(token);
    if (entry == NULL || !finite3(x, y, z) || !finite3(ax, ay, az) ||
        !isfinite(angle) || !finite3(sx, sy, sz)) return 0;
    DrawModelEx(entry->model, (Vector3){x, y, z}, (Vector3){ax, ay, az}, angle,
                (Vector3){sx, sy, sz}, model_color(rgba));
    return 1;
}
uint8_t grl_draw_model_wires_ex(uint64_t token, float x, float y, float z,
                                float ax, float ay, float az, float angle,
                                float sx, float sy, float sz, uint32_t rgba) {
    ModelSlot *entry = model_slot(token);
    if (entry == NULL || !finite3(x, y, z) || !finite3(ax, ay, az) ||
        !isfinite(angle) || !finite3(sx, sy, sz)) return 0;
    DrawModelWiresEx(entry->model, (Vector3){x, y, z}, (Vector3){ax, ay, az}, angle,
                     (Vector3){sx, sy, sz}, model_color(rgba));
    return 1;
}

static int free_mesh_slot(void) {
    for (int i = 0; i < GRL_MAX_MESHES; ++i) {
        if (!mesh_slots[i].in_use && mesh_slots[i].generation != UINT32_MAX) return i;
    }
    return -1;
}

static MeshSlot *mesh_slot(uint64_t token) {
    uint32_t slot = (uint32_t)token;
    uint32_t generation = (uint32_t)(token >> 32);
    if (!IsWindowReady() || (slot & MESH_TOKEN_TAG) == 0 || generation == 0) return NULL;
    slot &= ~MESH_TOKEN_TAG;
    if (slot == 0 || slot > GRL_MAX_MESHES) return NULL;
    MeshSlot *entry = &mesh_slots[slot - 1];
    return entry->in_use && entry->generation == generation ? entry : NULL;
}

static uint64_t retain_mesh(int slot, Mesh mesh) {
    Model owner = LoadModelFromMesh(mesh);
    if (!valid_native_model(owner)) {
        dispose_model(owner);
        return 0;
    }
    MeshSlot *entry = &mesh_slots[slot];
    entry->generation++;
    entry->owner = owner;
    entry->in_use = 1;
    return ((uint64_t)entry->generation << 32) | MESH_TOKEN_TAG | (uint64_t)(slot + 1);
}

static int positive_dimension(float value) { return isfinite(value) && value > 0; }
static int subdivisions(int value, int minimum) {
    return value >= minimum && value <= GRL_MAX_MESH_SUBDIVISIONS;
}

uint64_t grl_gen_mesh_poly(int32_t sides, float radius) {
    if (!IsWindowReady() || !subdivisions(sides, 3) || !positive_dimension(radius)) return 0;
    int slot = free_mesh_slot();
    return slot >= 0 ? retain_mesh(slot, GenMeshPoly(sides, radius)) : 0;
}
uint64_t grl_gen_mesh_plane(float width, float length, int32_t res_x, int32_t res_z) {
    if (!IsWindowReady() || !positive_dimension(width) || !positive_dimension(length) ||
        !subdivisions(res_x, 1) || !subdivisions(res_z, 1)) return 0;
    int slot = free_mesh_slot();
    return slot >= 0 ? retain_mesh(slot, GenMeshPlane(width, length, res_x, res_z)) : 0;
}
uint64_t grl_gen_mesh_cube(float width, float height, float length) {
    if (!IsWindowReady() || !positive_dimension(width) || !positive_dimension(height) ||
        !positive_dimension(length)) return 0;
    int slot = free_mesh_slot();
    return slot >= 0 ? retain_mesh(slot, GenMeshCube(width, height, length)) : 0;
}
uint64_t grl_gen_mesh_sphere(float radius, int32_t rings, int32_t slices) {
    if (!IsWindowReady() || !positive_dimension(radius) ||
        !subdivisions(rings, 3) || !subdivisions(slices, 3)) return 0;
    int slot = free_mesh_slot();
    return slot >= 0 ? retain_mesh(slot, GenMeshSphere(radius, rings, slices)) : 0;
}
uint64_t grl_gen_mesh_hemi_sphere(float radius, int32_t rings, int32_t slices) {
    if (!IsWindowReady() || !positive_dimension(radius) ||
        !subdivisions(rings, 3) || !subdivisions(slices, 3)) return 0;
    int slot = free_mesh_slot();
    return slot >= 0 ? retain_mesh(slot, GenMeshHemiSphere(radius, rings, slices)) : 0;
}
uint64_t grl_gen_mesh_cylinder(float radius, float height, int32_t slices) {
    if (!IsWindowReady() || !positive_dimension(radius) || !positive_dimension(height) ||
        !subdivisions(slices, 3)) return 0;
    int slot = free_mesh_slot();
    return slot >= 0 ? retain_mesh(slot, GenMeshCylinder(radius, height, slices)) : 0;
}
uint64_t grl_gen_mesh_cone(float radius, float height, int32_t slices) {
    if (!IsWindowReady() || !positive_dimension(radius) || !positive_dimension(height) ||
        !subdivisions(slices, 3)) return 0;
    int slot = free_mesh_slot();
    return slot >= 0 ? retain_mesh(slot, GenMeshCone(radius, height, slices)) : 0;
}

uint8_t grl_is_mesh_valid(uint64_t token) {
    MeshSlot *entry = mesh_slot(token);
    return entry != NULL && IsModelValid(entry->owner);
}
uint8_t grl_unload_mesh(uint64_t token) {
    MeshSlot *entry = mesh_slot(token);
    if (entry == NULL) return 0;
    Model owner = entry->owner;
    entry->in_use = 0;
    entry->owner = (Model){0};
    dispose_model(owner);
    return 1;
}
int32_t grl_unload_all_meshes(void) {
    int32_t count = 0;
    if (!IsWindowReady()) return 0;
    for (int i = 0; i < GRL_MAX_MESHES; ++i) {
        if (mesh_slots[i].in_use) {
            uint64_t token = ((uint64_t)mesh_slots[i].generation << 32) | MESH_TOKEN_TAG | (uint64_t)(i + 1);
            count += grl_unload_mesh(token);
        }
    }
    return count;
}
int32_t grl_mesh_vertex_count(uint64_t token) {
    MeshSlot *entry = mesh_slot(token);
    return entry != NULL ? entry->owner.meshes[0].vertexCount : 0;
}
int32_t grl_mesh_triangle_count(uint64_t token) {
    MeshSlot *entry = mesh_slot(token);
    return entry != NULL ? entry->owner.meshes[0].triangleCount : 0;
}
uint8_t grl_get_mesh_bounding_box(uint64_t token, void *out) {
    MeshSlot *entry = mesh_slot(token);
    BoundingBox box = entry != NULL ? GetMeshBoundingBox(entry->owner.meshes[0]) : (BoundingBox){0};
    float fields[6] = {box.min.x, box.min.y, box.min.z, box.max.x, box.max.y, box.max.z};
    memcpy(out, fields, sizeof(fields));
    return entry != NULL;
}
uint8_t grl_draw_mesh(uint64_t token, const void *transform, uint32_t rgba) {
    MeshSlot *entry = mesh_slot(token);
    if (entry == NULL) return 0;
    float f[16];
    memcpy(f, transform, sizeof(f));
    for (int i = 0; i < 16; ++i) if (!isfinite(f[i])) return 0;
    Matrix matrix = {f[0], f[1], f[2], f[3], f[4], f[5], f[6], f[7],
                     f[8], f[9], f[10], f[11], f[12], f[13], f[14], f[15]};
    Material material = entry->owner.materials[0];
    Color original = material.maps[MATERIAL_MAP_ALBEDO].color;
    material.maps[MATERIAL_MAP_ALBEDO].color = model_color(rgba);
    DrawMesh(entry->owner.meshes[0], material, matrix);
    material.maps[MATERIAL_MAP_ALBEDO].color = original;
    return 1;
}
uint64_t grl_load_model_from_mesh(uint64_t token) {
    MeshSlot *entry = mesh_slot(token);
    if (entry == NULL || !IsModelValid(entry->owner)) return 0;
    int slot = free_model_slot();
    if (slot < 0) return 0;
    /* The owner is already a validated single-mesh model. Moving its complete
     * native container preserves every CPU pointer and GPU ID, cannot fail
     * after reservation, and never uploads or deep-copies the mesh again. */
    uint64_t model = store_model(slot, entry->owner);
    entry->in_use = 0;
    entry->owner = (Model){0};
    return model;
}
