/// @function nes_prg_set_32k(bank32)
/// @description Points the whole $8000-$FFFF range at one 32KB bank.
function nes_prg_set_32k(_bank32) {
    for (var _i = 0; _i < 4; _i++) nes_prg_set_8k(_i, _bank32 * 4 + _i);
}
