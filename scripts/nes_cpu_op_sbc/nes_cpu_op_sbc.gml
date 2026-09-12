function nes_cpu_op_sbc(_v) {
    nes_cpu_op_adc((_v ^ 0xFF) & 0xFF);
}
