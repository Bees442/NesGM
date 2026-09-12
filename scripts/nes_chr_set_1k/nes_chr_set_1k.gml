/// @function nes_chr_set_1k(slot, bank)
/// @description Points one 1KB PPU CHR window at a 1KB CHR bank.
function nes_chr_set_1k(_slot, _bank) {
    var _n = global.cart.chr_banks_1k;
    if (_n <= 0) return;
    var _wrapped = ((_bank mod _n) + _n) mod _n;
    global.chr_map[_slot] = _wrapped * 1024;
}
