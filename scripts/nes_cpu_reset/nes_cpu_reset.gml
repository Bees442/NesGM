/// @function nes_cpu_reset()
/// @description Resets registers and loads PC from the reset vector ($FFFC/$FFFD).
function nes_cpu_reset() {
    nes_cpu_build_zn_table(); // no-op after the first ROM load

    global.cpu_a = 0;
    global.cpu_x = 0;
    global.cpu_y = 0;
    global.cpu_sp = 0xFD;
    global.cpu_p = 0x24;
    global.cpu_irq_line = false;
    global.cpu_opw = -1;
    global.cpu_pc = nes_cpu_read(0xFFFC) | (nes_cpu_read(0xFFFD) << 8);
}
