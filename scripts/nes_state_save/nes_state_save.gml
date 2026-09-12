// nes_state: save states - a snapshot of the entire machine (CPU registers, RAM, PPU state
// and VRAM, cartridge banking and PRG-RAM) written to a single file, restorable at any time.
//
// Unlike the battery-backed .sav files in nes_cart (which only hold the cartridge's save RAM
// and only work for games that have a battery), a save state captures the exact machine state
// mid-frame, so it works for every game and restores to the precise instant it was taken.
//
// States live next to the ROM as <rom>.st0 .. <rom>.st9. The format is versioned; loading a
// state written by an older/newer build is refused rather than restoring garbage.

/// @function nes_state_save(slot)
/// @description Writes the full machine state to the given slot. Returns true on success.
function nes_state_save(_slot) {
    var _b = buffer_create(65536, buffer_grow, 1);

    buffer_write(_b, buffer_u32, NES_STATE_MAGIC);
    buffer_write(_b, buffer_u32, NES_STATE_VERSION);
    buffer_write(_b, buffer_u8, global.cart.mapper);

    // ---- CPU ----
    buffer_write(_b, buffer_u16, global.cpu_pc);
    buffer_write(_b, buffer_u8,  global.cpu_a);
    buffer_write(_b, buffer_u8,  global.cpu_x);
    buffer_write(_b, buffer_u8,  global.cpu_y);
    buffer_write(_b, buffer_u8,  global.cpu_sp);
    buffer_write(_b, buffer_u8,  global.cpu_p);
    buffer_write(_b, buffer_u8,  global.cpu_irq_line ? 1 : 0);

    // ---- internal RAM ----
    buffer_copy(global.ram, 0, 2048, _b, buffer_tell(_b));
    buffer_seek(_b, buffer_seek_relative, 2048);

    // ---- PPU registers / timing ----
    buffer_write(_b, buffer_u8,  global.ppu_ctrl);
    buffer_write(_b, buffer_u8,  global.ppu_mask);
    buffer_write(_b, buffer_u8,  global.ppu_status);
    buffer_write(_b, buffer_u8,  global.ppu_oamaddr);
    buffer_write(_b, buffer_u16, global.ppu_v);
    buffer_write(_b, buffer_u16, global.ppu_t);
    buffer_write(_b, buffer_u8,  global.ppu_x);
    buffer_write(_b, buffer_u8,  global.ppu_w ? 1 : 0);
    buffer_write(_b, buffer_u8,  global.ppu_data_buffer);
    buffer_write(_b, buffer_u16, global.ppu_scanline);
    buffer_write(_b, buffer_u16, global.ppu_dot);
    buffer_write(_b, buffer_u8,  global.ppu_frame_odd ? 1 : 0);
    buffer_write(_b, buffer_u8,  global.ppu_nmi_line ? 1 : 0);

    // ---- PPU memory ----
    buffer_copy(global.ppu_oam, 0, 256, _b, buffer_tell(_b));
    buffer_seek(_b, buffer_seek_relative, 256);
    buffer_copy(global.ppu_nametable, 0, 2048, _b, buffer_tell(_b));
    buffer_seek(_b, buffer_seek_relative, 2048);
    buffer_copy(global.ppu_palette, 0, 32, _b, buffer_tell(_b));
    buffer_seek(_b, buffer_seek_relative, 32);

    // ---- cartridge: PRG-RAM, live bank tables, mirroring ----
    buffer_copy(global.cart.prg_ram, 0, 8192, _b, buffer_tell(_b));
    buffer_seek(_b, buffer_seek_relative, 8192);

    buffer_write(_b, buffer_u8, global.cart.mirror_mode);
    for (var _i = 0; _i < 4; _i++) buffer_write(_b, buffer_u32, global.prg_map[_i]);
    for (var _i = 0; _i < 8; _i++) buffer_write(_b, buffer_u32, global.chr_map[_i]);

    // CHR-RAM carts keep their tile data in the CHR buffer, so it has to travel with the state
    // (CHR-ROM doesn't - it's reloaded from the .nes file).
    buffer_write(_b, buffer_u8, global.cart.chr_is_ram ? 1 : 0);
    if (global.cart.chr_is_ram) {
        buffer_write(_b, buffer_u32, global.cart.chr_size);
        buffer_copy(global.cart.chr, 0, global.cart.chr_size, _b, buffer_tell(_b));
        buffer_seek(_b, buffer_seek_relative, global.cart.chr_size);
    }

    nes_state_write_mapper(_b);

    var _path = nes_state_path(_slot);
    buffer_resize(_b, buffer_tell(_b));
    buffer_save(_b, _path);
    buffer_delete(_b);

    show_debug_message("nes_state: saved slot " + string(_slot) + " -> " + _path);
    return true;
}
