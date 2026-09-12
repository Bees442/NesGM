/// @function nes_prg_set_32k_from_16k(low16, high16)
/// @description Convenience for the common "low 16KB bank + high 16KB bank" layout.
function nes_prg_set_32k_from_16k(_low16, _high16) {
    nes_prg_set_16k(0, _low16);
    nes_prg_set_16k(1, _high16);
}
