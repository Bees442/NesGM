/// @function nes_cpu_run_frame()
/// @description Runs instructions until the PPU signals end of frame; returns how many it ran.
function nes_cpu_run_frame() {
    var _prg = global.prg_buf;
    var _pmap = global.prg_map;
    var _den = global.ppu_dot_den;
    var _num = global.ppu_dot_num;
    var _carry = global.ppu_dot_carry;
    var _dot = global.ppu_dot;
    var _apu_on = global.apu_enabled;
    var _batch = global.apu_batch_cycles;

    // The first dot >= the current one at which the PPU has something to do; 340 stands in for
    // "nothing left before the scanline wraps". An event at dot D fires when D falls in
    // [_dot, _end), so no event is due exactly while _end <= _next_ev, and advancing the
    // counter is the whole job - one comparison instead of re-testing every boundary.
    var _next_ev;
    if (_dot <= 1) _next_ev = 1;
    else if (_dot <= 256) _next_ev = 256;
    else if (_dot <= 257) _next_ev = 257;
    else if (_dot <= 280) _next_ev = 280;
    else _next_ev = 340;

    var _count = 0;
    while (!global.ppu_frame_ready && _count < 200000) {
        _count += 1;

        var _cyc;
        if (global.ppu_nmi_line) {
            global.ppu_nmi_line = false;
            nes_cpu_push16(global.cpu_pc);
            nes_cpu_push8((global.cpu_p & 0xEF) | 0x20);
            global.cpu_p |= 0x04;
            global.cpu_pc = nes_cpu_read(0xFFFA) | (nes_cpu_read(0xFFFB) << 8);
            _cyc = 7;
        } else if (global.cpu_irq_line && (global.cpu_p & 0x04) == 0) {
            nes_cpu_push16(global.cpu_pc);
            nes_cpu_push8((global.cpu_p & 0xEF) | 0x20);
            global.cpu_p |= 0x04;
            global.cpu_pc = nes_cpu_read(0xFFFE) | (nes_cpu_read(0xFFFF) << 8);
            _cyc = 7;
        } else {
            // One buffer read collects the opcode and the three bytes behind it, which is every
            // operand any instruction can have; nes_cpu_addr then unpacks what it needs without
            // touching the buffer again. -1 tells it to fall back to reading byte by byte.
            var _pc = global.cpu_pc;
            var _opcode;
            if (_pc >= 0x8000) {
                var _off = _pc & 0x1FFF;
                var _addr = _pmap[(_pc >> 13) & 3] | _off;
                if (_off <= 0x1FFC) {
                    var _w = buffer_peek(_prg, _addr, buffer_u32);
                    global.cpu_opw = _w;
                    _opcode = _w & 0xFF;
                } else {
                    global.cpu_opw = -1;
                    _opcode = buffer_peek(_prg, _addr, buffer_u8);
                }
            } else {
                global.cpu_opw = -1;
                _opcode = nes_cpu_read(_pc);
            }
            global.cpu_pc = _pc + 1;
            _cyc = nes_cpu_execute(_opcode);
        }

        if (global.dma_extra_cycles > 0) {
            _cyc += global.dma_extra_cycles;
            global.dma_extra_cycles = 0;
        }

        var _dots;
        if (_den == 1) {
            _dots = _cyc * 3;
        } else {
            var _acc = _carry + _cyc * _num;
            _dots = _acc div _den;
            _carry = _acc - _dots * _den;
        }

        var _end = _dot + _dots;
        if (_end <= _next_ev) {
            _dot = _end;
        } else {
            global.ppu_dot = _dot;
            nes_ppu_run(_dots);
            _dot = global.ppu_dot;
            if (_dot <= 1) _next_ev = 1;
            else if (_dot <= 256) _next_ev = 256;
            else if (_dot <= 257) _next_ev = 257;
            else if (_dot <= 280) _next_ev = 280;
            else _next_ev = 340;
        }

        if (_apu_on) {
            _batch += _cyc;
            if (_batch >= NES_APU_BATCH_CYCLES) {
                nes_apu_run(_batch);
                _batch = 0;
            }
        }
    }

    global.ppu_dot = _dot;
    global.ppu_dot_carry = _carry;
    global.apu_batch_cycles = _batch;
    return _count;
}
