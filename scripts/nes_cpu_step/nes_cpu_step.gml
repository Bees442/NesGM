// nes_cpu: 2A03 CPU core - a MOS 6502 interpreter covering all 151 official opcodes plus the
// stable undocumented ones, instruction-stepped (each call to nes_cpu_step() runs exactly one
// instruction and returns the cycles it took; nes_bus/nes_ppu/nes_apu are advanced from there).
// No decimal mode, since the 2A03 has none. The handful of genuinely unstable undocumented
// opcodes (ANE, LXA, TAS, SHA/SHX/SHY) are deliberately left out: their real behaviour depends
// on analog effects, and no licensed game relies on them. One of those reaching the CPU logs a
// message via nes_cpu_unimplemented and costs 2 cycles, so a ROM can't hang on it.
//
// Addressing modes (passed to nes_cpu_addr as small ints): 1=IMM 2=ZP 3=ZPX 4=ZPY 5=ABS
// 6=ABSX 7=ABSY 8=INDX 9=INDY 10=IND(JMP only) 11=REL(branches). Implied/accumulator
// opcodes don't call nes_cpu_addr at all.

/// @function nes_cpu_step()
/// @description Services a pending NMI (or a pending IRQ, if interrupts aren't masked),
/// otherwise fetches and executes one instruction. Either way, advances the PPU (3x cycles)
/// and APU (1x cycles) by the CPU cycles spent (plus any OAM DMA stall) and returns the CPU
/// cycle count. NMI wins over IRQ, exactly as on hardware.
function nes_cpu_step() {
    var _cyc;

    if (global.ppu_nmi_line) {
        global.ppu_nmi_line = false;
        nes_cpu_push16(global.cpu_pc);
        nes_cpu_push8((global.cpu_p & 0xEF) | 0x20);
        global.cpu_p |= 0x04;
        global.cpu_pc = nes_cpu_read(0xFFFA) | (nes_cpu_read(0xFFFB) << 8);
        _cyc = 7;
    } else if (global.cpu_irq_line && (global.cpu_p & 0x04) == 0) {
        // Level-triggered: the line stays asserted until the mapper/APU clears it, so it is
        // deliberately NOT cleared here - the handler acknowledging the device does that.
        nes_cpu_push16(global.cpu_pc);
        nes_cpu_push8((global.cpu_p & 0xEF) | 0x20);
        global.cpu_p |= 0x04;
        global.cpu_pc = nes_cpu_read(0xFFFE) | (nes_cpu_read(0xFFFF) << 8);
        _cyc = 7;
    } else {
        // Opcode fetch, with the PRG-ROM case inlined. Code virtually always runs from
        // $8000-$FFFF, and skipping nes_cpu_read's dispatch saves one call per instruction -
        // about 30k calls a frame, which the VM feels even though YYC would not.
        var _pc = global.cpu_pc;
        var _opcode;
        if (_pc >= 0x8000) {
            _opcode = buffer_peek(global.prg_buf, global.prg_map[(_pc >> 13) & 3] | (_pc & 0x1FFF), buffer_u8);
        } else {
            _opcode = nes_cpu_read(_pc);
        }
        global.cpu_pc = _pc + 1;
        global.cpu_opw = -1;
        _cyc = nes_cpu_execute(_opcode);
    }

    if (global.dma_extra_cycles > 0) {
        _cyc += global.dma_extra_cycles;
        global.dma_extra_cycles = 0;
    }

    // How many PPU dots those CPU cycles bought. NTSC is a flat 3 per cycle; PAL is 3.2, which
    // is carried as the exact fraction 16/5 with the remainder kept between instructions, so it
    // stays on integers and cannot drift the way repeated 3.2 additions would.
    var _dots;
    if (global.ppu_dot_den == 1) {
        _dots = _cyc * 3;
    } else {
        var _carry = global.ppu_dot_carry + _cyc * global.ppu_dot_num;
        _dots = _carry div global.ppu_dot_den;
        global.ppu_dot_carry = _carry - _dots * global.ppu_dot_den;
    }

    // Inlined copy of nes_ppu_run's fast path (kept in sync with it): an instruction usually
    // stays inside the current scanline and crosses none of the event dots (1, 256, 257, 280),
    // in which case advancing the counter is all there is to do. Same motive as the fetch
    // above - one less call per instruction.
    var _dot = global.ppu_dot;
    var _end = _dot + _dots;
    if (_end < 341 && (_dot > 280 || _end <= 1 || (_dot > 1 && _end <= 256) || (_dot > 257 && _end <= 280))) {
        global.ppu_dot = _end;
    } else {
        nes_ppu_run(_dots);
    }

    // The APU is only advanced every NES_APU_BATCH_CYCLES or so rather than every instruction.
    // Its frame sequencer works in thousands of cycles and its output samples are ~80 cycles
    // apart, so batching costs no audible accuracy while removing another ~28k calls a frame.
    if (global.apu_enabled) {
        var _batch = global.apu_batch_cycles + _cyc;
        if (_batch >= NES_APU_BATCH_CYCLES) {
            global.apu_batch_cycles = 0;
            nes_apu_run(_batch);
        } else {
            global.apu_batch_cycles = _batch;
        }
    }

    return _cyc;
}
