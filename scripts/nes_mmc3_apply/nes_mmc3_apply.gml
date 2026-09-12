/// @function nes_mmc3_apply()
/// @description Recomputes the PRG/CHR bank tables from MMC3's eight bank registers.
function nes_mmc3_apply() {
    var _c = global.cart;
    var _s = _c.state;
    var _b = _s.banks;
    var _last8 = _c.prg_banks_8k - 1;

    if (_s.prg_mode == 0) {
        nes_prg_set_8k(0, _b[6]);
        nes_prg_set_8k(1, _b[7]);
        nes_prg_set_8k(2, _last8 - 1);
    } else {
        nes_prg_set_8k(0, _last8 - 1);
        nes_prg_set_8k(1, _b[7]);
        nes_prg_set_8k(2, _b[6]);
    }
    nes_prg_set_8k(3, _last8);

    var _r0 = _b[0] & 0xFE;
    var _r1 = _b[1] & 0xFE;

    if (_s.chr_mode == 0) {
        nes_chr_set_1k(0, _r0);
        nes_chr_set_1k(1, _r0 + 1);
        nes_chr_set_1k(2, _r1);
        nes_chr_set_1k(3, _r1 + 1);
        nes_chr_set_1k(4, _b[2]);
        nes_chr_set_1k(5, _b[3]);
        nes_chr_set_1k(6, _b[4]);
        nes_chr_set_1k(7, _b[5]);
    } else {
        nes_chr_set_1k(0, _b[2]);
        nes_chr_set_1k(1, _b[3]);
        nes_chr_set_1k(2, _b[4]);
        nes_chr_set_1k(3, _b[5]);
        nes_chr_set_1k(4, _r0);
        nes_chr_set_1k(5, _r0 + 1);
        nes_chr_set_1k(6, _r1);
        nes_chr_set_1k(7, _r1 + 1);
    }
}
