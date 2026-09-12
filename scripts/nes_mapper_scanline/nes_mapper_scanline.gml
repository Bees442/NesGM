/// @function nes_mapper_scanline()
/// @description Clocks the MMC3 scanline counter - called by the PPU once per rendered
/// scanline, just before that line is drawn (a stand-in for the real A12-rising-edge trigger,
/// which is accurate enough for the raster splits games actually use it for). Raises the CPU
/// IRQ line when it hits zero.
function nes_mapper_scanline() {
    if (global.cart.mapper != 4) return;

    var _s = global.cart.state;
    if (_s.irq_counter == 0 || _s.irq_reload) {
        _s.irq_counter = _s.irq_latch;
        _s.irq_reload = false;
    } else {
        _s.irq_counter -= 1;
    }

    if (_s.irq_counter == 0 && _s.irq_enabled) {
        global.cpu_irq_line = true;
    }
}
