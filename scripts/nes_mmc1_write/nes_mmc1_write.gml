/// @function nes_mmc1_write(addr, value)
function nes_mmc1_write(_addr, _value) {
    var _s = global.cart.state;

    if (_value & 0x80) {
        _s.shift = 0x10;
        _s.control |= 0x0C;
        nes_mmc1_apply();
        return;
    }

    var _complete = (_s.shift & 1) != 0;
    _s.shift = (_s.shift >> 1) | ((_value & 1) << 4);

    if (_complete) {
        var _reg = (_addr >> 13) & 3;
        var _v = _s.shift & 0x1F;
        switch (_reg) {
            case 0: _s.control = _v; break;
            case 1: _s.chr0 = _v; break;
            case 2: _s.chr1 = _v; break;
            case 3: _s.prg = _v; break;
        }
        _s.shift = 0x10;
        nes_mmc1_apply();
    }
}
