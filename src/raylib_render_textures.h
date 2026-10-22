#ifndef GOOSE_RAYLIB_RENDER_TEXTURES_H
#define GOOSE_RAYLIB_RENDER_TEXTURES_H

#include "raylib_adapter.h"

#define GRL_MAX_RENDER_TEXTURES 64
#define GRL_MAX_RENDER_TEXTURE_SIZE 4096

/* Generation/kind tokens own the native FBO, color texture and depth buffer.
 * No raw Texture2D is lent to callers, so attachments cannot be freed twice. */
uint64_t grl_load_render_texture(int32_t width, int32_t height);
uint8_t grl_is_render_texture_valid(uint64_t token);
int32_t grl_render_texture_width(uint64_t token);
int32_t grl_render_texture_height(uint64_t token);
/* Creation/unload are rejected while any managed texture mode is active. */
uint8_t grl_unload_render_texture(uint64_t token);
int32_t grl_unload_all_render_textures(void);
uint8_t grl_begin_texture_mode(uint64_t token);
uint8_t grl_end_texture_mode(void);
uint8_t grl_is_texture_mode_active(void);
/* Convenience draw: whole target, upright, at 1:1 scale. */
uint8_t grl_draw_render_texture(uint64_t token, int32_t x, int32_t y, uint32_t rgba);
/* Raw DrawTexturePro source-rectangle convention; negative source height flips
 * FBO textures upright. Rotation is in degrees. Feedback into self is rejected. */
uint8_t grl_draw_render_texture_pro(uint64_t token,
    float sx, float sy, float sw, float sh, float dx, float dy, float dw, float dh,
    float ox, float oy, float rotation, uint32_t rgba);
/* Window-close hook ends an active mode, flushes draws and releases all targets. */
void grl_shutdown_render_textures(void);

#endif
