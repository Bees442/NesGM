function nes_cpu_push8(_v) {
    nes_cpu_write(0x100 + global.cpu_sp, _v & 0xFF);
    global.cpu_sp = (global.cpu_sp - 1) & 0xFF;
}
