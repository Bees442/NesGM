# NesGM

NesGM is a Nintendo Entertainment System emulator made with GameMaker.
This is Technical experiment

## Features
- iNES ROM loading (`.nes`)
- Supported mappers: NROM (0), MMC1 (1), UxROM (2), CNROM (3), MMC3 (4), and AxROM (7)
- NTSC and PAL timing modes
- Keyboard and gamepad input
- Sound, mute, fullscreen, frame-rate limiter, and region controls
- Ten save-state slots
## Controls

| Action | Keyboard |
| --- | --- |
| Move | Arrow keys |
| A | `X` |
| B | `Z` |
| Start | `Enter` |
| Select | `Shift` |
| Open ROM | `Enter` or `O` on the start screen |
| Pause menu | `Esc` |
| Save state | `F5` |
| Load state | `F8` |
| Choose save slot | `0`–`9` |
| Mute | `M` |

Gamepads are supported automatically when a controller is connected.

## Using NesGM

1. Start the application.
2. Select **Choose ROM**, or press `Enter` / `O`.
3. Pick a valid `.nes` ROM file.
4. Press `Esc` at any time to open the pause menu.

The pause menu contains ROM loading, system settings, fullscreen, audio controls, and save-state actions. Emulation is paused while the menu is open.

## Building from Source

Open `NesGM.yyp` in GameMaker, then use its Windows build workflow to create an executable. The project is configured for a resizable Windows window and requires a GameMaker installation with a Windows export runtime.

## Which is better to use: vm or yyc?

It would be best to use yyc, as it doubles the performance and allows you to achieve a stable 60 FPS in the emulator, while on the VM you’ll get at best 40 FPS.