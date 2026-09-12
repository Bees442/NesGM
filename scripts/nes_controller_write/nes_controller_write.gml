function nes_controller_write(_value) {
    var _strobe = (_value & 1) != 0;
    global.controller_strobe = _strobe;
    if (_strobe) {
        global.controller_shift[0] = global.controller_state[0];
        global.controller_shift[1] = global.controller_state[1];
    }
}
