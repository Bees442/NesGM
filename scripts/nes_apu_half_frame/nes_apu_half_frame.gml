/// @function nes_apu_half_frame()
/// @description Clocks length counters and the pulse sweep units (~120Hz via the frame sequencer).
function nes_apu_half_frame() {
    if (!global.apu_pulse_halt[0] && global.apu_pulse_length[0] > 0) global.apu_pulse_length[0] -= 1;
    if (!global.apu_pulse_halt[1] && global.apu_pulse_length[1] > 0) global.apu_pulse_length[1] -= 1;
    if (!global.apu_tri_halt && global.apu_tri_length > 0) global.apu_tri_length -= 1;
    if (!global.apu_noise_halt && global.apu_noise_length > 0) global.apu_noise_length -= 1;

    nes_apu_sweep_clock(0);
    nes_apu_sweep_clock(1);
}
