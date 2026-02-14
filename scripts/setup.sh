#!/usr/bin/env bash
set -euo pipefail

# Meshtastic-MeshXT-Firmware Setup Script
# Clones the Meshtastic firmware, copies MeshXT files, and applies patches.

MESHTASTIC_TAG="v2.5.6.0"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
FIRMWARE_DIR="$PROJECT_DIR/firmware"

echo "=== Meshtastic-MeshXT-Firmware Setup ==="
echo ""

# Step 1: Clone Meshtastic firmware
if [ -d "$FIRMWARE_DIR" ]; then
    echo "✓ Meshtastic firmware directory already exists at $FIRMWARE_DIR"
    echo "  Delete it and re-run this script to start fresh."
else
    echo "→ Cloning Meshtastic firmware (${MESHTASTIC_TAG})..."
    git clone --depth 1 --branch "$MESHTASTIC_TAG" \
        https://github.com/meshtastic/firmware.git "$FIRMWARE_DIR"
    echo "→ Initialising submodules..."
    cd "$FIRMWARE_DIR"
    git submodule update --init --recursive
    cd "$PROJECT_DIR"
    echo "✓ Meshtastic firmware cloned."
fi

# Step 2: Copy MeshXT source files
echo "→ Copying MeshXT source files..."
cp "$PROJECT_DIR/src/modules/MeshXTCompress.cpp" "$FIRMWARE_DIR/src/modules/"
cp "$PROJECT_DIR/src/modules/MeshXTCompress.h"   "$FIRMWARE_DIR/src/modules/"
cp "$PROJECT_DIR/src/modules/MeshXTFEC.cpp"       "$FIRMWARE_DIR/src/modules/"
cp "$PROJECT_DIR/src/modules/MeshXTFEC.h"         "$FIRMWARE_DIR/src/modules/"
cp "$PROJECT_DIR/src/modules/MeshXTModule.cpp"    "$FIRMWARE_DIR/src/modules/"
cp "$PROJECT_DIR/src/modules/MeshXTModule.h"      "$FIRMWARE_DIR/src/modules/"
cp "$PROJECT_DIR/src/modules/MeshXTPacket.cpp"    "$FIRMWARE_DIR/src/modules/"
cp "$PROJECT_DIR/src/modules/MeshXTPacket.h"      "$FIRMWARE_DIR/src/modules/"
echo "✓ MeshXT source files copied."

# Step 3: Apply patch to register MeshXTModule
echo "→ Applying MeshXT module registration patch..."
cd "$FIRMWARE_DIR"
if git apply --check "$PROJECT_DIR/patches/modules_cpp.patch" 2>/dev/null; then
    git apply "$PROJECT_DIR/patches/modules_cpp.patch"
    echo "✓ Patch applied successfully."
else
    # Check if already applied
    if grep -q "MeshXTModule" src/modules/Modules.cpp 2>/dev/null; then
        echo "✓ Patch already applied."
    else
        echo "⚠ Patch failed to apply cleanly. Applying manually..."
        # Manual fallback: add include and module registration
        sed -i '/#include "SerialModule.h"/a #include "MeshXTModule.h"' src/modules/Modules.cpp
        sed -i '/new SerialModule/a \    new MeshXTModule();' src/modules/Modules.cpp
        echo "✓ Manual patch applied."
    fi
fi
cd "$PROJECT_DIR"

# Step 4: Patch Router.cpp to intercept outgoing text messages
echo "→ Patching Router.cpp for MeshXT send interception..."
cd "$FIRMWARE_DIR"
ROUTER_FILE="src/mesh/Router.cpp"
if grep -q "MeshXTModule" "$ROUTER_FILE" 2>/dev/null; then
    echo "✓ Router.cpp already patched."
else
    # Add #include at the top (after existing includes)
    sed -i '/#include "Router.h"/a #include "modules/MeshXTModule.h"\nextern MeshXTModule *meshXTModule;' "$ROUTER_FILE"

    # Add intercept call at the start of Router::send()
    # Find "ErrorCode Router::send" and add the hook after the opening brace
    sed -i '/ErrorCode Router::send/,/{/ {
        /{/ a\
\    // MeshXT: intercept outgoing text messages and compress them\
\    if (meshXTModule && p->decoded.portnum == meshtastic_PortNum_TEXT_MESSAGE_APP) {\
\        meshXTModule->interceptTextMessage(p);\
\    }
    }' "$ROUTER_FILE"

    echo "✓ Router.cpp patched — outgoing text messages will be auto-compressed."
fi
cd "$PROJECT_DIR"

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "  1. Connect your device via USB"
echo "  2. Flash with:  bash scripts/flash.sh tbeam"
echo "     (replace 'tbeam' with your board — run 'bash scripts/flash.sh' for options)"
echo ""
