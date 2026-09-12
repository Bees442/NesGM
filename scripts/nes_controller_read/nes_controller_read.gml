function nes_controller_read(_index) {
    if (global.controller_strobe) {
        return global.controller_state[_index] & 1;
    }
    var _bit = global.controller_shift[_index] & 1;
    global.controller_shift[_index] = (global.controller_shift[_index] >> 1) | 0x80;
    return _bit;
}
