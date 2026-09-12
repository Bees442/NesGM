/// @function nes_ppu_reg_write(reg, value)
/// @description Handles a CPU write to $2000-$2007 (reg = addr & 7).
function nes_ppu_reg_write(_reg, _value) {
    switch (_reg) {
        case 0:
            global.ppu_ctrl = _value;
            global.ppu_t = (global.ppu_t & 0xF3FF) | ((_value & 0x03) << 10);
            break;
        case 1:
            if ((_value & 0x01) != (global.ppu_mask & 0x01)) global.ppu_palette_dirty = true;
            global.ppu_mask = _value;
            break;
        case 3:
            global.ppu_oamaddr = _value;
            break;
        case 4:
            buffer_poke(global.ppu_oam, global.ppu_oamaddr, buffer_u8, _value);
            global.ppu_oamaddr = (global.ppu_oamaddr + 1) & 0xFF;
            break;
        case 5:
            if (!global.ppu_w) {
                global.ppu_t = (global.ppu_t & 0xFFE0) | (_value >> 3);
                global.ppu_x = _value & 0x07;
                global.ppu_w = true;
            } else {
                global.ppu_t = (global.ppu_t & 0x8FFF) | ((_value & 0x07) << 12);
                global.ppu_t = (global.ppu_t & 0xFC1F) | ((_value & 0xF8) << 2);
                global.ppu_w = false;
            }
            break;
        case 6:
            if (!global.ppu_w) {
                global.ppu_t = (global.ppu_t & 0x00FF) | ((_value & 0x3F) << 8);
                global.ppu_w = true;
            } else {
                global.ppu_t = (global.ppu_t & 0xFF00) | _value;
                global.ppu_v = global.ppu_t;
                global.ppu_w = false;
            }
            break;
        case 7:
            nes_ppu_vram_write(global.ppu_v & 0x3FFF, _value);
            global.ppu_v += ((global.ppu_ctrl & 0x04) ? 32 : 1);
            break;
    }
}
