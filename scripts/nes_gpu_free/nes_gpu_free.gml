/// @function nes_gpu_free()
/// @description Releases every surface and buffer the GPU renderer owns; safe to call when nothing is allocated.
function nes_gpu_free() {
    var _surfaces = ["gpu_chr_surf", "gpu_nt_surf", "gpu_pal_surf", "gpu_state_surf"];
    for (var _i = 0; _i < array_length(_surfaces); _i++) {
        var _n = _surfaces[_i];
        if (variable_global_exists(_n)) {
            var _s = variable_global_get(_n);
            if (_s >= 0 && surface_exists(_s)) surface_free(_s);
            variable_global_set(_n, -1);
        }
    }

    var _buffers = ["gpu_chr_buf", "gpu_nt_buf", "gpu_pal_buf", "gpu_state_buf", "gpu_oam"];
    for (var _i = 0; _i < array_length(_buffers); _i++) {
        var _n = _buffers[_i];
        if (variable_global_exists(_n)) {
            var _b = variable_global_get(_n);
            if (_b >= 0 && buffer_exists(_b)) buffer_delete(_b);
            variable_global_set(_n, -1);
        }
    }

    global.gpu_ready = false;
}
