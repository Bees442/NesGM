/// @function nes_ppu_increment_y()
/// @description Standard "increment vertical position in v" step, run at dot 256 of rendered scanlines.
function nes_ppu_increment_y() {
    var _v = global.ppu_v;
    if ((_v & 0x7000) != 0x7000) {
        _v += 0x1000;
    } else {
        _v &= 0x8FFF;
        var _y = (_v & 0x03E0) >> 5;
        if (_y == 29) {
            _y = 0;
            _v ^= 0x0800;
        } else if (_y == 31) {
            _y = 0;
        } else {
            _y += 1;
        }
        _v = (_v & 0xFC1F) | (_y << 5);
    }
    global.ppu_v = _v;
}
