/// @function nes_cpu_op_lax()
/// @description LAX - load the operand into both A and X.
function nes_cpu_op_lax() {
    var _v = nes_cpu_read(global.cpu_ea);
    global.cpu_a = _v;
    global.cpu_x = _v;
    nes_cpu_set_zn(_v);
}
