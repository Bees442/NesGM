function nes_cpu_op_cmp(_reg, _v) {
    var _r = (_reg - _v) & 0xFF;
    if (_reg >= _v) global.cpu_p |= 0x01; else global.cpu_p &= 0xFE;
    nes_cpu_set_zn(_r);
}
