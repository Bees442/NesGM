/// @function nes_ui_draw_screen(surface, x, y, w, h)
/// @description Draws the emulated picture to the window, desaturated by however far the menu has faded in.
function nes_ui_draw_screen(_surface, _x, _y, _w, _h) {
    var _amount = global.ui_mono;

    if (_amount <= 0.001) {
        draw_surface_stretched(_surface, _x, _y, _w, _h);
        return;
    }

    shader_set(shd_nes_mono);
    shader_set_uniform_f(shader_get_uniform(shd_nes_mono, "u_amount"), _amount);
    shader_set_uniform_f(shader_get_uniform(shd_nes_mono, "u_darken"), 0.55);
    shader_set_uniform_f(shader_get_uniform(shd_nes_mono, "u_tint"), 1.0);
    draw_surface_stretched(_surface, _x, _y, _w, _h);
    shader_reset();
}
