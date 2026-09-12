// Addressing modes are numbered so that the two-byte ones are exactly those >= 8, which turns
// "does this mode take a second operand byte" into a single comparison.
//   1=IMM 2=ZP 3=ZPX 4=ZPY 5=INDX 6=INDY 7=REL 8=ABS 9=ABSX 10=ABSY 11=IND(JMP only)
//
// The operand bytes normally arrive prefetched: nes_cpu_run_frame reads the opcode and the
// three bytes after it as one buffer_u32 (global.cpu_opw), so the common path here does no
// buffer access at all. global.cpu_opw is -1 when that was not possible - code running outside
// PRG-ROM, or an instruction straddling the end of an 8KB bank - and then the bytes are read
// individually as before.

/// @function nes_cpu_addr(mode)
/// @description Fetches the operand for `mode`, advancing PC past it; sets global.cpu_ea and global.cpu_page_crossed.
function nes_cpu_addr(_mode) {
    var _pc = global.cpu_pc;

    var _o0, _o1;
    var _w = global.cpu_opw;
    if (_w >= 0) {
        _o0 = (_w >> 8) & 0xFF;
        _o1 = (_w >> 16) & 0xFF;
    } else if (_mode == 1) {
        _o0 = 0;
        _o1 = 0;
    } else {
        _o0 = nes_cpu_read(_pc);
        _o1 = (_mode >= 8) ? nes_cpu_read(_pc + 1) : 0;
    }

    // Cases are ordered by how often they actually run, because the VM scans them linearly.
    switch (_mode) {
        case 2:
            global.cpu_ea = _o0;
            global.cpu_pc = _pc + 1;
            global.cpu_page_crossed = 0;
            break;
        case 1:
            global.cpu_ea = _pc;
            global.cpu_pc = _pc + 1;
            global.cpu_page_crossed = 0;
            break;
        case 7: {
            var _off = (_o0 & 0x80) ? (_o0 - 0x100) : _o0;
            var _next = _pc + 1;
            global.cpu_pc = _next;
            global.cpu_ea = (_next + _off) & 0xFFFF;
            global.cpu_page_crossed = 0;
            break;
        }
        case 8:
            global.cpu_ea = _o0 | (_o1 << 8);
            global.cpu_pc = _pc + 2;
            global.cpu_page_crossed = 0;
            break;
        case 9: {
            var _base9 = _o0 | (_o1 << 8);
            var _eff9 = (_base9 + global.cpu_x) & 0xFFFF;
            global.cpu_ea = _eff9;
            global.cpu_pc = _pc + 2;
            global.cpu_page_crossed = ((_base9 & 0xFF00) != (_eff9 & 0xFF00)) ? 1 : 0;
            break;
        }
        case 6: {
            var _ram6 = global.ram;
            var _base6 = buffer_peek(_ram6, _o0, buffer_u8) | (buffer_peek(_ram6, (_o0 + 1) & 0xFF, buffer_u8) << 8);
            var _eff6 = (_base6 + global.cpu_y) & 0xFFFF;
            global.cpu_ea = _eff6;
            global.cpu_pc = _pc + 1;
            global.cpu_page_crossed = ((_base6 & 0xFF00) != (_eff6 & 0xFF00)) ? 1 : 0;
            break;
        }
        case 3:
            global.cpu_ea = (_o0 + global.cpu_x) & 0xFF;
            global.cpu_pc = _pc + 1;
            global.cpu_page_crossed = 0;
            break;
        case 10: {
            var _base10 = _o0 | (_o1 << 8);
            var _eff10 = (_base10 + global.cpu_y) & 0xFFFF;
            global.cpu_ea = _eff10;
            global.cpu_pc = _pc + 2;
            global.cpu_page_crossed = ((_base10 & 0xFF00) != (_eff10 & 0xFF00)) ? 1 : 0;
            break;
        }
        case 5: {
            var _ram5 = global.ram;
            var _zp = (_o0 + global.cpu_x) & 0xFF;
            global.cpu_ea = buffer_peek(_ram5, _zp, buffer_u8) | (buffer_peek(_ram5, (_zp + 1) & 0xFF, buffer_u8) << 8);
            global.cpu_pc = _pc + 1;
            global.cpu_page_crossed = 0;
            break;
        }
        case 4:
            global.cpu_ea = (_o0 + global.cpu_y) & 0xFF;
            global.cpu_pc = _pc + 1;
            global.cpu_page_crossed = 0;
            break;
        case 11: {
            var _ptr = _o0 | (_o1 << 8);
            var _ptr_hi = (_ptr & 0xFF00) | ((_ptr + 1) & 0x00FF);
            global.cpu_ea = nes_cpu_read(_ptr) | (nes_cpu_read(_ptr_hi) << 8);
            global.cpu_pc = _pc + 2;
            global.cpu_page_crossed = 0;
            break;
        }
    }
}
