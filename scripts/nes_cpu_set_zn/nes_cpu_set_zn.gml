/// @function nes_cpu_set_zn(value)
/// @description Sets the zero and negative flags from `value`. Nearly every instruction ends
/// in one of these, so the two flag bits come from a 256-entry table and land in P with a
/// single read-modify-write instead of two branches and two writes.
function nes_cpu_set_zn(_v) {
    global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[_v & 0xFF];
}
