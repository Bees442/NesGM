function nes_cpu_pop8() {
    global.cpu_sp = (global.cpu_sp + 1) & 0xFF;
    return nes_cpu_read(0x100 + global.cpu_sp);
}
