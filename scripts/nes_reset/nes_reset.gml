/// @function nes_reset()
/// @description Reboots the console with the cartridge still in it - RAM, PPU, APU and CPU restart, the ROM stays put.
function nes_reset() {
    if (!variable_global_exists("cart") || is_undefined(global.cart)) return;

    nes_cart_save_sram();

    nes_bus_init();
    nes_ppu_init();
    nes_apu_init();
    nes_gpu_init();
    nes_cpu_reset();
}
