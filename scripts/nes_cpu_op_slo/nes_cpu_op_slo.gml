/// @function nes_cpu_op_slo()
/// @description SLO - shift memory left, then OR it into A.
function nes_cpu_op_slo() {
    var _r = nes_cpu_rmw_asl(nes_cpu_read(global.cpu_ea));
    nes_cpu_write(global.cpu_ea, _r);
    global.cpu_a |= _r;
    nes_cpu_set_zn(global.cpu_a);
}
