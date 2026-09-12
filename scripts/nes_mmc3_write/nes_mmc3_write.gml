/// @function nes_mmc3_write(addr, value)
function nes_mmc3_write(_addr, _value) {
    var _s = global.cart.state;
    var _even = (_addr & 1) == 0;

    if (_addr <= 0x9FFF) {
        if (_even) { // $8000 - bank select
            _s.bank_select = _value & 0x07;
            _s.prg_mode = (_value >> 6) & 1;
            _s.chr_mode = (_value >> 7) & 1;
        } else {     // $8001 - bank data
            _s.banks[_s.bank_select] = _value;
        }
        nes_mmc3_apply();
    } else if (_addr <= 0xBFFF) {
        if (_even) { // $A000 - mirroring
            global.cart.mirror_mode = (_value & 1) ? NES_MIRROR_HORIZONTAL : NES_MIRROR_VERTICAL;
            global.mirror_mode = global.cart.mirror_mode;
        } else {     // $A001 - PRG-RAM protect
            _s.prg_ram_protect = _value;
        }
    } else if (_addr <= 0xDFFF) {
        if (_even) { // $C000 - IRQ latch
            _s.irq_latch = _value;
        } else {     // $C001 - IRQ reload
            _s.irq_counter = 0;
            _s.irq_reload = true;
        }
    } else {
        if (_even) { // $E000 - IRQ disable + acknowledge
            _s.irq_enabled = false;
            global.cpu_irq_line = false;
        } else {     // $E001 - IRQ enable
            _s.irq_enabled = true;
        }
    }
}
