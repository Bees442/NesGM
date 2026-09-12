/// @function nes_gpu_ensure_surfaces()
/// @description Recreates any of the renderer's surfaces the runtime threw away; reports whether all are usable.
function nes_gpu_ensure_surfaces() {
    if (!global.gpu_ready) return false;

    var _chr_lost = !surface_exists(global.gpu_chr_surf);
    if (_chr_lost) global.gpu_chr_surf = surface_create(256, global.gpu_chr_h);

    if (!surface_exists(global.gpu_nt_surf))    global.gpu_nt_surf = surface_create(256, 8);
    if (!surface_exists(global.gpu_pal_surf))   global.gpu_pal_surf = surface_create(32, 1);
    if (!surface_exists(global.gpu_state_surf)) global.gpu_state_surf = surface_create(256, 1);

    if (_chr_lost) nes_gpu_upload_chr();

    return true;
}
