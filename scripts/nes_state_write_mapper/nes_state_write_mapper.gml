/// @function nes_state_write_mapper(buffer)
/// @description Appends the active mapper's own registers, so the next register write recomputes the same layout.
function nes_state_write_mapper(_b) {
    var _s = global.cart.state;

    switch (global.cart.mapper) {
        case 1:
            buffer_write(_b, buffer_u8, _s.shift);
            buffer_write(_b, buffer_u8, _s.control);
            buffer_write(_b, buffer_u8, _s.chr0);
            buffer_write(_b, buffer_u8, _s.chr1);
            buffer_write(_b, buffer_u8, _s.prg);
            break;
        case 2:
        case 7:
            buffer_write(_b, buffer_u8, _s.bank);
            break;
        case 3:
            buffer_write(_b, buffer_u8, _s.chr_bank);
            break;
        case 4:
            buffer_write(_b, buffer_u8, _s.bank_select);
            for (var _i = 0; _i < 8; _i++) buffer_write(_b, buffer_u8, _s.banks[_i]);
            buffer_write(_b, buffer_u8, _s.prg_mode);
            buffer_write(_b, buffer_u8, _s.chr_mode);
            buffer_write(_b, buffer_u8, _s.irq_latch);
            buffer_write(_b, buffer_u8, _s.irq_counter);
            buffer_write(_b, buffer_u8, _s.irq_enabled ? 1 : 0);
            buffer_write(_b, buffer_u8, _s.irq_reload ? 1 : 0);
            buffer_write(_b, buffer_u8, _s.prg_ram_protect);
            break;
    }
}
