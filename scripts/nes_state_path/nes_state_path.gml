/// @function nes_state_path(slot)
/// @description File path for a save-state slot (0-9), alongside the loaded ROM.
function nes_state_path(_slot) {
    return filename_change_ext(global.cart.filename, ".st" + string(_slot));
}
