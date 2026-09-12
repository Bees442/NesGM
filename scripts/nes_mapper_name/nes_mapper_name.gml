/// @function nes_mapper_name(id)
/// @description The common name for a mapper number, for display; falls back to the bare number.
function nes_mapper_name(_id) {
    switch (_id) {
        case 0: return "NROM";
        case 1: return "MMC1";
        case 2: return "UxROM";
        case 3: return "CNROM";
        case 4: return "MMC3";
        case 7: return "AxROM";
        default: return "mapper " + string(_id);
    }
}
