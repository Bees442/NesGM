function nes_cpu_branch(_cond) {
    var _cyc = 2;
    if (_cond) {
        var _old_pc = global.cpu_pc;
        _cyc += 1;
        if ((_old_pc & 0xFF00) != (global.cpu_ea & 0xFF00)) _cyc += 1;
        global.cpu_pc = global.cpu_ea;
    }
    return _cyc;
}
