#include "raylib_render_textures.h"
#include <math.h>
#include <rlgl.h>

typedef struct {
    RenderTexture2D target;
    uint32_t generation;
    uint8_t in_use;
} RenderTextureSlot;

#define RENDER_TEXTURE_TOKEN_TAG UINT32_C(0x40000000)
static RenderTextureSlot render_texture_slots[GRL_MAX_RENDER_TEXTURES];
static uint64_t active_render_texture;

static int free_render_texture_slot(void) {
    for (int i = 0; i < GRL_MAX_RENDER_TEXTURES; ++i) {
        if (!render_texture_slots[i].in_use && render_texture_slots[i].generation != UINT32_MAX) return i;
    }
    return -1;
}
static RenderTextureSlot *render_texture_slot(uint64_t token) {
    uint32_t slot = (uint32_t)token;
    uint32_t generation = (uint32_t)(token >> 32);
    if (!IsWindowReady() || (slot & RENDER_TEXTURE_TOKEN_TAG) == 0 || generation == 0) return NULL;
    slot &= ~RENDER_TEXTURE_TOKEN_TAG;
    if (slot == 0 || slot > GRL_MAX_RENDER_TEXTURES) return NULL;
    RenderTextureSlot *entry = &render_texture_slots[slot - 1];
    return entry->in_use && entry->generation == generation ? entry : NULL;
}
static uint64_t retain_render_texture(int slot, RenderTexture2D target) {
    /* Upstream's validity query checks IDs/metadata, not FBO completeness.
     * Both this check and native unload bind framebuffers, hence mode guards. */
    if (!IsRenderTextureValid(target) || !rlFramebufferComplete(target.id)) {
        UnloadRenderTexture(target);
        return 0;
    }
    RenderTextureSlot *entry = &render_texture_slots[slot];
    entry->generation++;
    entry->target = target;
    entry->in_use = 1;
    return ((uint64_t)entry->generation << 32) | RENDER_TEXTURE_TOKEN_TAG | (uint64_t)(slot + 1);
}

uint64_t grl_load_render_texture(int32_t width, int32_t height) {
    if (!IsWindowReady() || active_render_texture != 0 || width <= 0 || height <= 0 ||
        width > GRL_MAX_RENDER_TEXTURE_SIZE || height > GRL_MAX_RENDER_TEXTURE_SIZE) return 0;
    int slot = free_render_texture_slot();
    if (slot < 0) return 0;
    rlDrawRenderBatchActive();
    return retain_render_texture(slot, LoadRenderTexture(width, height));
}
uint8_t grl_is_render_texture_valid(uint64_t token) {
    RenderTextureSlot *entry = render_texture_slot(token);
    return entry != NULL && IsRenderTextureValid(entry->target);
}
int32_t grl_render_texture_width(uint64_t token) {
    RenderTextureSlot *entry = render_texture_slot(token);
    return entry != NULL ? entry->target.texture.width : 0;
}
int32_t grl_render_texture_height(uint64_t token) {
    RenderTextureSlot *entry = render_texture_slot(token);
    return entry != NULL ? entry->target.texture.height : 0;
}
uint8_t grl_unload_render_texture(uint64_t token) {
    RenderTextureSlot *entry = render_texture_slot(token);
    if (entry == NULL || active_render_texture != 0) return 0;
    /* DrawTexture* queues geometry. Issue outstanding samples before deleting
     * their source texture, even when the caller unloads before EndDrawing. */
    rlDrawRenderBatchActive();
    RenderTexture2D target = entry->target;
    entry->in_use = 0;
    entry->target = (RenderTexture2D){0};
    UnloadRenderTexture(target);  // also frees the depth attachment through rlgl
    return 1;
}
int32_t grl_unload_all_render_textures(void) {
    if (!IsWindowReady() || active_render_texture != 0) return 0;
    int32_t count = 0;
    for (int i = 0; i < GRL_MAX_RENDER_TEXTURES; ++i) {
        if (render_texture_slots[i].in_use) {
            uint64_t token = ((uint64_t)render_texture_slots[i].generation << 32) |
                RENDER_TEXTURE_TOKEN_TAG | (uint64_t)(i + 1);
            count += grl_unload_render_texture(token);
        }
    }
    return count;
}
uint8_t grl_begin_texture_mode(uint64_t token) {
    RenderTextureSlot *entry = render_texture_slot(token);
    if (entry == NULL || active_render_texture != 0) return 0;
    BeginTextureMode(entry->target);
    active_render_texture = token;
    return 1;
}
uint8_t grl_end_texture_mode(void) {
    if (!IsWindowReady() || active_render_texture == 0) return 0;
    EndTextureMode();
    active_render_texture = 0;
    return 1;
}
uint8_t grl_is_texture_mode_active(void) {
    return IsWindowReady() && active_render_texture != 0;
}
static Color render_texture_color(uint32_t c) {
    return (Color){(unsigned char)(c >> 24), (unsigned char)(c >> 16),
        (unsigned char)(c >> 8), (unsigned char)c};
}
uint8_t grl_draw_render_texture(uint64_t token, int32_t x, int32_t y, uint32_t rgba) {
    RenderTextureSlot *entry = render_texture_slot(token);
    if (entry == NULL || token == active_render_texture) return 0;
    DrawTextureRec(entry->target.texture,
        (Rectangle){0, 0, (float)entry->target.texture.width, -(float)entry->target.texture.height},
        (Vector2){(float)x, (float)y}, render_texture_color(rgba));
    return 1;
}
uint8_t grl_draw_render_texture_pro(uint64_t token,
    float sx, float sy, float sw, float sh, float dx, float dy, float dw, float dh,
    float ox, float oy, float rotation, uint32_t rgba) {
    RenderTextureSlot *entry = render_texture_slot(token);
    if (entry == NULL || token == active_render_texture) return 0;
    float values[11] = {sx, sy, sw, sh, dx, dy, dw, dh, ox, oy, rotation};
    for (int i = 0; i < 11; ++i) if (!isfinite(values[i])) return 0;
    DrawTexturePro(entry->target.texture, (Rectangle){sx, sy, sw, sh},
        (Rectangle){dx, dy, dw, dh}, (Vector2){ox, oy}, rotation, render_texture_color(rgba));
    return 1;
}
void grl_shutdown_render_textures(void) {
    if (!IsWindowReady()) return;
    grl_end_texture_mode();
    grl_unload_all_render_textures();
}
