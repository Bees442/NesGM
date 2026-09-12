/// @function nes_ppu_run(cycles)
/// @description Advances the PPU by the given number of dots (call with 3x CPU cycles), in scanline-sized chunks.
function nes_ppu_run(_cycles) {
    var _dot = global.ppu_dot;

    var _end = _dot + _cycles;
    if (_end < 341) {
        if (_dot > 280 || _end <= 1 || (_dot > 1 && _end <= 256) || (_dot > 257 && _end <= 280)) {
            global.ppu_dot = _end;
            return;
        }
    }

    var _remaining = _cycles;
    while (_remaining > 0) {
        var _sl = global.ppu_scanline;
        _dot = global.ppu_dot;
        var _last = global.ppu_last_scanline;
        var _len = 341;
        if (!global.region_pal && _sl == _last && global.ppu_frame_odd && ((global.ppu_mask & 0x18) != 0)) _len = 340;

        var _room = _len - _dot;
        if (_remaining < _room) {
            nes_ppu_scanline_events(_sl, _dot, _dot + _remaining);
            global.ppu_dot = _dot + _remaining;
            _remaining = 0;
        } else {
            nes_ppu_scanline_events(_sl, _dot, _len);
            _remaining -= _room;
            global.ppu_dot = 0;
            _sl += 1;
            if (_sl > _last) {
                _sl = 0;
                global.ppu_frame_odd = !global.ppu_frame_odd;
            }
            global.ppu_scanline = _sl;
        }
    }
}
