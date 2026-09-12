/// @function nes_cpu_op_rla()
/// @description RLA - rotate memory left, then AND it into A.
function nes_cpu_op_rla() {
    var _r = nes_cpu_rmw_rol(nes_cpu_read(global.cpu_ea));
    nes_cpu_write(global.cpu_ea, _r);
    global.cpu_a &= _r;
    nes_cpu_set_zn(global.cpu_a);
}
