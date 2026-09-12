/// @function nes_cart_sram_path()
/// @description The .sav path matching the loaded ROM. Saves live next to the ROM file.
function nes_cart_sram_path() {
    return filename_change_ext(global.cart.filename, ".sav");
}
