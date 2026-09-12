/// @function nes_to_hex(value, digits)
/// @description Zero-padded uppercase hex string, used only for debug logging.
function nes_to_hex(_value, _digits) {
    var _hexchars = "0123456789ABCDEF";
    var _s = "";
    var _v = _value;
    for (var _i = 0; _i < _digits; _i++) {
        var _nibble = _v & 0xF;
        _s = string_char_at(_hexchars, _nibble + 1) + _s;
        _v = _v >> 4;
    }
    return _s;
}
