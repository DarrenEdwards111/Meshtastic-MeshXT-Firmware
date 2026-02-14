#!/usr/bin/env bash
set -euo pipefail

# Meshtastic-MeshXT-Firmware Flash Script

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
FIRMWARE_DIR="$PROJECT_DIR/firmware"

if [ ! -d "$FIRMWARE_DIR" ]; then
    echo "Error: Meshtastic firmware not found. Run 'bash scripts/setup.sh' first."
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "Usage: bash scripts/flash.sh <board-target>"
    echo ""
    echo "Common board targets:"
    echo "  tbeam           LILYGO T-Beam (all versions)"
    echo "  heltec-v3       Heltec WiFi LoRa 32 V3"
    echo "  tlora-v2-1-1_6  LILYGO LoRa32 V2.1"
    echo "  t-deck          LILYGO T-Deck"
    echo "  rak4631         RAK WisBlock RAK4631"
    echo "  t-echo          LILYGO T-Echo"
    echo "  station-g2      Station G2"
    echo ""
    echo "Example: bash scripts/flash.sh tbeam"
    exit 0
fi

TARGET="$1"

echo "=== Flashing MeshXT firmware for: $TARGET ==="
cd "$FIRMWARE_DIR"
pio run -e "$TARGET" -t upload
echo ""
echo "✓ Flash complete! Your device is now running Meshtastic + MeshXT."
