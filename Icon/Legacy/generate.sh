#!/bin/bash

set -e

if ! command -v gm >/dev/null 2>&1; then
    echo "GraphicsMagick (\`gm\`) is required to export legacy icons."
    exit 1
fi

cd "$(dirname "$(realpath "$0")")"

convert_icon () {
    ICON_TYPE="$1"
    ICON_SRC="$2"
    ICON_DARK_SUFFIX="$3"

    ICON_SIZE=$(gm identify -format "%w,%h" "$ICON_SRC")

    if [ "$ICON_SIZE" != "2048,2048" ]; then
        echo "Source icon must be of size 2048x2048 (currently \"$ICON_SIZE\")"
        exit 1
    fi

    generate_images() {
        FORMAT="png"
        QUALITY="90"
        WIDTH="$1"
        TWOX_WIDTH=$(( WIDTH * 2 )) 

        # 2x.
        gm convert "$ICON_SRC" -resize "${TWOX_WIDTH}x${TWOX_WIDTH}" -format $FORMAT -quality $QUALITY "${ICON_TYPE}.iconset/icon_${WIDTH}x${WIDTH}@2x${ICON_DARK_SUFFIX}.png"
        # 1x.
        gm convert "$ICON_SRC" -resize "${WIDTH}x${WIDTH}" -format $FORMAT -quality $QUALITY "${ICON_TYPE}.iconset/icon_${WIDTH}x${WIDTH}${ICON_DARK_SUFFIX}.png"
    }

    generate_images 512
    generate_images 256
    generate_images 128
    generate_images 32
    generate_images 16
}

mkdir -p GodotLG-Default.iconset/
mkdir -p GodotLG-Dark.iconset/

convert_icon GodotLG-Default ../Export/GodotLG-macOS-Default-1024x1024@2x.webp ""
convert_icon GodotLG-Dark ../Export/GodotLG-macOS-Dark-1024x1024@2x.webp "~dark"

mkdir -p GodotLG.iconset
cp GodotLG-Default.iconset/* GodotLG.iconset/
cp GodotLG-Dark.iconset/* GodotLG.iconset/
rm -rf GodotLG-Default.iconset/
rm -rf GodotLG-Dark.iconset/

iconutil -c icns GodotLG.iconset

mv GodotLG.icns ../Resources/

