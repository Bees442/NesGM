/// @function nes_prg_set_16k(slot16, bank16)
/// @description Points a 16KB CPU PRG window (slot16: 0 = $8000, 1 = $C000) at a 16KB bank.
function nes_prg_set_16k(_slot16, _bank16) {
    nes_prg_set_8k(_slot16 * 2,     _bank16 * 2);
    nes_prg_set_8k(_slot16 * 2 + 1, _bank16 * 2 + 1);
}
