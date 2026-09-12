/// @function nes_gpu_draw_sprites(band, priority)
/// @description Emits the quads for every sprite starting inside `band`, filtered to priority (0 = front, 1 = behind).
function nes_gpu_draw_sprites(_band, _priority) {
    var _oam = global.gpu_oam;
    var _height = _band.spr_h;
    var _halves = _height div 8;
    var _left_clip = _band.spr_left ? 0 : 8;

    draw_primitive_begin_texture(pr_trianglelist, surface_get_texture(global.gpu_chr_surf));

    for (var _i = 0; _i < 64; _i++) {
        var _attr = buffer_peek(_oam, _i * 4 + 2, buffer_u8);
        if (((_attr >> 5) & 1) != _priority) continue;

        var _top = buffer_peek(_oam, _i * 4 + 0, buffer_u8) + 1;
        if (_top >= 240 || _top + _height <= _band.y0 || _top >= _band.y1) continue;

        var _sx = buffer_peek(_oam, _i * 4 + 3, buffer_u8);
        if (_sx + 8 <= _left_clip) continue;

        var _tile = buffer_peek(_oam, _i * 4 + 1, buffer_u8);
        var _flip_h = (_attr & 0x40) != 0;
        var _flip_v = (_attr & 0x80) != 0;
        var _colour = make_colour_rgb(_attr & 0x03, 0, 0);

        var _base0, _base1;
        if (_height == 16) {
            var _pt = (_tile & 1) ? 0x1000 : 0x0000;
            var _idx = _tile & 0xFE;
            _base0 = _pt + _idx * 16;
            _base1 = _pt + (_idx + 1) * 16;
        } else {
            _base0 = _band.spr_pt + _tile * 16;
            _base1 = _base0;
        }

        var _u0 = _flip_h ? 8 : 0;
        var _u1 = _flip_h ? 0 : 8;

        for (var _h = 0; _h < _halves; _h++) {
            var _y0 = _top + _h * 8;
            var _y1 = _y0 + 8;
            if (_y1 <= 0 || _y0 >= 240) continue;

            var _src = _flip_v ? (_halves - 1 - _h) : _h;
            var _base = (_src == 0) ? _base0 : _base1;
            var _v0 = _base + (_flip_v ? 8 : 0);
            var _v1 = _base + (_flip_v ? 0 : 8);

            var _x0 = max(_sx, _left_clip);
            var _x1 = _sx + 8;
            var _cu0 = _u0 + (_u1 - _u0) * ((_x0 - _sx) / 8);

            draw_vertex_texture_colour(_x0, _y0, _cu0, _v0, _colour, 1);
            draw_vertex_texture_colour(_x1, _y0, _u1,  _v0, _colour, 1);
            draw_vertex_texture_colour(_x0, _y1, _cu0, _v1, _colour, 1);

            draw_vertex_texture_colour(_x1, _y0, _u1,  _v0, _colour, 1);
            draw_vertex_texture_colour(_x1, _y1, _u1,  _v1, _colour, 1);
            draw_vertex_texture_colour(_x0, _y1, _cu0, _v1, _colour, 1);
        }
    }

    draw_primitive_end();
}
