/// @function nes_mapper_write(addr, value)
/// @description Dispatches a write in $8000-$FFFF to the active mapper's register logic.
function nes_mapper_write(_addr, _value) {
    switch (global.cart.mapper) {
        case 1: nes_mmc1_write(_addr, _value); break;
        case 2: global.cart.state.bank = _value & 0x0F; nes_uxrom_apply(); break;
        case 3: global.cart.state.chr_bank = _value & 0x03; nes_chr_set_8k(global.cart.state.chr_bank); break;
        case 4: nes_mmc3_write(_addr, _value); break;
        case 7: global.cart.state.bank = _value & 0x07;
                global.cart.mirror_mode = (_value & 0x10) ? NES_MIRROR_SINGLE_HIGH : NES_MIRROR_SINGLE_LOW;
                global.mirror_mode = global.cart.mirror_mode;
                nes_axrom_apply(); break;
    }
}
