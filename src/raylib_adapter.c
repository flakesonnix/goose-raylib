#include "raylib_adapter.h"

static char rl_adapter_buffer[RL_ADAPTER_MAX_STR];

const char *rl_to_c_string(goose_slice_u8 s) {
    size_t n = (size_t)s.len;
    if (n >= RL_ADAPTER_MAX_STR) n = RL_ADAPTER_MAX_STR - 1;
    memcpy(rl_adapter_buffer, s.data, n);
    rl_adapter_buffer[n] = '\0';
    return rl_adapter_buffer;
}

void rl_draw_text(goose_slice_u8 text, int x, int y, int fontSize, Color color) {
    DrawText(rl_to_c_string(text), x, y, fontSize, color);
}

int rl_measure_text(goose_slice_u8 text, int fontSize) {
    return MeasureText(rl_to_c_string(text), fontSize);
}

void rl_set_window_title(goose_slice_u8 title) {
    SetWindowTitle(rl_to_c_string(title));
}

/* --- Texture2D --- */

goose_texture2d rl_load_texture(goose_slice_u8 fileName) {
    Texture2D t = LoadTexture(rl_to_c_string(fileName));
    goose_texture2d g;
    g.id = t.id;
    g.width = t.width;
    g.height = t.height;
    g.mipmaps = t.mipmaps;
    g.format = t.format;
    return g;
}

void rl_unload_texture(goose_texture2d texture) {
    Texture2D t;
    t.id = texture.id;
    t.width = texture.width;
    t.height = texture.height;
    t.mipmaps = texture.mipmaps;
    t.format = texture.format;
    UnloadTexture(t);
}

void rl_draw_texture(goose_texture2d texture, int posX, int posY, Color tint) {
    Texture2D t;
    t.id = texture.id;
    t.width = texture.width;
    t.height = texture.height;
    t.mipmaps = texture.mipmaps;
    t.format = texture.format;
    DrawTexture(t, posX, posY, tint);
}

void rl_draw_texture_ex(goose_texture2d texture, int posX, int posY, float rotation, float scale, Color tint) {
    Texture2D t;
    t.id = texture.id;
    t.width = texture.width;
    t.height = texture.height;
    t.mipmaps = texture.mipmaps;
    t.format = texture.format;
    DrawTextureEx(t, (Vector2){ (float)posX, (float)posY }, rotation, scale, tint);
}

void rl_draw_texture_rec(goose_texture2d texture, int sourceX, int sourceY, int sourceW, int sourceH, int posX, int posY, Color tint) {
    Texture2D t;
    t.id = texture.id;
    t.width = texture.width;
    t.height = texture.height;
    t.mipmaps = texture.mipmaps;
    t.format = texture.format;
    Rectangle source = { (float)sourceX, (float)sourceY, (float)sourceW, (float)sourceH };
    DrawTextureRec(t, source, (Vector2){ (float)posX, (float)posY }, tint);
}

/* --- Image (metadata only) --- */

int rl_image_width(goose_slice_u8 fileName) {
    Image im = LoadImage(rl_to_c_string(fileName));
    int w = im.width;
    UnloadImage(im);
    return w;
}

int rl_image_height(goose_slice_u8 fileName) {
    Image im = LoadImage(rl_to_c_string(fileName));
    int h = im.height;
    UnloadImage(im);
    return h;
}

int rl_image_format(goose_slice_u8 fileName) {
    Image im = LoadImage(rl_to_c_string(fileName));
    int f = im.format;
    UnloadImage(im);
    return f;
}
