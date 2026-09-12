function nes_cpu_op_bit(_v) {
    var _r = global.cpu_a & _v;
    if (_r == 0) global.cpu_p |= 0x02; else global.cpu_p &= 0xFD;
    if (_v & 0x80) global.cpu_p |= 0x80; else global.cpu_p &= 0x7F;
    if (_v & 0x40) global.cpu_p |= 0x40; else global.cpu_p &= 0xBF;
}
