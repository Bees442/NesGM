/// @function nes_cpu_op_rra()
/// @description RRA - rotate memory right, then add it to A.
function nes_cpu_op_rra() {
    var _r = nes_cpu_rmw_ror(nes_cpu_read(global.cpu_ea));
    nes_cpu_write(global.cpu_ea, _r);
    nes_cpu_op_adc(_r);
}
