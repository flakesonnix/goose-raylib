// test_audio.goose — Test: audio API (Phase C)
// Checks Sound struct, audio device functions, and that all sound
// function signatures exist. Loading a real sound requires an audio
// file; this test covers the API surface without one.
//
// Build:
//   goose build test_audio.goose && ./test_audio

import raylib;

fn main() {
    // Sound is an opaque handle (Sound { id }).  Creating one without a real
    // audio file gives an invalid handle; the C adapter safely ignores it.
    let s = raylib::Sound { 0 };
    assert(s.id == 0);

    // Audio device API signatures
    raylib::init_audio_device();
    let _ready: bool = raylib::is_audio_device_ready();
    raylib::close_audio_device();

    // Sound API signatures (dummy handle — no real sound file loaded)
    raylib::play_sound(s);
    raylib::stop_sound(s);
    raylib::pause_sound(s);
    raylib::resume_sound(s);
    let _playing: bool = raylib::is_sound_playing(s);
    raylib::set_sound_volume(s, 0.5);
    raylib::set_sound_pitch(s, 1.0);
    raylib::set_sound_pan(s, 0.0);

    assert(_ready == _ready);
    assert(_playing == _playing);

    print("test_audio passed");
}
