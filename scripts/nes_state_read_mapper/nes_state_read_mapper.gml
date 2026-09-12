/// @function nes_state_read_mapper(buffer)
/// @description Restores the active mapper's registers (counterpart to nes_state_write_mapper).
function nes_state_read_mapper(_b) {
    var _s = global.cart.state;

    switch (global.cart.mapper) {
        case 1:
            _s.shift   = buffer_read(_b, buffer_u8);
            _s.control = buffer_read(_b, buffer_u8);
            _s.chr0    = buffer_read(_b, buffer_u8);
            _s.chr1    = buffer_read(_b, buffer_u8);
            _s.prg     = buffer_read(_b, buffer_u8);
            break;
        case 2:
        case 7:
            _s.bank = buffer_read(_b, buffer_u8);
            break;
        case 3:
            _s.chr_bank = buffer_read(_b, buffer_u8);
            break;
        case 4:
            _s.bank_select = buffer_read(_b, buffer_u8);
            for (var _i = 0; _i < 8; _i++) _s.banks[_i] = buffer_read(_b, buffer_u8);
            _s.prg_mode        = buffer_read(_b, buffer_u8);
            _s.chr_mode        = buffer_read(_b, buffer_u8);
            _s.irq_latch       = buffer_read(_b, buffer_u8);
            _s.irq_counter     = buffer_read(_b, buffer_u8);
            _s.irq_enabled     = buffer_read(_b, buffer_u8) != 0;
            _s.irq_reload      = buffer_read(_b, buffer_u8) != 0;
            _s.prg_ram_protect = buffer_read(_b, buffer_u8);
            break;
    }
}
