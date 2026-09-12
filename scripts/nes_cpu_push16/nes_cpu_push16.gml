function nes_cpu_push16(_v) {
    nes_cpu_push8((_v >> 8) & 0xFF);
    nes_cpu_push8(_v & 0xFF);
}
