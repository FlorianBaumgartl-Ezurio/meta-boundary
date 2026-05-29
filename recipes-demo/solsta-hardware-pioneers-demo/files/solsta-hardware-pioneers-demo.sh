#!/bin/sh

WESTON_INI="/etc/xdg/weston/weston.ini"
PIDFILE="/tmp/solsta-demo.pid"

VIDEO_URI="file:///home/weston/ezurio-nitrogen95-smarc-highlights.mp4"
CAMERA_PIPELINE="libcamerasrc src::stream-role=still-capture ! video/x-raw,width=3840,height=2160 ! waylandsink fullscreen=true"

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

stop_current() {
    if [ -f "$PIDFILE" ]; then
        PID=$(cat "$PIDFILE")

        kill -TERM -"$PID" 2>/dev/null
        sleep 1
        kill -KILL -"$PID" 2>/dev/null

        rm -f "$PIDFILE"
    fi

    killall gst-launch-1.0 2>/dev/null
    killall timeout 2>/dev/null
}

cleanup() {
    stop_current
    killall evtest 2>/dev/null
    exit 0
}

trap cleanup INT TERM

start_video() {
    stop_current

    setsid sh -c "
        while true; do
            gst-launch-1.0 playbin \
                uri=$VIDEO_URI \
                video-sink='waylandsink fullscreen=true'
        done
    " &

    echo $! > "$PIDFILE"
}

start_camera() {
    stop_current

    setsid sh -c "
        gst-launch-1.0 $CAMERA_PIPELINE
    " &

    echo $! > "$PIDFILE"
}

start_loop_up() {
    stop_current

    setsid sh -c "
        while true; do
            gst-launch-1.0 playbin \
                uri=$VIDEO_URI \
                video-sink='waylandsink fullscreen=true'

            timeout 103 gst-launch-1.0 $CAMERA_PIPELINE
        done
    " &

    echo $! > "$PIDFILE"
}

stop_mode() {
    stop_current
}

start_loop_up

while true; do
    KEYBOARD=$(ls /dev/input/by-id/*-kbd 2>/dev/null | head -n1)

    if [ -n "$KEYBOARD" ]; then
        evtest --grab "$KEYBOARD" 2>/dev/null | while read line; do
            echo "$line" | grep -q "value 1" || continue

            case "$line" in
                *"(KEY_UP),"*)
                    start_loop_up
                    ;;

                *"(KEY_DOWN),"*)
                    stop_mode
                    ;;

                *"(KEY_LEFT),"*)
                    start_video
                    ;;

                *"(KEY_RIGHT),"*)
                    start_camera
                    ;;
            esac
        done
    fi

    sleep 3
done