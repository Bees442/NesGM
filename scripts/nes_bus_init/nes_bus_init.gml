function nes_bus_init() {
    global.ram = buffer_create(2048, buffer_fixed, 1);

    global.controller_state = [0, 0];
    global.controller_shift = [0, 0];
    global.controller_strobe = false;

    global.dma_extra_cycles = 0;
}
