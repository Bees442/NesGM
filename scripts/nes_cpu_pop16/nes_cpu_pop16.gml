function nes_cpu_pop16() {
    var _lo = nes_cpu_pop8();
    var _hi = nes_cpu_pop8();
    return _lo | (_hi << 8);
}
