/// @function nes_mapper_init()
/// @description Sets up per-mapper state and the initial bank layout. Returns false for an unsupported mapper.
function nes_mapper_init() {
    var _c = global.cart;

    nes_prg_set_32k_from_16k(0, (_c.prg_banks_8k div 2) - 1);
    nes_chr_set_8k(0);

    switch (_c.mapper) {
        case 0:
            return true;

        case 1:
            _c.state = {
                shift: 0x10,
                control: 0x0C,
                chr0: 0, chr1: 0, prg: 0,
                last_write_cycle: -10,
            };
            nes_mmc1_apply();
            return true;

        case 2:
            _c.state = { bank: 0 };
            nes_uxrom_apply();
            return true;

        case 3:
            _c.state = { chr_bank: 0 };
            return true;

        case 4:
            _c.state = {
                bank_select: 0,
                banks: array_create(8, 0),
                prg_mode: 0,
                chr_mode: 0,
                irq_latch: 0,
                irq_counter: 0,
                irq_enabled: false,
                irq_reload: false,
                prg_ram_protect: 0,
            };
            nes_mmc3_apply();
            return true;

        case 7:
            _c.state = { bank: 0 };
            _c.mirror_mode = NES_MIRROR_SINGLE_LOW;
            global.mirror_mode = _c.mirror_mode;
            nes_axrom_apply();
            return true;
    }

    return false;
}
