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

#endif
