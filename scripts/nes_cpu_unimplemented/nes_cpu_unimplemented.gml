/// @function nes_cpu_unimplemented(opcode)
/// @description Reports an opcode that has no case in nes_cpu_execute and charges it 2 cycles
/// so the CPU keeps moving. Only the handful of deliberately omitted unstable undocumented
/// opcodes can reach this.
function nes_cpu_unimplemented(_opcode) {
    show_debug_message("nes_cpu: unimplemented opcode " + string(_opcode)
        + " (0x" + nes_to_hex(_opcode, 2) + ") at PC=0x" + nes_to_hex(global.cpu_pc - 1, 4));
    return 2;
}
