/// @function nes_ppu_build_decode_table()
/// @description Builds the 64K lookup that turns a tile row's two bitplane bytes into eight packed 2-bit pixels.
function nes_ppu_build_decode_table() {
    if (variable_global_exists("ppu_decode")) return;

    var _t = array_create(65536, 0);
    for (var _hi = 0; _hi < 256; _hi++) {
        for (var _lo = 0; _lo < 256; _lo++) {
            var _packed = 0;
            for (var _px = 0; _px < 8; _px++) {
                var _bit = 7 - _px;
                var _val = ((_lo >> _bit) & 1) | (((_hi >> _bit) & 1) << 1);
                _packed |= _val << (_px * 2);
            }
            _t[(_hi << 8) | _lo] = _packed;
        }
    }
    global.ppu_decode = _t;
}
