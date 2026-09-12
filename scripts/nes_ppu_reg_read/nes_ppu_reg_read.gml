/// @function nes_ppu_reg_read(reg)
/// @description Handles a CPU read from $2000-$2007 (reg = addr & 7).
function nes_ppu_reg_read(_reg) {
    switch (_reg) {
        case 2:
            var _r = global.ppu_status;
            global.ppu_status &= 0x7F;
            global.ppu_w = false;
            return _r;
        case 4:
            return buffer_peek(global.ppu_oam, global.ppu_oamaddr, buffer_u8);
        case 7:
            var _addr = global.ppu_v & 0x3FFF;
            var _value;
            if (_addr >= 0x3F00) {
                _value = nes_ppu_vram_read(_addr);
                global.ppu_data_buffer = _value;
            } else {
                _value = global.ppu_data_buffer;
                global.ppu_data_buffer = nes_ppu_vram_read(_addr);
            }
            global.ppu_v += ((global.ppu_ctrl & 0x04) ? 32 : 1);
            return _value;
        default:
            return 0;
    }
}
