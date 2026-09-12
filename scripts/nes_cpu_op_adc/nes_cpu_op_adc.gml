function nes_cpu_op_adc(_v) {
    var _a = global.cpu_a;
    var _c = global.cpu_p & 0x01;
    var _sum = _a + _v + _c;
    var _result = _sum & 0xFF;
    if (_sum > 0xFF) global.cpu_p |= 0x01; else global.cpu_p &= 0xFE;
    if (((_a ^ _result) & (_v ^ _result) & 0x80) != 0) global.cpu_p |= 0x40; else global.cpu_p &= 0xBF;
    global.cpu_a = _result;
    nes_cpu_set_zn(_result);
}
