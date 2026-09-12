/// @function nes_prg_set_8k(slot, bank)
/// @description Points one 8KB CPU PRG window ($8000/$A000/$C000/$E000) at a PRG bank.
function nes_prg_set_8k(_slot, _bank) {
    var _n = global.cart.prg_banks_8k;
    if (_n <= 0) return;
    var _wrapped = ((_bank mod _n) + _n) mod _n;
    global.prg_map[_slot] = _wrapped * 8192;
}
