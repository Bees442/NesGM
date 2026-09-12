/// @function nes_ppu_sprite0_check(scanline)
/// @description Sets the sprite 0 hit flag for one scanline without drawing anything (for the GPU renderer).
function nes_ppu_sprite0_check(_sl) {
    var _mask = global.ppu_mask;
    if ((_mask & 0x18) != 0x18) return;
    if (global.ppu_status & 0x40) return;

    var _oam = global.ppu_oam;
    var _height = (global.ppu_ctrl & 0x20) ? 16 : 8;
    var _top = buffer_peek(_oam, 0, buffer_u8) + 1;
    if (_sl < _top || _sl >= _top + _height) return;

    var _tile = buffer_peek(_oam, 1, buffer_u8);
    var _attr = buffer_peek(_oam, 2, buffer_u8);
    var _sx   = buffer_peek(_oam, 3, buffer_u8);
    if (_sx > 254) return;

    var _row = _sl - _top;
    if (_attr & 0x80) _row = _height - 1 - _row;

    var _addr;
    if (_height == 16) {
        var _idx = _tile & 0xFE;
        if (_row >= 8) { _idx += 1; _row -= 8; }
        _addr = ((_tile & 1) ? 0x1000 : 0x0000) + _idx * 16 + _row;
    } else {
        _addr = ((global.ppu_ctrl & 0x08) ? 0x1000 : 0x0000) + _tile * 16 + _row;
    }

    var _chr = global.chr_buf;
    var _map = global.chr_map;
    var _a2 = _addr + 8;
    var _lo = buffer_peek(_chr, _map[(_addr >> 10) & 7] | (_addr & 0x3FF), buffer_u8);
    var _hi = buffer_peek(_chr, _map[(_a2 >> 10) & 7] | (_a2 & 0x3FF), buffer_u8);
    if (_lo == 0 && _hi == 0) return;

    var _decode = global.ppu_decode;
    var _sprite_bits = _decode[(_hi << 8) | _lo];
    var _flip_h = (_attr & 0x40) != 0;

    var _v = global.ppu_v;
    var _coarse_y = (_v >> 5) & 0x1F;
    var _fine_y = (_v >> 12) & 0x7;
    var _nt_y = (_v >> 11) & 1;
    var _bg_pt = (global.ppu_ctrl & 0x10) ? 0x1000 : 0x0000;
    var _nt = global.ppu_nametable;
    var _fx = global.ppu_x;
    var _bg_left = (_mask & 0x02) != 0;
    var _spr_left = (_mask & 0x04) != 0;

    var _cached_tile = -1;
    var _cached_bits = 0;

    for (var _p = 0; _p < 8; _p++) {
        var _x = _sx + _p;
        if (_x > 254) break;
        if (_x < 8 && (!_bg_left || !_spr_left)) continue;

        var _sv = (_sprite_bits >> ((_flip_h ? (7 - _p) : _p) * 2)) & 3;
        if (_sv == 0) continue;

        var _xx = _x + _fx;
        var _cx = ((_v & 0x1F) + (_xx >> 3));
        var _ntx = (_v >> 10) & 1;
        if (_cx > 31) { _cx -= 32; _ntx = 1 - _ntx; }

        var _bank = nes_ppu_nt_bank((_nt_y << 1) | _ntx) << 10;
        var _tile_key = _bank | (_coarse_y << 5) | _cx;
        if (_tile_key != _cached_tile) {
            var _ti = buffer_peek(_nt, _tile_key, buffer_u8);
            var _ta = _bg_pt + _ti * 16 + _fine_y;
            var _tb = _ta + 8;
            var _blo = buffer_peek(_chr, _map[(_ta >> 10) & 7] | (_ta & 0x3FF), buffer_u8);
            var _bhi = buffer_peek(_chr, _map[(_tb >> 10) & 7] | (_tb & 0x3FF), buffer_u8);
            _cached_bits = _decode[(_bhi << 8) | _blo];
            _cached_tile = _tile_key;
        }

        if (((_cached_bits >> ((_xx & 7) * 2)) & 3) != 0) {
            global.ppu_status |= 0x40;
            return;
        }
    }
}
