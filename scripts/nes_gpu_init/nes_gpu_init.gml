// nes_gpu: renders the background on the GPU instead of pixel by pixel on the CPU.
//
// Profiling put the software scanline renderer at roughly half of a YYC frame (~11.5 ms of
// ~23 ms), and it is the one part of the emulator that is embarrassingly parallel, so it is the
// only piece worth moving. The CPU interpreter cannot go: it is strictly serial. Sprite 0 hit
// cannot go either - games poll it mid-frame, and reading GPU results back would stall.
//
// How the PPU's state reaches the shader:
//   * CHR and nametable memory become one-byte-per-texel surfaces;
//   * the palette becomes a 32-texel surface of finished RGB;
//   * the loopy v register, fine X and the mask bits are recorded per scanline into a
//     256x1 surface, because they change on every line;
//   * CHR bank mapping, mirroring and the pattern-table select change only a handful of times
//     per frame, so they are plain uniforms and the frame is drawn in bands between changes.
//
// Known v1 limits (the software path stays exact, and remains the default):
//   * the palette and nametable are sampled once per frame, at the top of the visible region,
//     so mid-frame changes to either are not reflected;
//   * only the background is drawn - sprites are still to come.

/// @function nes_gpu_init()
/// @description Allocates the surfaces and per-frame state the GPU renderer needs. Safe to
/// call on every ROM load; existing surfaces are released first.
function nes_gpu_init() {
    nes_gpu_free();

    // One texel per byte of CHR, 256 texels wide. Height covers the cartridge's whole CHR so
    // bank switching is just an offset the shader adds, with no re-upload.
    var _chr_rows = max(1, ceil(global.cart.chr_size / 256));
    global.gpu_chr_h = _chr_rows;
    global.gpu_chr_surf = surface_create(256, _chr_rows);
    global.gpu_chr_buf = buffer_create(256 * _chr_rows * 4, buffer_fixed, 1);

    // The console's 2KB of nametable RAM.
    global.gpu_nt_surf = surface_create(256, 8);
    global.gpu_nt_buf = buffer_create(256 * 8 * 4, buffer_fixed, 1);

    // 32 palette entries, already resolved to RGB.
    global.gpu_pal_surf = surface_create(32, 1);
    global.gpu_pal_buf = buffer_create(32 * 4, buffer_fixed, 1);

    // Per-scanline v register / fine X / mask flags.
    global.gpu_state_surf = surface_create(256, 1);
    global.gpu_state_buf = buffer_create(256 * 4, buffer_fixed, 1);

    // OAM as it stood at the top of the visible region, which is what the sprites are drawn from.
    global.gpu_oam = buffer_create(256, buffer_fixed, 1);

    global.gpu_bands = [];
    global.gpu_band_count = 0;

    global.gpu_ready = true;
    nes_gpu_upload_chr();
}
