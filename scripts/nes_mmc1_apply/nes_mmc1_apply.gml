/// @function nes_mmc1_apply()
/// @description Recomputes mirroring and the PRG/CHR bank tables from MMC1's registers.
function nes_mmc1_apply() {
    var _c = global.cart;
    var _s = _c.state;

    switch (_s.control & 0x03) {
        case 0: _c.mirror_mode = NES_MIRROR_SINGLE_LOW; break;
        case 1: _c.mirror_mode = NES_MIRROR_SINGLE_HIGH; break;
        case 2: _c.mirror_mode = NES_MIRROR_VERTICAL; break;
        case 3: _c.mirror_mode = NES_MIRROR_HORIZONTAL; break;
    }
    global.mirror_mode = _c.mirror_mode;

    var _prg_mode = (_s.control >> 2) & 0x03;
    var _bank = _s.prg & 0x0F;
    var _last16 = (_c.prg_banks_8k div 2) - 1;

    switch (_prg_mode) {
        case 0: case 1:
            nes_prg_set_16k(0, _bank & 0xFE);
            nes_prg_set_16k(1, (_bank & 0xFE) | 1);
            break;
        case 2:
            nes_prg_set_16k(0, 0);
            nes_prg_set_16k(1, _bank);
            break;
        case 3:
            nes_prg_set_16k(0, _bank);
            nes_prg_set_16k(1, _last16);
            break;
    }

    if (_s.control & 0x10) {
        nes_chr_set_4k(0, _s.chr0);
        nes_chr_set_4k(1, _s.chr1);
    } else {
        nes_chr_set_8k(_s.chr0 >> 1);
    }
}
