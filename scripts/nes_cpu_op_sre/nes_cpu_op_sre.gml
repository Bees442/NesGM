/// @function nes_cpu_op_sre()
/// @description SRE - shift memory right, then EOR it into A.
function nes_cpu_op_sre() {
    var _r = nes_cpu_rmw_lsr(nes_cpu_read(global.cpu_ea));
    nes_cpu_write(global.cpu_ea, _r);
    global.cpu_a ^= _r;
    nes_cpu_set_zn(global.cpu_a);
}
