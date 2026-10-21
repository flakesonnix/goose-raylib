#ifndef RAYLIB_ADAPTER_H
#define RAYLIB_ADAPTER_H

#include <raylib.h>
#include <stdint.h>
#include <string.h>

/*
 * goose-raylib C adapter
 * ----------------------
 *
 * Goose u8[:] slices cross the ABI as a { data, len } struct.  Raylib expects
 * null-terminated const char * strings, so we convert here.  The buffer is
 * static and valid until the next call to any rl_* string function, which is
 * sufficient because Raylib copies strings internally where it needs to keep
 * them.
 */

typedef struct {
    const uint8_t *data;
    int64_t len;
} goose_slice_u8;

#define RL_ADAPTER_MAX_STR 4096

const char *rl_to_c_string(goose_slice_u8 s);

/* String-accepting raylib wrappers (called via Goose extern fn) */
void rl_draw_text(goose_slice_u8 text, int x, int y, int fontSize, Color color);
int rl_measure_text(goose_slice_u8 text, int fontSize);
void rl_set_window_title(goose_slice_u8 title);

/* --- Texture2D (Phase B) --- */

/*
 * Goose-compatible copy of raylib Texture2D, without any pointer fields.
 * Layout matches C: { u32 id, i32 width, i32 height, i32 mipmaps, i32 format }
 */
typedef struct {
    unsigned int id;
    int width;
    int height;
    int mipmaps;
    int format;
} goose_texture2d;

/* Load a texture from file. Returns a goose_texture2d copy of the C struct. */
goose_texture2d rl_load_texture(goose_slice_u8 fileName);

/* Unload a texture previously loaded with rl_load_texture. */
void rl_unload_texture(goose_texture2d texture);

/* Draw a texture at a position with a tint color. */
void rl_draw_texture(goose_texture2d texture, int posX, int posY, Color tint);

/* Draw a texture extended (position, rotation, scale, tint). */
void rl_draw_texture_ex(goose_texture2d texture, int posX, int posY, float rotation, float scale, Color tint);

/* Draw a texture defined by a source rectangle. */
void rl_draw_texture_rec(goose_texture2d texture, int sourceX, int sourceY, int sourceW, int sourceH, int posX, int posY, Color tint);

/* --- Image (Phase B, metadata only) --- */

/*
 * Goose-compatible copy of raylib Image without the void *data pointer.
 * Goose cannot hold raw C pointers, so only metadata is exposed.
 */
typedef struct {
    int width;
    int height;
    int mipmaps;
    int format;
} goose_image;

/* Query image dimensions from file without keeping the C Image around. */
int rl_image_width(goose_slice_u8 fileName);
int rl_image_height(goose_slice_u8 fileName);
int rl_image_format(goose_slice_u8 fileName);

/* --- Audio (Phase C) --- */

/*
 * Sound handle system.
 *
 * raylib's Sound struct contains an AudioStream with pointer fields, so it
 * cannot be copied by value across the Goose/C ABI.  Instead the adapter
 * keeps a static table of loaded Sounds and hands out numeric handles.
 * Goose code only ever sees the handle (i32), never the raw C struct.
 */

#define RL_ADAPTER_MAX_SOUNDS 64

typedef struct {
    int in_use;
    Sound sound;
} goose_sound_slot;

void rl_init_audio_device(void);
void rl_close_audio_device(void);
int rl_is_audio_device_ready(void);
int rl_load_sound(goose_slice_u8 fileName);          // returns sound handle (i32), or -1 on failure
void rl_unload_sound(int handle);
void rl_play_sound(int handle);
void rl_stop_sound(int handle);
void rl_pause_sound(int handle);
void rl_resume_sound(int handle);
int rl_is_sound_playing(int handle);
void rl_set_sound_volume(int handle, float volume);
void rl_set_sound_pitch(int handle, float pitch);
void rl_set_sound_pan(int handle, float pan);

#endif
