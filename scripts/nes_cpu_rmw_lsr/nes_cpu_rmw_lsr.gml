function nes_cpu_rmw_lsr(_v) {
    if (_v & 0x01) global.cpu_p |= 0x01; else global.cpu_p &= 0xFE;
    var _r = (_v >> 1) & 0xFF;
    nes_cpu_set_zn(_r);
    return _r;
}
