#!/bin/sh

WESTON_INI="/etc/xdg/weston/weston.ini"

if [ ! -f "$WESTON_INI" ]; then
    mkdir -p "$(dirname "$WESTON_INI")"
    cat > "$WESTON_INI" << 'EOC'
[core]
shell=kiosk-shell.so
EOC
    sync
    reboot
fi

if ! awk '
    /^\[core\]/ { in_core=1; next }
    /^\[/ { in_core=0 }
    in_core && /^[[:space:]]*shell[[:space:]]*=[[:space:]]*kiosk-shell\.so[[:space:]]*$/ { found=1 }
    END { exit found ? 0 : 1 }
' "$WESTON_INI"; then
    echo "Configuring Weston kiosk shell..."

    if grep -q '^\[core\]' "$WESTON_INI"; then
        sed -i '/^\[core\]/a shell=kiosk-shell.so' "$WESTON_INI"
    else
        cat >> "$WESTON_INI" << 'EOC'

[core]
shell=kiosk-shell.so
EOC
    fi

    sync
    reboot
fi

while true; do
  gst-launch-1.0 playbin \
    uri=file:///home/weston/ezurio-nitrogen95-smarc-highlights.mp4 \
    video-sink="waylandsink fullscreen=true"

  timeout 103 gst-launch-1.0 libcamerasrc src::stream-role=still-capture \
    ! 'video/x-raw,width=3840,height=2160' \
    ! waylandsink fullscreen=true
done
