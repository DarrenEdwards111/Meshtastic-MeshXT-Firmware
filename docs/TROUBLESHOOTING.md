# Troubleshooting

## Setup Issues

### `git submodule update` fails
The Meshtastic firmware has many submodules. Try:
```bash
cd firmware
git submodule update --init --recursive --depth 1
```

### Patch fails to apply
The patch is written for Meshtastic `v2.5.6.0`. If you're using a different version, the patch may not apply cleanly. The setup script has a manual fallback, but you can also edit `firmware/src/modules/Modules.cpp` by hand:

1. Add `#include "MeshXTModule.h"` near the other `#include` lines
2. Add `new MeshXTModule();` inside the `setupModules()` function

## Build Issues

### `fatal error: MeshModule.h: No such file or directory`
You're building the MeshXT files outside the Meshtastic firmware tree. Make sure you ran `setup.sh` or manually copied the files into `firmware/src/modules/`.

### `undefined reference to meshxt_fec_init`
All 8 MeshXT files must be present. Check that both `.cpp` and `.h` files are in `firmware/src/modules/`.

### Build runs out of memory (ESP32)
Try building with FEC set to `MESHXT_FEC_NONE_CODE` to reduce code size, or use a board with more flash.

## Flash Issues

### Device not detected on USB
- Try a different USB cable (some are charge-only)
- Install CP2102/CH340 USB drivers for your OS
- On Linux: add your user to the `dialout` group: `sudo usermod -aG dialout $USER`

### Upload fails with timeout
- Hold the BOOT button while clicking RST on ESP32 boards
- For T-Beam: hold the middle button during reset

## Runtime Issues

### MeshXT messages not showing on other nodes
Both sender and receiver need MeshXT installed. Standard Meshtastic nodes ignore `PRIVATE_APP` packets — this is by design.

### Messages appear garbled
Check that both nodes are running the same MeshXT version. Different codebook versions are not compatible.

### Higher battery drain
FEC encoding uses additional CPU cycles. If battery life is critical, set `fecLevel = MESHXT_FEC_NONE_CODE` in `MeshXTModule.cpp`.
