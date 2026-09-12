function nes_apu_take_buffer(_bytes) {
    var _i = global.apu_ring_index;
    global.apu_ring_index = (_i + 1) mod NES_APU_RING_SIZE;

    var _buf = global.apu_ring[_i];
    if (_buf < 0 || !buffer_exists(_buf) || buffer_get_size(_buf) < _bytes) {
        if (_buf >= 0 && buffer_exists(_buf)) buffer_delete(_buf);
        _buf = buffer_create(max(_bytes, 4096), buffer_fixed, 2);
        global.apu_ring[_i] = _buf;
    }
    return _buf;
}
