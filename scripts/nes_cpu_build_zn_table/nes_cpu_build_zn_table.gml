/// @function nes_cpu_build_zn_table()
/// @description Builds the Z/N flag lookup used by nes_cpu_set_zn. Entry v holds 0x02 when v
/// is zero and 0x80 when its high bit is set - exactly the bits to OR into P.
function nes_cpu_build_zn_table() {
    if (variable_global_exists("cpu_zn_table")) return;

    var _t = array_create(256, 0);
    _t[0] = 0x02;
    for (var _i = 128; _i < 256; _i++) _t[_i] = 0x80;
    global.cpu_zn_table = _t;
}
