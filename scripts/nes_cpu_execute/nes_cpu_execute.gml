/// @function nes_cpu_execute(opcode)
/// @description Decodes and runs one instruction. Returns its base cycle cost (including
/// the +1 page-cross penalty where applicable); does not include OAM DMA stalls.
function nes_cpu_execute(_opcode) {
    var _cyc = 2;

    // Two-level dispatch: the outer switch narrows on the opcode's high nibble and the
    // inner one picks the exact opcode. GML's VM scans switch cases linearly, so one flat
    // switch over ~250 opcodes cost ~124 comparisons on every instruction executed - by far
    // the emulator's largest single expense when profiled. Two levels bring that to about
    // 8 + 8. The cases themselves are unchanged; only their grouping is.
    switch (_opcode >> 4) {
    case 0xA:
        switch (_opcode) {
        case 0xA9: nes_cpu_addr(1); _cyc = 2; global.cpu_a = nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; break;
        case 0xA5: nes_cpu_addr(2); _cyc = 3; global.cpu_a = nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; break;
        case 0xAD: nes_cpu_addr(8); _cyc = 4; global.cpu_a = nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; break;
        case 0xA1: nes_cpu_addr(5); _cyc = 6; global.cpu_a = nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; break;
        case 0xA2: nes_cpu_addr(1); _cyc = 2; global.cpu_x = nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_x & 0xFF]; break;
        case 0xA6: nes_cpu_addr(2); _cyc = 3; global.cpu_x = nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_x & 0xFF]; break;
        case 0xAE: nes_cpu_addr(8); _cyc = 4; global.cpu_x = nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_x & 0xFF]; break;
        case 0xA0: nes_cpu_addr(1); _cyc = 2; global.cpu_y = nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_y & 0xFF]; break;
        case 0xA4: nes_cpu_addr(2); _cyc = 3; global.cpu_y = nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_y & 0xFF]; break;
        case 0xAC: nes_cpu_addr(8); _cyc = 4; global.cpu_y = nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_y & 0xFF]; break;
        case 0xAA: global.cpu_x = global.cpu_a; global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_x & 0xFF]; _cyc = 2; break; // TAX
        case 0xA8: global.cpu_y = global.cpu_a; global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_y & 0xFF]; _cyc = 2; break; // TAY
        case 0xA7: nes_cpu_addr(2); _cyc = 3; nes_cpu_op_lax(); break;
        case 0xAF: nes_cpu_addr(8); _cyc = 4; nes_cpu_op_lax(); break;
        case 0xA3: nes_cpu_addr(5); _cyc = 6; nes_cpu_op_lax(); break;
        default: _cyc = nes_cpu_unimplemented(_opcode); break;
        }
        break;

    case 0xD:
        switch (_opcode) {
        case 0xD0: nes_cpu_addr(7); _cyc = nes_cpu_branch((global.cpu_p & 0x02) == 0); break; // BNE
        case 0xD8: global.cpu_p &= 0xF7; _cyc = 2; break; // CLD
        case 0xD5: nes_cpu_addr(3); _cyc = 4; nes_cpu_op_cmp(global.cpu_a, nes_cpu_read(global.cpu_ea)); break;
        case 0xDD: nes_cpu_addr(9); _cyc = 4 + global.cpu_page_crossed; nes_cpu_op_cmp(global.cpu_a, nes_cpu_read(global.cpu_ea)); break;
        case 0xD9: nes_cpu_addr(10); _cyc = 4 + global.cpu_page_crossed; nes_cpu_op_cmp(global.cpu_a, nes_cpu_read(global.cpu_ea)); break;
        case 0xD1: nes_cpu_addr(6); _cyc = 5 + global.cpu_page_crossed; nes_cpu_op_cmp(global.cpu_a, nes_cpu_read(global.cpu_ea)); break;
        case 0xD6: { nes_cpu_addr(3); _cyc = 6; var _r = (nes_cpu_read(global.cpu_ea) - 1) & 0xFF; nes_cpu_write(global.cpu_ea, _r); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[_r & 0xFF]; break; }
        case 0xDE: { nes_cpu_addr(9); _cyc = 7; var _r = (nes_cpu_read(global.cpu_ea) - 1) & 0xFF; nes_cpu_write(global.cpu_ea, _r); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[_r & 0xFF]; break; }
        case 0xDA: _cyc = 2; break;
        case 0xD4:
            // zero page,X
            nes_cpu_addr(3); _cyc = 4; break;
        case 0xDC:
            // absolute,X
            nes_cpu_addr(9); _cyc = 4 + global.cpu_page_crossed; break;
        case 0xD7: nes_cpu_addr(3); _cyc = 6; nes_cpu_op_dcp(); break;
        case 0xDF: nes_cpu_addr(9); _cyc = 7; nes_cpu_op_dcp(); break;
        case 0xDB: nes_cpu_addr(10); _cyc = 7; nes_cpu_op_dcp(); break;
        case 0xD3: nes_cpu_addr(6); _cyc = 8; nes_cpu_op_dcp(); break;
        case 0xD2:
            show_debug_message("nes_cpu: KIL/JAM opcode 0x" + nes_to_hex(_opcode, 2) + " at PC=0x" + nes_to_hex(global.cpu_pc - 1, 4) + " - halting CPU would hang the emulator, treating as NOP");
            _cyc = 2;
            break;
        default: _cyc = nes_cpu_unimplemented(_opcode); break;
        }
        break;

    case 0xB:
        switch (_opcode) {
        case 0xB0: nes_cpu_addr(7); _cyc = nes_cpu_branch((global.cpu_p & 0x01) != 0); break; // BCS
        case 0xB8: global.cpu_p &= 0xBF; _cyc = 2; break; // CLV
        case 0xB5: nes_cpu_addr(3); _cyc = 4; global.cpu_a = nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; break;
        case 0xBD: nes_cpu_addr(9); _cyc = 4 + global.cpu_page_crossed; global.cpu_a = nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; break;
        case 0xB9: nes_cpu_addr(10); _cyc = 4 + global.cpu_page_crossed; global.cpu_a = nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; break;
        case 0xB1: nes_cpu_addr(6); _cyc = 5 + global.cpu_page_crossed; global.cpu_a = nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; break;
        case 0xB6: nes_cpu_addr(4); _cyc = 4; global.cpu_x = nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_x & 0xFF]; break;
        case 0xBE: nes_cpu_addr(10); _cyc = 4 + global.cpu_page_crossed; global.cpu_x = nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_x & 0xFF]; break;
        case 0xB4: nes_cpu_addr(3); _cyc = 4; global.cpu_y = nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_y & 0xFF]; break;
        case 0xBC: nes_cpu_addr(9); _cyc = 4 + global.cpu_page_crossed; global.cpu_y = nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_y & 0xFF]; break;
        case 0xBA: global.cpu_x = global.cpu_sp; global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_x & 0xFF]; _cyc = 2; break; // TSX
        case 0xB7: nes_cpu_addr(4); _cyc = 4; nes_cpu_op_lax(); break;
        case 0xBF: nes_cpu_addr(10); _cyc = 4 + global.cpu_page_crossed; nes_cpu_op_lax(); break;
        case 0xB3: nes_cpu_addr(6); _cyc = 5 + global.cpu_page_crossed; nes_cpu_op_lax(); break;
        case 0xB2:
            show_debug_message("nes_cpu: KIL/JAM opcode 0x" + nes_to_hex(_opcode, 2) + " at PC=0x" + nes_to_hex(global.cpu_pc - 1, 4) + " - halting CPU would hang the emulator, treating as NOP");
            _cyc = 2;
            break;
        default: _cyc = nes_cpu_unimplemented(_opcode); break;
        }
        break;

    case 0x9:
        switch (_opcode) {
        case 0x90: nes_cpu_addr(7); _cyc = nes_cpu_branch((global.cpu_p & 0x01) == 0); break; // BCC
        case 0x95: nes_cpu_addr(3); _cyc = 4; nes_cpu_write(global.cpu_ea, global.cpu_a); break;
        case 0x9D: nes_cpu_addr(9); _cyc = 5; nes_cpu_write(global.cpu_ea, global.cpu_a); break;
        case 0x99: nes_cpu_addr(10); _cyc = 5; nes_cpu_write(global.cpu_ea, global.cpu_a); break;
        case 0x91: nes_cpu_addr(6); _cyc = 6; nes_cpu_write(global.cpu_ea, global.cpu_a); break;
        case 0x96: nes_cpu_addr(4); _cyc = 4; nes_cpu_write(global.cpu_ea, global.cpu_x); break;
        case 0x94: nes_cpu_addr(3); _cyc = 4; nes_cpu_write(global.cpu_ea, global.cpu_y); break;
        case 0x9A: global.cpu_sp = global.cpu_x; _cyc = 2; break; // TXS
        case 0x98:
            global.cpu_a = global.cpu_y; global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; _cyc = 2; break; // TYA

        // ================= unofficial / undocumented opcodes =================
        // Not part of the published 6502 instruction set, but stable on the 2A03 and used by
        // a fair number of commercial games (and by test ROMs), so a game hitting one of these
        // would otherwise misbehave or hang. The unstable//highly-analog ones (ANE/$8B, LXA/$AB,
        // TAS/$9B, SHA/SHX/SHY) are deliberately left out - their real behaviour depends on
        // analog effects no emulator reproduces identically, and no licensed game relies on them.

        // ---- NOPs: implied (1 byte) ----
        case 0x97: nes_cpu_addr(4); _cyc = 4; nes_cpu_write(global.cpu_ea, global.cpu_a & global.cpu_x); break;
        case 0x92:
            show_debug_message("nes_cpu: KIL/JAM opcode 0x" + nes_to_hex(_opcode, 2) + " at PC=0x" + nes_to_hex(global.cpu_pc - 1, 4) + " - halting CPU would hang the emulator, treating as NOP");
            _cyc = 2;
            break;
        default: _cyc = nes_cpu_unimplemented(_opcode); break;
        }
        break;

    case 0x8:
        switch (_opcode) {
        case 0x88:
            global.cpu_y = (global.cpu_y - 1) & 0xFF; global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_y & 0xFF]; _cyc = 2; break; // DEY

        // ---- EOR ----
        case 0x85: nes_cpu_addr(2); _cyc = 3; nes_cpu_write(global.cpu_ea, global.cpu_a); break;
        case 0x8D: nes_cpu_addr(8); _cyc = 4; nes_cpu_write(global.cpu_ea, global.cpu_a); break;
        case 0x81: nes_cpu_addr(5); _cyc = 6; nes_cpu_write(global.cpu_ea, global.cpu_a); break;
        case 0x86: nes_cpu_addr(2); _cyc = 3; nes_cpu_write(global.cpu_ea, global.cpu_x); break;
        case 0x8E: nes_cpu_addr(8); _cyc = 4; nes_cpu_write(global.cpu_ea, global.cpu_x); break;
        case 0x84: nes_cpu_addr(2); _cyc = 3; nes_cpu_write(global.cpu_ea, global.cpu_y); break;
        case 0x8C: nes_cpu_addr(8); _cyc = 4; nes_cpu_write(global.cpu_ea, global.cpu_y); break;
        case 0x8A: global.cpu_a = global.cpu_x; global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; _cyc = 2; break; // TXA
        case 0x80: case 0x82: case 0x89:
            // immediate
            nes_cpu_addr(1); _cyc = 2; break;
        case 0x87: nes_cpu_addr(2); _cyc = 3; nes_cpu_write(global.cpu_ea, global.cpu_a & global.cpu_x); break;
        case 0x8F: nes_cpu_addr(8); _cyc = 4; nes_cpu_write(global.cpu_ea, global.cpu_a & global.cpu_x); break;
        case 0x83: nes_cpu_addr(5); _cyc = 6; nes_cpu_write(global.cpu_ea, global.cpu_a & global.cpu_x); break;
        default: _cyc = nes_cpu_unimplemented(_opcode); break;
        }
        break;

    case 0xF:
        switch (_opcode) {
        case 0xF0: nes_cpu_addr(7); _cyc = nes_cpu_branch((global.cpu_p & 0x02) != 0); break; // BEQ
        case 0xF8:
            global.cpu_p |= 0x08; _cyc = 2; break; // SED

        // ---- CMP ----
        case 0xF6: { nes_cpu_addr(3); _cyc = 6; var _r = (nes_cpu_read(global.cpu_ea) + 1) & 0xFF; nes_cpu_write(global.cpu_ea, _r); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[_r & 0xFF]; break; }
        case 0xFE: { nes_cpu_addr(9); _cyc = 7; var _r = (nes_cpu_read(global.cpu_ea) + 1) & 0xFF; nes_cpu_write(global.cpu_ea, _r); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[_r & 0xFF]; break; }
        case 0xF5: nes_cpu_addr(3); _cyc = 4; nes_cpu_op_sbc(nes_cpu_read(global.cpu_ea)); break;
        case 0xFD: nes_cpu_addr(9); _cyc = 4 + global.cpu_page_crossed; nes_cpu_op_sbc(nes_cpu_read(global.cpu_ea)); break;
        case 0xF9: nes_cpu_addr(10); _cyc = 4 + global.cpu_page_crossed; nes_cpu_op_sbc(nes_cpu_read(global.cpu_ea)); break;
        case 0xF1: nes_cpu_addr(6); _cyc = 5 + global.cpu_page_crossed; nes_cpu_op_sbc(nes_cpu_read(global.cpu_ea)); break;
        case 0xFA: _cyc = 2; break;
        case 0xF4:
            // zero page,X
            nes_cpu_addr(3); _cyc = 4; break;
        case 0xFC:
            // absolute,X
            nes_cpu_addr(9); _cyc = 4 + global.cpu_page_crossed; break;
        case 0xF7: nes_cpu_addr(3); _cyc = 6; nes_cpu_op_isc(); break;
        case 0xFF: nes_cpu_addr(9); _cyc = 7; nes_cpu_op_isc(); break;
        case 0xFB: nes_cpu_addr(10); _cyc = 7; nes_cpu_op_isc(); break;
        case 0xF3: nes_cpu_addr(6); _cyc = 8; nes_cpu_op_isc(); break;
        case 0xF2:
            show_debug_message("nes_cpu: KIL/JAM opcode 0x" + nes_to_hex(_opcode, 2) + " at PC=0x" + nes_to_hex(global.cpu_pc - 1, 4) + " - halting CPU would hang the emulator, treating as NOP");
            _cyc = 2;
            break;
        default: _cyc = nes_cpu_unimplemented(_opcode); break;
        }
        break;
    case 0x2:
        switch (_opcode) {
        case 0x29: nes_cpu_addr(1); _cyc = 2; global.cpu_a &= nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; break;
        case 0x25: nes_cpu_addr(2); _cyc = 3; global.cpu_a &= nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; break;
        case 0x2D: nes_cpu_addr(8); _cyc = 4; global.cpu_a &= nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; break;
        case 0x21: nes_cpu_addr(5); _cyc = 6; global.cpu_a &= nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; break;
        case 0x24: nes_cpu_addr(2); _cyc = 3; nes_cpu_op_bit(nes_cpu_read(global.cpu_ea)); break;
        case 0x2C: nes_cpu_addr(8); _cyc = 4; nes_cpu_op_bit(nes_cpu_read(global.cpu_ea)); break;
        case 0x20:
            {
            nes_cpu_addr(8);
            nes_cpu_push16(global.cpu_pc - 1);
            global.cpu_pc = global.cpu_ea;
            _cyc = 6;
            break;
        }
        case 0x28:
            global.cpu_p = (nes_cpu_pop8() & 0xEF) | 0x20; _cyc = 4; break; // PLP

        // ---- ROL / ROR ----
        case 0x2A: _cyc = 2; global.cpu_a = nes_cpu_rmw_rol(global.cpu_a); break;
        case 0x26: nes_cpu_addr(2); _cyc = 5; nes_cpu_write(global.cpu_ea, nes_cpu_rmw_rol(nes_cpu_read(global.cpu_ea))); break;
        case 0x2E: nes_cpu_addr(8); _cyc = 6; nes_cpu_write(global.cpu_ea, nes_cpu_rmw_rol(nes_cpu_read(global.cpu_ea))); break;
        case 0x27: nes_cpu_addr(2); _cyc = 5; nes_cpu_op_rla(); break;
        case 0x2F: nes_cpu_addr(8); _cyc = 6; nes_cpu_op_rla(); break;
        case 0x23: nes_cpu_addr(5); _cyc = 8; nes_cpu_op_rla(); break;
        case 0x2B:
            { // ANC - AND, then copy bit 7 into carry
            nes_cpu_addr(1); _cyc = 2;
            global.cpu_a &= nes_cpu_read(global.cpu_ea);
            global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF];
            if (global.cpu_a & 0x80) global.cpu_p |= 0x01; else global.cpu_p &= 0xFE;
            break;
        }
        case 0x22:
            show_debug_message("nes_cpu: KIL/JAM opcode 0x" + nes_to_hex(_opcode, 2) + " at PC=0x" + nes_to_hex(global.cpu_pc - 1, 4) + " - halting CPU would hang the emulator, treating as NOP");
            _cyc = 2;
            break;
        default: _cyc = nes_cpu_unimplemented(_opcode); break;
        }
        break;

    case 0x4:
        switch (_opcode) {
        case 0x49: nes_cpu_addr(1); _cyc = 2; global.cpu_a ^= nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; break;
        case 0x45: nes_cpu_addr(2); _cyc = 3; global.cpu_a ^= nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; break;
        case 0x4D: nes_cpu_addr(8); _cyc = 4; global.cpu_a ^= nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; break;
        case 0x41: nes_cpu_addr(5); _cyc = 6; global.cpu_a ^= nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; break;
        case 0x4C: nes_cpu_addr(8); global.cpu_pc = global.cpu_ea; _cyc = 3; break;
        case 0x4A: _cyc = 2; global.cpu_a = nes_cpu_rmw_lsr(global.cpu_a); break;
        case 0x46: nes_cpu_addr(2); _cyc = 5; nes_cpu_write(global.cpu_ea, nes_cpu_rmw_lsr(nes_cpu_read(global.cpu_ea))); break;
        case 0x4E: nes_cpu_addr(8); _cyc = 6; nes_cpu_write(global.cpu_ea, nes_cpu_rmw_lsr(nes_cpu_read(global.cpu_ea))); break;
        case 0x48: nes_cpu_push8(global.cpu_a); _cyc = 3; break; // PHA
        case 0x40: global.cpu_p = (nes_cpu_pop8() & 0xEF) | 0x20; global.cpu_pc = nes_cpu_pop16(); _cyc = 6; break;
        case 0x44:
            // zero page
            nes_cpu_addr(2); _cyc = 3; break;
        case 0x47: nes_cpu_addr(2); _cyc = 5; nes_cpu_op_sre(); break;
        case 0x4F: nes_cpu_addr(8); _cyc = 6; nes_cpu_op_sre(); break;
        case 0x43: nes_cpu_addr(5); _cyc = 8; nes_cpu_op_sre(); break;
        case 0x4B:
            { // ALR - AND then LSR A
            nes_cpu_addr(1); _cyc = 2;
            global.cpu_a &= nes_cpu_read(global.cpu_ea);
            global.cpu_a = nes_cpu_rmw_lsr(global.cpu_a);
            break;
        }
        case 0x42:
            show_debug_message("nes_cpu: KIL/JAM opcode 0x" + nes_to_hex(_opcode, 2) + " at PC=0x" + nes_to_hex(global.cpu_pc - 1, 4) + " - halting CPU would hang the emulator, treating as NOP");
            _cyc = 2;
            break;
        default: _cyc = nes_cpu_unimplemented(_opcode); break;
        }
        break;

    case 0x6:
        switch (_opcode) {
        case 0x69: nes_cpu_addr(1); _cyc = 2; nes_cpu_op_adc(nes_cpu_read(global.cpu_ea)); break;
        case 0x65: nes_cpu_addr(2); _cyc = 3; nes_cpu_op_adc(nes_cpu_read(global.cpu_ea)); break;
        case 0x6D: nes_cpu_addr(8); _cyc = 4; nes_cpu_op_adc(nes_cpu_read(global.cpu_ea)); break;
        case 0x61: nes_cpu_addr(5); _cyc = 6; nes_cpu_op_adc(nes_cpu_read(global.cpu_ea)); break;
        case 0x6C: nes_cpu_addr(11); global.cpu_pc = global.cpu_ea; _cyc = 5; break;
        case 0x68: global.cpu_a = nes_cpu_pop8(); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; _cyc = 4; break; // PLA
        case 0x6A: _cyc = 2; global.cpu_a = nes_cpu_rmw_ror(global.cpu_a); break;
        case 0x66: nes_cpu_addr(2); _cyc = 5; nes_cpu_write(global.cpu_ea, nes_cpu_rmw_ror(nes_cpu_read(global.cpu_ea))); break;
        case 0x6E: nes_cpu_addr(8); _cyc = 6; nes_cpu_write(global.cpu_ea, nes_cpu_rmw_ror(nes_cpu_read(global.cpu_ea))); break;
        case 0x60: global.cpu_pc = (nes_cpu_pop16() + 1) & 0xFFFF; _cyc = 6; break;
        case 0x64:
            // zero page
            nes_cpu_addr(2); _cyc = 3; break;
        case 0x67: nes_cpu_addr(2); _cyc = 5; nes_cpu_op_rra(); break;
        case 0x6F: nes_cpu_addr(8); _cyc = 6; nes_cpu_op_rra(); break;
        case 0x63: nes_cpu_addr(5); _cyc = 8; nes_cpu_op_rra(); break;
        case 0x6B:
            { // ARR - AND then ROR A, with its own peculiar C/V flag behaviour
            nes_cpu_addr(1); _cyc = 2;
            var _v = global.cpu_a & nes_cpu_read(global.cpu_ea);
            var _r = (_v >> 1) | ((global.cpu_p & 0x01) << 7);
            global.cpu_a = _r;
            global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[_r & 0xFF];
            if (_r & 0x40) global.cpu_p |= 0x01; else global.cpu_p &= 0xFE;
            if (((_r >> 6) ^ (_r >> 5)) & 1) global.cpu_p |= 0x40; else global.cpu_p &= 0xBF;
            break;
        }
        case 0x62:
            show_debug_message("nes_cpu: KIL/JAM opcode 0x" + nes_to_hex(_opcode, 2) + " at PC=0x" + nes_to_hex(global.cpu_pc - 1, 4) + " - halting CPU would hang the emulator, treating as NOP");
            _cyc = 2;
            break;
        default: _cyc = nes_cpu_unimplemented(_opcode); break;
        }
        break;

    case 0xE:
        switch (_opcode) {
        case 0xE0: nes_cpu_addr(1); _cyc = 2; nes_cpu_op_cmp(global.cpu_x, nes_cpu_read(global.cpu_ea)); break;
        case 0xE4: nes_cpu_addr(2); _cyc = 3; nes_cpu_op_cmp(global.cpu_x, nes_cpu_read(global.cpu_ea)); break;
        case 0xEC: nes_cpu_addr(8); _cyc = 4; nes_cpu_op_cmp(global.cpu_x, nes_cpu_read(global.cpu_ea)); break;
        case 0xE6: { nes_cpu_addr(2); _cyc = 5; var _r = (nes_cpu_read(global.cpu_ea) + 1) & 0xFF; nes_cpu_write(global.cpu_ea, _r); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[_r & 0xFF]; break; }
        case 0xEE: { nes_cpu_addr(8); _cyc = 6; var _r = (nes_cpu_read(global.cpu_ea) + 1) & 0xFF; nes_cpu_write(global.cpu_ea, _r); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[_r & 0xFF]; break; }
        case 0xE8: global.cpu_x = (global.cpu_x + 1) & 0xFF; global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_x & 0xFF]; _cyc = 2; break; // INX
        case 0xEA: _cyc = 2; break;
        case 0xE9: nes_cpu_addr(1); _cyc = 2; nes_cpu_op_sbc(nes_cpu_read(global.cpu_ea)); break;
        case 0xE5: nes_cpu_addr(2); _cyc = 3; nes_cpu_op_sbc(nes_cpu_read(global.cpu_ea)); break;
        case 0xED: nes_cpu_addr(8); _cyc = 4; nes_cpu_op_sbc(nes_cpu_read(global.cpu_ea)); break;
        case 0xE1: nes_cpu_addr(5); _cyc = 6; nes_cpu_op_sbc(nes_cpu_read(global.cpu_ea)); break;
        case 0xE2:
            // immediate
            nes_cpu_addr(1); _cyc = 2; break;
        case 0xE7: nes_cpu_addr(2); _cyc = 5; nes_cpu_op_isc(); break;
        case 0xEF: nes_cpu_addr(8); _cyc = 6; nes_cpu_op_isc(); break;
        case 0xE3: nes_cpu_addr(5); _cyc = 8; nes_cpu_op_isc(); break;
        case 0xEB: nes_cpu_addr(1); _cyc = 2; nes_cpu_op_sbc(nes_cpu_read(global.cpu_ea)); break;
        default: _cyc = nes_cpu_unimplemented(_opcode); break;
        }
        break;

    case 0xC:
        switch (_opcode) {
        case 0xC9: nes_cpu_addr(1); _cyc = 2; nes_cpu_op_cmp(global.cpu_a, nes_cpu_read(global.cpu_ea)); break;
        case 0xC5: nes_cpu_addr(2); _cyc = 3; nes_cpu_op_cmp(global.cpu_a, nes_cpu_read(global.cpu_ea)); break;
        case 0xCD: nes_cpu_addr(8); _cyc = 4; nes_cpu_op_cmp(global.cpu_a, nes_cpu_read(global.cpu_ea)); break;
        case 0xC1: nes_cpu_addr(5); _cyc = 6; nes_cpu_op_cmp(global.cpu_a, nes_cpu_read(global.cpu_ea)); break;
        case 0xC0: nes_cpu_addr(1); _cyc = 2; nes_cpu_op_cmp(global.cpu_y, nes_cpu_read(global.cpu_ea)); break;
        case 0xC4: nes_cpu_addr(2); _cyc = 3; nes_cpu_op_cmp(global.cpu_y, nes_cpu_read(global.cpu_ea)); break;
        case 0xCC: nes_cpu_addr(8); _cyc = 4; nes_cpu_op_cmp(global.cpu_y, nes_cpu_read(global.cpu_ea)); break;
        case 0xC6: { nes_cpu_addr(2); _cyc = 5; var _r = (nes_cpu_read(global.cpu_ea) - 1) & 0xFF; nes_cpu_write(global.cpu_ea, _r); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[_r & 0xFF]; break; }
        case 0xCE: { nes_cpu_addr(8); _cyc = 6; var _r = (nes_cpu_read(global.cpu_ea) - 1) & 0xFF; nes_cpu_write(global.cpu_ea, _r); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[_r & 0xFF]; break; }
        case 0xCA: global.cpu_x = (global.cpu_x - 1) & 0xFF; global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_x & 0xFF]; _cyc = 2; break; // DEX
        case 0xC8:
            global.cpu_y = (global.cpu_y + 1) & 0xFF; global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_y & 0xFF]; _cyc = 2; break; // INY

        // ---- JMP / JSR ----
        case 0xC2:
            // immediate
            nes_cpu_addr(1); _cyc = 2; break;
        case 0xC7: nes_cpu_addr(2); _cyc = 5; nes_cpu_op_dcp(); break;
        case 0xCF: nes_cpu_addr(8); _cyc = 6; nes_cpu_op_dcp(); break;
        case 0xC3: nes_cpu_addr(5); _cyc = 8; nes_cpu_op_dcp(); break;
        case 0xCB:
            {
            nes_cpu_addr(1); _cyc = 2;
            var _v = nes_cpu_read(global.cpu_ea);
            var _t = global.cpu_a & global.cpu_x;
            if (_t >= _v) global.cpu_p |= 0x01; else global.cpu_p &= 0xFE;
            global.cpu_x = (_t - _v) & 0xFF;
            global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_x & 0xFF];
            break;
        }
        default: _cyc = nes_cpu_unimplemented(_opcode); break;
        }
        break;

    case 0x1:
        switch (_opcode) {
        case 0x16: nes_cpu_addr(3); _cyc = 6; nes_cpu_write(global.cpu_ea, nes_cpu_rmw_asl(nes_cpu_read(global.cpu_ea))); break;
        case 0x1E: nes_cpu_addr(9); _cyc = 7; nes_cpu_write(global.cpu_ea, nes_cpu_rmw_asl(nes_cpu_read(global.cpu_ea))); break;
        case 0x10: nes_cpu_addr(7); _cyc = nes_cpu_branch((global.cpu_p & 0x80) == 0); break; // BPL
        case 0x18: global.cpu_p &= 0xFE; _cyc = 2; break; // CLC
        case 0x15: nes_cpu_addr(3); _cyc = 4; global.cpu_a |= nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; break;
        case 0x1D: nes_cpu_addr(9); _cyc = 4 + global.cpu_page_crossed; global.cpu_a |= nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; break;
        case 0x19: nes_cpu_addr(10); _cyc = 4 + global.cpu_page_crossed; global.cpu_a |= nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; break;
        case 0x11: nes_cpu_addr(6); _cyc = 5 + global.cpu_page_crossed; global.cpu_a |= nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; break;
        case 0x1A: _cyc = 2; break;
        case 0x14:
            // zero page,X
            nes_cpu_addr(3); _cyc = 4; break;
        case 0x1C:
            // absolute,X
            nes_cpu_addr(9); _cyc = 4 + global.cpu_page_crossed; break;
        case 0x17: nes_cpu_addr(3); _cyc = 6; nes_cpu_op_slo(); break;
        case 0x1F: nes_cpu_addr(9); _cyc = 7; nes_cpu_op_slo(); break;
        case 0x1B: nes_cpu_addr(10); _cyc = 7; nes_cpu_op_slo(); break;
        case 0x13: nes_cpu_addr(6); _cyc = 8; nes_cpu_op_slo(); break;
        case 0x12:
            show_debug_message("nes_cpu: KIL/JAM opcode 0x" + nes_to_hex(_opcode, 2) + " at PC=0x" + nes_to_hex(global.cpu_pc - 1, 4) + " - halting CPU would hang the emulator, treating as NOP");
            _cyc = 2;
            break;
        default: _cyc = nes_cpu_unimplemented(_opcode); break;
        }
        break;

    case 0x0:
        switch (_opcode) {
        case 0x0A: _cyc = 2; global.cpu_a = nes_cpu_rmw_asl(global.cpu_a); break;
        case 0x06: nes_cpu_addr(2); _cyc = 5; nes_cpu_write(global.cpu_ea, nes_cpu_rmw_asl(nes_cpu_read(global.cpu_ea))); break;
        case 0x0E: nes_cpu_addr(8); _cyc = 6; nes_cpu_write(global.cpu_ea, nes_cpu_rmw_asl(nes_cpu_read(global.cpu_ea))); break;
        case 0x00:
            {
            global.cpu_pc += 1;
            nes_cpu_push16(global.cpu_pc);
            nes_cpu_push8(global.cpu_p | 0x30);
            global.cpu_p |= 0x04;
            global.cpu_pc = nes_cpu_read(0xFFFE) | (nes_cpu_read(0xFFFF) << 8);
            _cyc = 7;
            break;
        }
        case 0x09: nes_cpu_addr(1); _cyc = 2; global.cpu_a |= nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; break;
        case 0x05: nes_cpu_addr(2); _cyc = 3; global.cpu_a |= nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; break;
        case 0x0D: nes_cpu_addr(8); _cyc = 4; global.cpu_a |= nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; break;
        case 0x01: nes_cpu_addr(5); _cyc = 6; global.cpu_a |= nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; break;
        case 0x08: nes_cpu_push8(global.cpu_p | 0x30); _cyc = 3; break; // PHP
        case 0x04:
            // zero page
            nes_cpu_addr(2); _cyc = 3; break;
        case 0x0C:
            // absolute
            nes_cpu_addr(8); _cyc = 4; break;
        case 0x07: nes_cpu_addr(2); _cyc = 5; nes_cpu_op_slo(); break;
        case 0x0F: nes_cpu_addr(8); _cyc = 6; nes_cpu_op_slo(); break;
        case 0x03: nes_cpu_addr(5); _cyc = 8; nes_cpu_op_slo(); break;
        case 0x0B:
            { // ANC - AND, then copy bit 7 into carry
            nes_cpu_addr(1); _cyc = 2;
            global.cpu_a &= nes_cpu_read(global.cpu_ea);
            global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF];
            if (global.cpu_a & 0x80) global.cpu_p |= 0x01; else global.cpu_p &= 0xFE;
            break;
        }
        case 0x02:
            show_debug_message("nes_cpu: KIL/JAM opcode 0x" + nes_to_hex(_opcode, 2) + " at PC=0x" + nes_to_hex(global.cpu_pc - 1, 4) + " - halting CPU would hang the emulator, treating as NOP");
            _cyc = 2;
            break;
        default: _cyc = nes_cpu_unimplemented(_opcode); break;
        }
        break;

    case 0x3:
        switch (_opcode) {
        case 0x35: nes_cpu_addr(3); _cyc = 4; global.cpu_a &= nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; break;
        case 0x3D: nes_cpu_addr(9); _cyc = 4 + global.cpu_page_crossed; global.cpu_a &= nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; break;
        case 0x39: nes_cpu_addr(10); _cyc = 4 + global.cpu_page_crossed; global.cpu_a &= nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; break;
        case 0x31: nes_cpu_addr(6); _cyc = 5 + global.cpu_page_crossed; global.cpu_a &= nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; break;
        case 0x30: nes_cpu_addr(7); _cyc = nes_cpu_branch((global.cpu_p & 0x80) != 0); break; // BMI
        case 0x38: global.cpu_p |= 0x01; _cyc = 2; break; // SEC
        case 0x36: nes_cpu_addr(3); _cyc = 6; nes_cpu_write(global.cpu_ea, nes_cpu_rmw_rol(nes_cpu_read(global.cpu_ea))); break;
        case 0x3E: nes_cpu_addr(9); _cyc = 7; nes_cpu_write(global.cpu_ea, nes_cpu_rmw_rol(nes_cpu_read(global.cpu_ea))); break;
        case 0x3A: _cyc = 2; break;
        case 0x34:
            // zero page,X
            nes_cpu_addr(3); _cyc = 4; break;
        case 0x3C:
            // absolute,X
            nes_cpu_addr(9); _cyc = 4 + global.cpu_page_crossed; break;
        case 0x37: nes_cpu_addr(3); _cyc = 6; nes_cpu_op_rla(); break;
        case 0x3F: nes_cpu_addr(9); _cyc = 7; nes_cpu_op_rla(); break;
        case 0x3B: nes_cpu_addr(10); _cyc = 7; nes_cpu_op_rla(); break;
        case 0x33: nes_cpu_addr(6); _cyc = 8; nes_cpu_op_rla(); break;
        case 0x32:
            show_debug_message("nes_cpu: KIL/JAM opcode 0x" + nes_to_hex(_opcode, 2) + " at PC=0x" + nes_to_hex(global.cpu_pc - 1, 4) + " - halting CPU would hang the emulator, treating as NOP");
            _cyc = 2;
            break;
        default: _cyc = nes_cpu_unimplemented(_opcode); break;
        }
        break;

    case 0x5:
        switch (_opcode) {
        case 0x50: nes_cpu_addr(7); _cyc = nes_cpu_branch((global.cpu_p & 0x40) == 0); break; // BVC
        case 0x58: global.cpu_p &= 0xFB; _cyc = 2; break; // CLI
        case 0x55: nes_cpu_addr(3); _cyc = 4; global.cpu_a ^= nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; break;
        case 0x5D: nes_cpu_addr(9); _cyc = 4 + global.cpu_page_crossed; global.cpu_a ^= nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; break;
        case 0x59: nes_cpu_addr(10); _cyc = 4 + global.cpu_page_crossed; global.cpu_a ^= nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; break;
        case 0x51: nes_cpu_addr(6); _cyc = 5 + global.cpu_page_crossed; global.cpu_a ^= nes_cpu_read(global.cpu_ea); global.cpu_p = (global.cpu_p & 0x7D) | global.cpu_zn_table[global.cpu_a & 0xFF]; break;
        case 0x56: nes_cpu_addr(3); _cyc = 6; nes_cpu_write(global.cpu_ea, nes_cpu_rmw_lsr(nes_cpu_read(global.cpu_ea))); break;
        case 0x5E: nes_cpu_addr(9); _cyc = 7; nes_cpu_write(global.cpu_ea, nes_cpu_rmw_lsr(nes_cpu_read(global.cpu_ea))); break;
        case 0x5A: _cyc = 2; break;
        case 0x54:
            // zero page,X
            nes_cpu_addr(3); _cyc = 4; break;
        case 0x5C:
            // absolute,X
            nes_cpu_addr(9); _cyc = 4 + global.cpu_page_crossed; break;
        case 0x57: nes_cpu_addr(3); _cyc = 6; nes_cpu_op_sre(); break;
        case 0x5F: nes_cpu_addr(9); _cyc = 7; nes_cpu_op_sre(); break;
        case 0x5B: nes_cpu_addr(10); _cyc = 7; nes_cpu_op_sre(); break;
        case 0x53: nes_cpu_addr(6); _cyc = 8; nes_cpu_op_sre(); break;
        case 0x52:
            show_debug_message("nes_cpu: KIL/JAM opcode 0x" + nes_to_hex(_opcode, 2) + " at PC=0x" + nes_to_hex(global.cpu_pc - 1, 4) + " - halting CPU would hang the emulator, treating as NOP");
            _cyc = 2;
            break;
        default: _cyc = nes_cpu_unimplemented(_opcode); break;
        }
        break;

    case 0x7:
        switch (_opcode) {
        case 0x75: nes_cpu_addr(3); _cyc = 4; nes_cpu_op_adc(nes_cpu_read(global.cpu_ea)); break;
        case 0x7D: nes_cpu_addr(9); _cyc = 4 + global.cpu_page_crossed; nes_cpu_op_adc(nes_cpu_read(global.cpu_ea)); break;
        case 0x79: nes_cpu_addr(10); _cyc = 4 + global.cpu_page_crossed; nes_cpu_op_adc(nes_cpu_read(global.cpu_ea)); break;
        case 0x71: nes_cpu_addr(6); _cyc = 5 + global.cpu_page_crossed; nes_cpu_op_adc(nes_cpu_read(global.cpu_ea)); break;
        case 0x70:
            nes_cpu_addr(7); _cyc = nes_cpu_branch((global.cpu_p & 0x40) != 0); break; // BVS

        // ---- BIT ----
        case 0x78: global.cpu_p |= 0x04; _cyc = 2; break; // SEI
        case 0x76: nes_cpu_addr(3); _cyc = 6; nes_cpu_write(global.cpu_ea, nes_cpu_rmw_ror(nes_cpu_read(global.cpu_ea))); break;
        case 0x7E: nes_cpu_addr(9); _cyc = 7; nes_cpu_write(global.cpu_ea, nes_cpu_rmw_ror(nes_cpu_read(global.cpu_ea))); break;
        case 0x7A: _cyc = 2; break;
        case 0x74:
            // zero page,X
            nes_cpu_addr(3); _cyc = 4; break;
        case 0x7C:
            // absolute,X
            nes_cpu_addr(9); _cyc = 4 + global.cpu_page_crossed; break;
        case 0x77: nes_cpu_addr(3); _cyc = 6; nes_cpu_op_rra(); break;
        case 0x7F: nes_cpu_addr(9); _cyc = 7; nes_cpu_op_rra(); break;
        case 0x7B: nes_cpu_addr(10); _cyc = 7; nes_cpu_op_rra(); break;
        case 0x73: nes_cpu_addr(6); _cyc = 8; nes_cpu_op_rra(); break;
        case 0x72:
            show_debug_message("nes_cpu: KIL/JAM opcode 0x" + nes_to_hex(_opcode, 2) + " at PC=0x" + nes_to_hex(global.cpu_pc - 1, 4) + " - halting CPU would hang the emulator, treating as NOP");
            _cyc = 2;
            break;
        default: _cyc = nes_cpu_unimplemented(_opcode); break;
        }
        break;

    }

    return _cyc;
}
