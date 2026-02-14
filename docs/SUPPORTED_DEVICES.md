# Supported Devices

## ESP32-based

| Device | PlatformIO Target | Notes |
|--------|-------------------|-------|
| LILYGO T-Beam v0.7 | `tbeam` | Older version, limited availability |
| LILYGO T-Beam v1.1/v1.2 | `tbeam` | Most common T-Beam |
| LILYGO T-Beam Supreme | `tbeam-s3-core` | ESP32-S3 based |
| Heltec WiFi LoRa 32 V3 | `heltec-v3` | Popular, affordable |
| Heltec Wireless Stick Lite V3 | `heltec-wsl-v3` | Compact form factor |
| LILYGO T-Deck | `t-deck` | Built-in keyboard and screen |
| LILYGO LoRa32 V2.1 | `tlora-v2-1-1_6` | Budget option |
| Station G2 | `station-g2` | High-power base station |

## nRF52-based

| Device | PlatformIO Target | Notes |
|--------|-------------------|-------|
| RAK WisBlock RAK4631 | `rak4631` | Modular, low power |
| LILYGO T-Echo | `t-echo` | E-ink display, compact |

## Selecting Your Board

Use the PlatformIO target name when flashing:

```bash
bash scripts/flash.sh tbeam        # For T-Beam
bash scripts/flash.sh heltec-v3    # For Heltec V3
bash scripts/flash.sh rak4631      # For RAK4631
```
