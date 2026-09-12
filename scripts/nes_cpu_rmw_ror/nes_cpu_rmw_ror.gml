function nes_cpu_rmw_ror(_v) {
    var _c = global.cpu_p & 0x01;
    if (_v & 0x01) global.cpu_p |= 0x01; else global.cpu_p &= 0xFE;
    var _r = (_v >> 1) | (_c << 7);
    nes_cpu_set_zn(_r);
    return _r;
}
