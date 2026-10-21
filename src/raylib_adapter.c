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
