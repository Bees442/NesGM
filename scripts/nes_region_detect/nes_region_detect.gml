/// @function nes_region_detect(header_buffer, filename)
/// @description Works out whether a ROM is NTSC or PAL and installs the timing that follows. Returns true for PAL.
function nes_region_detect(_hdr, _filename) {
    var _flags7 = buffer_peek(_hdr, 7, buffer_u8);
    var _is_ines2 = ((_flags7 >> 2) & 0x03) == 2;
    var _pal = false;
    var _why = "";

    if (_is_ines2) {
        var _tv = buffer_peek(_hdr, 12, buffer_u8) & 0x03;
        _pal = (_tv == 1);
        _why = "iNES 2.0 header";
    } else if (buffer_peek(_hdr, 9, buffer_u8) & 0x01) {
        _pal = true;
        _why = "iNES 1.0 header flag";
    } else {
        var _n = string_upper(filename_name(_filename));
        var _tags = ["(E)", "(EUROPE)", "(PAL)", "(EUR", "(F)", "(FRANCE)", "(G)", "(GERMANY)",
                     "(I)", "(ITALY)", "(S)", "(SPAIN)", "(SW)", "(AU)", "(AUSTRALIA)", "(NL)",
                     "(AUS)", "(AUSTRIA)", "(AUE)"];
        for (var _i = 0; _i < array_length(_tags); _i++) {
            if (string_pos(_tags[_i], _n) > 0) {
                _pal = true;
                _why = "filename tag " + _tags[_i];
                break;
            }
        }
        if (!_pal) _why = "no region information, assuming NTSC";
    }

    nes_region_apply(_pal);
    show_debug_message("nes_region: " + (_pal ? "PAL" : "NTSC") + " (" + _why + ")");
    return _pal;
}
