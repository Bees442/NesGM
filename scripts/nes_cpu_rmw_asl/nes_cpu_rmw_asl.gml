function nes_cpu_rmw_asl(_v) {
    if (_v & 0x80) global.cpu_p |= 0x01; else global.cpu_p &= 0xFE;
    var _r = (_v << 1) & 0xFF;
    nes_cpu_set_zn(_r);
    return _r;
}
