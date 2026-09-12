/// @function nes_state_load(slot)
/// @description Restores machine state from the given slot. Returns true on success, false if
/// the slot is empty, corrupt, from another build, or belongs to a different mapper.
function nes_state_load(_slot) {
    var _path = nes_state_path(_slot);
    if (!file_exists(_path)) {
        show_debug_message("nes_state: slot " + string(_slot) + " is empty");
        return false;
    }

    var _b = buffer_load(_path);
    if (_b < 0) return false;

    if (buffer_read(_b, buffer_u32) != NES_STATE_MAGIC
        || buffer_read(_b, buffer_u32) != NES_STATE_VERSION
        || buffer_read(_b, buffer_u8) != global.cart.mapper) {
        show_debug_message("nes_state: slot " + string(_slot) + " does not match this ROM/build, ignoring");
        buffer_delete(_b);
        return false;
    }

    // ---- CPU ----
    global.cpu_pc = buffer_read(_b, buffer_u16);
    global.cpu_a  = buffer_read(_b, buffer_u8);
    global.cpu_x  = buffer_read(_b, buffer_u8);
    global.cpu_y  = buffer_read(_b, buffer_u8);
    global.cpu_sp = buffer_read(_b, buffer_u8);
    global.cpu_p  = buffer_read(_b, buffer_u8);
    global.cpu_irq_line = buffer_read(_b, buffer_u8) != 0;

    // ---- internal RAM ----
    buffer_copy(_b, buffer_tell(_b), 2048, global.ram, 0);
    buffer_seek(_b, buffer_seek_relative, 2048);

    // ---- PPU registers / timing ----
    global.ppu_ctrl    = buffer_read(_b, buffer_u8);
    global.ppu_mask    = buffer_read(_b, buffer_u8);
    global.ppu_status  = buffer_read(_b, buffer_u8);
    global.ppu_oamaddr = buffer_read(_b, buffer_u8);
    global.ppu_v       = buffer_read(_b, buffer_u16);
    global.ppu_t       = buffer_read(_b, buffer_u16);
    global.ppu_x       = buffer_read(_b, buffer_u8);
    global.ppu_w       = buffer_read(_b, buffer_u8) != 0;
    global.ppu_data_buffer = buffer_read(_b, buffer_u8);
    global.ppu_scanline    = buffer_read(_b, buffer_u16);
    global.ppu_dot         = buffer_read(_b, buffer_u16);
    global.ppu_frame_odd   = buffer_read(_b, buffer_u8) != 0;
    global.ppu_nmi_line    = buffer_read(_b, buffer_u8) != 0;

    // ---- PPU memory ----
    buffer_copy(_b, buffer_tell(_b), 256, global.ppu_oam, 0);
    buffer_seek(_b, buffer_seek_relative, 256);
    buffer_copy(_b, buffer_tell(_b), 2048, global.ppu_nametable, 0);
    buffer_seek(_b, buffer_seek_relative, 2048);
    buffer_copy(_b, buffer_tell(_b), 32, global.ppu_palette, 0);
    buffer_seek(_b, buffer_seek_relative, 32);
    global.ppu_palette_dirty = true; // palette RAM was replaced behind the renderer's back

    // ---- cartridge ----
    buffer_copy(_b, buffer_tell(_b), 8192, global.cart.prg_ram, 0);
    buffer_seek(_b, buffer_seek_relative, 8192);
    global.sram_dirty = true; // the restored save RAM differs from what's on disk

    global.cart.mirror_mode = buffer_read(_b, buffer_u8);
    global.mirror_mode = global.cart.mirror_mode;
    for (var _i = 0; _i < 4; _i++) global.prg_map[_i] = buffer_read(_b, buffer_u32);
    for (var _i = 0; _i < 8; _i++) global.chr_map[_i] = buffer_read(_b, buffer_u32);

    if (buffer_read(_b, buffer_u8) != 0) {
        var _chr_size = buffer_read(_b, buffer_u32);
        var _copy = min(_chr_size, global.cart.chr_size);
        buffer_copy(_b, buffer_tell(_b), _copy, global.cart.chr, 0);
        buffer_seek(_b, buffer_seek_relative, _chr_size);
    }

    nes_state_read_mapper(_b);

    buffer_delete(_b);
    show_debug_message("nes_state: loaded slot " + string(_slot));
    return true;
}
