# 📡 Meshtastic-MeshXT-Firmware

**Meshtastic firmware with MeshXT compression + error correction built in.**

Extend your mesh network's effective range by compressing messages with Smaz short-string compression and protecting them with Reed-Solomon forward error correction — all transparent to the user.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

---

## What MeshXT Adds

| Feature | Description |
|---------|-------------|
| **Smaz Compression** | 254-entry codebook optimised for short English messages. Typical 30-50% size reduction. |
| **Reed-Solomon FEC** | Corrects bit errors in received packets. Three levels: Low (8 errors), Medium (16), High (32). |
| **Compact Framing** | 2-byte header encodes version, compression type, FEC level, and flags. |
| **Backward Compatible** | Uses `PRIVATE_APP` portnum — standard Meshtastic nodes simply ignore MeshXT packets. |
| **Fully Transparent** | Works with the standard Meshtastic app (Android/iOS). No special app needed. |

## How It Works with the Meshtastic App

MeshXT is completely invisible to you. Flash your device, open the Meshtastic app, send messages as normal.

**Sending:** When you type a message in the app, MeshXT automatically intercepts it before transmission, compresses the text with Smaz, adds Reed-Solomon error correction, and sends the smaller, protected packet over the air.

**Receiving:** When a MeshXT packet arrives from another device, the module automatically decodes and decompresses it, then surfaces it in your Meshtastic app as a normal text message.

You never see the compression happening. The app shows regular text messages. The radio sends smaller, error-corrected packets. Both devices need MeshXT flashed for the benefits — standard Meshtastic nodes on the network still work fine alongside MeshXT nodes.

## Supported Devices

### ESP32-based
- **LILYGO T-Beam** (v0.7, v1.1, v1.2, Supreme)
- **Heltec V3** (WiFi LoRa 32 V3)
- **LILYGO T-Deck**
- **Heltec Wireless Stick Lite V3**

### nRF52-based
- **RAK WisBlock RAK4631**
- **LILYGO T-Echo**

See [docs/SUPPORTED_DEVICES.md](docs/SUPPORTED_DEVICES.md) for the full list.

## Prerequisites

