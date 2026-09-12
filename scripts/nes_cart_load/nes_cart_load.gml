function nes_cart_load(_filename) {
    var _raw = buffer_load(_filename);
    if (_raw < 0) {
        show_debug_message("nes_cart_load: could not open " + _filename);
        return false;
    }

    if (buffer_get_size(_raw) < 16
        || buffer_peek(_raw, 0, buffer_u8) != ord("N")
        || buffer_peek(_raw, 1, buffer_u8) != ord("E")
        || buffer_peek(_raw, 2, buffer_u8) != ord("S")
        || buffer_peek(_raw, 3, buffer_u8) != 0x1A) {
        show_debug_message("nes_cart_load: not an iNES file: " + _filename);
        buffer_delete(_raw);
        return false;
    }

    var _prg_16k_count = buffer_peek(_raw, 4, buffer_u8);
    var _chr_8k_count  = buffer_peek(_raw, 5, buffer_u8);
    var _flags6        = buffer_peek(_raw, 6, buffer_u8);
    var _flags7        = buffer_peek(_raw, 7, buffer_u8);

    var _mapper       = (_flags7 & 0xF0) | (_flags6 >> 4);
    var _four_screen  = (_flags6 & 0x08) != 0;
    var _battery      = (_flags6 & 0x02) != 0;
    var _has_trainer  = (_flags6 & 0x04) != 0;
    var _mirror_mode  = (_flags6 & 0x01) ? NES_MIRROR_VERTICAL : NES_MIRROR_HORIZONTAL;

    nes_region_detect(_raw, _filename);

    var _offset = 16 + (_has_trainer ? 512 : 0);

    var _prg_size = _prg_16k_count * 16384;
    if (_prg_size <= 0) _prg_size = 16384;

    var _prg = buffer_create(_prg_size, buffer_fixed, 1);
    buffer_copy(_raw, _offset, _prg_size, _prg, 0);
    _offset += _prg_size;

    var _chr_is_ram = (_chr_8k_count == 0);
    var _chr_size = _chr_is_ram ? 8192 : (_chr_8k_count * 8192);
    var _chr = buffer_create(_chr_size, buffer_fixed, 1);
    if (!_chr_is_ram) {
        buffer_copy(_raw, _offset, _chr_size, _chr, 0);
    }

    buffer_delete(_raw);

    global.cart = {
        mapper: _mapper,
        mirror_mode: _mirror_mode,
        four_screen: _four_screen,
        battery: _battery,
        filename: _filename,
        prg: _prg,
        prg_size: _prg_size,
        prg_banks_8k: _prg_size div 8192,
        chr: _chr,
        chr_size: _chr_size,
        chr_is_ram: _chr_is_ram,
        chr_banks_1k: _chr_size div 1024,
        prg_ram: buffer_create(8192, buffer_fixed, 1),
        state: {},
    };

    global.prg_buf = _prg;
    global.chr_buf = _chr;
    global.prg_ram_buf = global.cart.prg_ram;
    global.mirror_mode = _mirror_mode;

    global.prg_map = array_create(4, 0);
    global.chr_map = array_create(8, 0);
    global.cpu_irq_line = false;
    global.sram_dirty = false;
    global.sram_autosave_timer = 180;

    if (!nes_mapper_init()) {
        show_debug_message("nes_cart_load: mapper " + string(_mapper) + " is not implemented");
        return false;
    }

    nes_cart_load_sram();
    return true;
}
