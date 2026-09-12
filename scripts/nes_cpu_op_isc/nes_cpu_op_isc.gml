/// @function nes_cpu_op_isc()
/// @description ISC/ISB - increment memory, then subtract it from A.
function nes_cpu_op_isc() {
    var _r = (nes_cpu_read(global.cpu_ea) + 1) & 0xFF;
    nes_cpu_write(global.cpu_ea, _r);
    nes_cpu_op_sbc(_r);
}