- [PlatformIO CLI](https://platformio.org/install/cli) or PlatformIO IDE (VS Code extension)
- [Git](https://git-scm.com/)
- Python 3.8+

---

## Quick Start — Heltec V3

The most common device. Plug in USB-C and run four commands:

```bash
# Install PlatformIO (if you haven't already)
pip install platformio

# Clone this repo
git clone https://github.com/DarrenEdwards111/Meshtastic-MeshXT-Firmware.git
cd Meshtastic-MeshXT-Firmware

# Run setup (clones Meshtastic v2.5.6.0, copies MeshXT modules, applies patch)
bash scripts/setup.sh

# Plug in your Heltec V3 via USB-C, then flash
bash scripts/flash.sh heltec-v3
```

That's it. Your Heltec is now running Meshtastic with MeshXT compression + error correction on every message.

## Quick Start — Other Devices

Same process, just change the board target:

```bash
git clone https://github.com/DarrenEdwards111/Meshtastic-MeshXT-Firmware.git
cd Meshtastic-MeshXT-Firmware
bash scripts/setup.sh

# Pick your board:
bash scripts/flash.sh tbeam          # LilyGO T-Beam
bash scripts/flash.sh heltec-v3      # Heltec V3
bash scripts/flash.sh tlora-v2-1-1_6 # LilyGO T-LoRa
bash scripts/flash.sh tbeam-s3-core  # T-Beam S3
bash scripts/flash.sh rak4631        # RAK WisBlock (nRF52)
bash scripts/flash.sh t-echo         # LilyGO T-Echo (nRF52)
bash scripts/flash.sh t-deck         # LilyGO T-Deck
```

Run `bash scripts/flash.sh` with no arguments to see all supported boards.

## Manual Install

If you prefer to integrate MeshXT into an existing Meshtastic build:

```bash
# 1. Clone the Meshtastic firmware
git clone --depth 1 --branch v2.5.6.0 https://github.com/meshtastic/firmware.git
cd firmware
git submodule update --init

# 2. Copy MeshXT source files
cp /path/to/Meshtastic-MeshXT-Firmware/src/modules/MeshXT*.cpp src/modules/
cp /path/to/Meshtastic-MeshXT-Firmware/src/modules/MeshXT*.h src/modules/

# 3. Register the MeshXT module — edit src/modules/Modules.cpp:
#    Add near the top:    #include "MeshXTModule.h"
#    Add in setupModules(): new MeshXTModule();

# 4. Build
pio run -e tbeam -t upload
```

---

## How It Works

### Packet Format

```
Byte 0: [VVVV CCCC]  Version (4 bits) | Compression type (4 bits)
Byte 1: [FFFF xxxx]  FEC level (4 bits) | Flags (4 bits)
Byte 2+: Payload (compressed + FEC-encoded data)
```

### Compression Types

| Code | Type | Description |
|------|------|-------------|
| 0 | None | Raw text, no compression |
| 1 | Smaz | Short-string compression via 254-entry codebook |
| 2 | Codebook | Reserved for future custom codebooks |

### FEC Levels

| Code | Level | Parity Bytes | Corrects Up To |
|------|-------|-------------|----------------|
| 0 | None | 0 | — |
| 1 | Low | 16 | 8 symbol errors |
| 2 | Medium | 32 | 16 symbol errors |
| 3 | High | 64 | 32 symbol errors |

### Pipeline

**Sending:** Text → Smaz compress → Reed-Solomon FEC encode → 2-byte header → transmit via `PRIVATE_APP` portnum

**Receiving:** Receive `PRIVATE_APP` packet → parse header → FEC decode/correct → Smaz decompress → display as text message

---

## Configuration

MeshXT currently uses sensible defaults:

- **Compression:** Smaz (`MESHXT_COMP_SMAZ`)
- **FEC Level:** Low (`MESHXT_FEC_LOW_CODE` — 16 parity bytes)

To change defaults, edit `MeshXTModule.cpp` constructor:

```cpp
MeshXTModule::MeshXTModule()
    : MeshModule("MeshXT", MESHXT_PORTNUM, MeshModule::SECURITY_PKI)
{
    compType = MESHXT_COMP_SMAZ;       // MESHXT_COMP_NONE or MESHXT_COMP_SMAZ
    fecLevel = MESHXT_FEC_LOW_CODE;    // MESHXT_FEC_NONE_CODE, _LOW_CODE, _MEDIUM_CODE, _HIGH_CODE
}
```

Higher FEC = more error correction but larger packets. For most use cases, `LOW` is the best balance.

---

## Compatibility

**MeshXT nodes coexist peacefully with standard Meshtastic nodes.** MeshXT uses the `PRIVATE_APP` portnum (256), which standard nodes simply ignore. Your mesh network continues to function normally — MeshXT-equipped nodes just get the bonus of compressed, error-corrected messaging between each other.

- MeshXT → MeshXT: Full compression + FEC ✅
- MeshXT → Standard: Packet is ignored (not displayed) ⚠️
- Standard → MeshXT: Normal text received as usual ✅

For mixed networks, MeshXT nodes can still send regular uncompressed messages via the standard Meshtastic UI.

---

## Contributing

Contributions welcome! Please:

1. Fork the repo
2. Create a feature branch (`git checkout -b feature/amazing-thing`)
3. Commit your changes
4. Push and open a Pull Request

Please follow the existing code style and include tests where possible.

---

## Links

- [MeshXT npm library](https://www.npmjs.com/package/meshxt) — JavaScript implementation for Node.js/browser
- [MeshXT main repo](https://github.com/DarrenEdwards111/meshxt) — Core protocol library
- [Meshtastic](https://meshtastic.org/) — The mesh networking platform

---

## License

This project is licensed under the **GNU General Public License v3.0** — see [LICENSE](LICENSE) for details. Required because Meshtastic firmware is GPL-3.0 licensed.

**© 2025 Mikoshi Ltd**
