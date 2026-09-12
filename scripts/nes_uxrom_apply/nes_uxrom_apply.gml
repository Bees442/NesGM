/// @function nes_uxrom_apply()
function nes_uxrom_apply() {
    nes_prg_set_16k(0, global.cart.state.bank);
    nes_prg_set_16k(1, (global.cart.prg_banks_8k div 2) - 1);
}
