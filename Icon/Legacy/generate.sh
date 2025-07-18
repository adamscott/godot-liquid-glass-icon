#!/bin/bash

set -e

if ! command -v gm >/dev/null 2>&1; then
    echo "GraphicsMagick (\`gm\`) is required to export legacy icons."
    exit 1
fi

cd $(dirname "$(realpath $0)")

convert_icon () {
    ICON_TYPE="$1"
    ICON_SRC="$2"

    ICON_SIZE=$(gm identify -format "%w,%h" $ICON_SRC)

    if [ $ICON_SIZE != "2048,2048" ]; then
        echo "Source icon must be of size 2048x2048 (currently \"$ICON_SIZE\")"
        exit 1
    fi

    generate_images() {
        FORMAT="png"
        QUALITY="90"
        WIDTH="$1"
        TWOX_WIDTH=$(expr $WIDTH \* 2)

        # 2x.
        gm convert $ICON_SRC -resize "$TWOX_WIDTH"x"$TWOX_WIDTH" -format $FORMAT -quality $QUALITY "$ICON_TYPE.iconset"/icon_"$WIDTH"x"$WIDTH"@2x.png
        # 1x.
        gm convert $ICON_SRC -resize "$WIDTH"x"$WIDTH" -format $FORMAT -quality $QUALITY "$ICON_TYPE.iconset"/icon_"$WIDTH"x"$WIDTH".png
    }

    generate_images 512
    generate_images 256
    generate_images 128
    generate_images 32
    generate_images 16
}

convert_icon GodotLG-Default ../Export/GodotLG-macOS-Default-1024x1024@2x.webp
convert_icon GodotLG-Dark ../Export/GodotLG-macOS-Dark-1024x1024@2x.webp

iconutil -c icns GodotLG-Default.iconset
iconutil -c icns GodotLG-Dark.iconset

mv GodotLG-Default.icns ../Resources/
mv GodotLG-Dark.icns ../Resources/

