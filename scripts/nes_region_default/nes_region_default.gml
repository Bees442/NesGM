/// @function nes_region_default()
/// @description Installs NTSC timing so the globals exist before any ROM is loaded.
function nes_region_default() {
    nes_region_apply(false);
}
