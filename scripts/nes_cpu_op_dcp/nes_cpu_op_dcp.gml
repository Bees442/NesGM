/// @function nes_cpu_op_dcp()
/// @description DCP - decrement memory, then compare it against A.
function nes_cpu_op_dcp() {
    var _r = (nes_cpu_read(global.cpu_ea) - 1) & 0xFF;
    nes_cpu_write(global.cpu_ea, _r);
    nes_cpu_op_cmp(global.cpu_a, _r);
}
