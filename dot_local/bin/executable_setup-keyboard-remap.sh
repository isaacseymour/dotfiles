#!/bin/sh
# Apply hidutil keyboard remappings.
# Called at login by ~/Library/LaunchAgents/local.KeyRemapping.plist.
#
# HID usages:
#   0x29 Esc | 0x39 Caps | 0xE0 L Ctrl | 0xE3 L Cmd | 0xE4 R Ctrl | 0xE7 R Cmd

# 1. System-wide: Caps → Esc (covers built-in, future keyboards, and any
#    external whose only customisation is Caps→Esc — e.g. vendor 0x05f3
#    product 0x0007).
hidutil property --set '{
  "UserKeyMapping":[
    {"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029}
  ]
}' >/dev/null

# 2. Kinesis Advantage (vendor 0x29ea, product 0x0102): Caps→Esc + full
#    bi-directional Cmd↔Ctrl swap so the keys live where macOS expects them.
hidutil property --matching '{"VendorID":0x29ea,"ProductID":0x0102}' --set '{
  "UserKeyMapping":[
    {"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029},
    {"HIDKeyboardModifierMappingSrc":0x7000000e0,"HIDKeyboardModifierMappingDst":0x7000000e3},
    {"HIDKeyboardModifierMappingSrc":0x7000000e3,"HIDKeyboardModifierMappingDst":0x7000000e0},
    {"HIDKeyboardModifierMappingSrc":0x7000000e4,"HIDKeyboardModifierMappingDst":0x7000000e7},
    {"HIDKeyboardModifierMappingSrc":0x7000000e7,"HIDKeyboardModifierMappingDst":0x7000000e4}
  ]
}' >/dev/null

# Add new keyboards by appending another `hidutil property --matching ...` block
# above. Get the IDs from `hidutil list` after plugging the keyboard in.
