#!/bin/bash
# Read pywal colors
COLORS_FILE=~/.cache/wal/colors
mapfile -t COLORS < "$COLORS_FILE"

# Assign colors (using a more diverse mapping)
BACKGROUND="${COLORS[0]}"  # color0: background
FOREGROUND="${COLORS[7]}"  # color7: often a lighter color for text
CARET="${COLORS[15]}"      # color15: bright accent for caret
STRING="${COLORS[2]}"      # color2: for strings
KEYWORD="${COLORS[1]}"     # color1: for keywords
COMMENT="${COLORS[8]}"     # color8: for comments
NUMBER="${COLORS[4]}"      # color4: for numbers
FUNCTION="${COLORS[6]}"    # color6: for functions

# Generate tmTheme file
cat << EOF > ~/.config/bat/themes/pywal.tmTheme
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>name</key>
    <string>Pywal Theme</string>
    <key>settings</key>
    <array>
        <dict>
            <key>settings</key>
            <dict>
                <key>background</key>
                <string>$BACKGROUND</string>
                <key>foreground</key>
                <string>$FOREGROUND</string>
                <key>caret</key>
                <string>$CARET</string>
                <key>lineHighlight</key>
                <string>${COLORS[8]}</string>
            </dict>
        </dict>
        <dict>
            <key>scope</key>
            <string>keyword</string>
            <key>settings</key>
            <dict>
                <key>foreground</key>
                <string>$KEYWORD</string>
            </dict>
        </dict>
        <dict>
            <key>scope</key>
            <string>string</string>
            <key>settings</key>
            <dict>
                <key>foreground</key>
                <string>$STRING</string>
            </dict>
        </dict>
        <dict>
            <key>scope</key>
            <string>comment</string>
            <key>settings</key>
            <dict>
                <key>foreground</key>
                <string>$COMMENT</string>
            </dict>
        </dict>
        <dict>
            <key>scope</key>
            <string>constant.numeric</string>
            <key>settings</key>
            <dict>
                <key>foreground</key>
                <string>$NUMBER</string>
            </dict>
        </dict>
        <dict>
            <key>scope</key>
            <string>entity.name.function</string>
            <key>settings</key>
            <dict>
                <key>foreground</key>
                <string>$FUNCTION</string>
            </dict>
        </dict>
    </array>
</dict>
</plist>
EOF

# Rebuild bat cache
bat cache --build
