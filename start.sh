#!/bin/bash

# Clean up X server files to avoid conflicts whilst instantiating
# the virtual framebuffer after a restart
rm -f /tmp/.X*-lock /tmp/.X11-unix/X*

# Set the display
# The default mode is headless, using ":1" virtual display with xvfb
case "$d" in
    ""|h)
        # Instantiate a virtual framebuffer
        Xvfb "$DISPLAY" -screen 0 1920x1080x24 &
        ;;
    d)
        # Use the Docker host's display
        DISPLAY=host.docker.internal:0
        ;;
    *)
        # Any user-defined display
        DISPLAY="$d"
esac

# Set `tradingMode` in jts.ini based on the `TRADING_MODE` environment
# variable
if [ "$TRADING_MODE" == "l" ]; then
    echo "Setting IB Gateway to Live Trading mode"
    sed -i 's/tradingMode=[pl]/tradingMode=l/' /home/docker/Jts/jts.ini
else
    echo "Setting IB Gateway to Paper Trading mode"
    sed -i 's/tradingMode=[pl]/tradingMode=p/' /home/docker/Jts/jts.ini
fi

# Launch IB Gateway with the provided credentials
ibgateway/ibgateway username="$u" password="$p" &

# If paper trading mode, accept the "Paper Trading Account" warning
if [ "$TRADING_MODE" == "p" ]; then
    # Wait for the paper trading warning window to appear
    echo "Waiting for paper trading warning to appear..."
    while ! xdotool search --name "Warning" &>/dev/null; do
        # Check for "Existing session detected" window
        if xdotool search --name "Existing session detected" &>/dev/null; then
            echo "Detected existing session. Logging in with this one..."
            # Kick out other session
            xdotool key 'Return'
        fi
        sleep 3
    done
    echo "Paper trading warning detected. Pressing Return to close it..."
    sleep 3
    # Press the return key to accept and close the warning
    xdotool key 'Return'

# If live trading mode, wait until the 2FA completes
else
    # Wait for 2FA window to appear
    echo "Waiting for 2FA window to appear..."
    while ! xdotool search --name "Second Factor Authentication" &>/dev/null
    do
        sleep 3
    done
    echo "2FA window detected"

    # Wait for 2FA process to complete and window to disappear
    while xdotool search --name "Second Factor Authentication" &>/dev/null; do
        echo "Waiting for 2FA to complete..."
        sleep 3
    done
    echo "2FA completed"

    window_id=$(xdotool search --onlyvisible --name "IBKR Gateway" | head -n 1)
    eval $(xdotool getwindowgeometry --shell "$window_id")
    xdotool mousemove --window "$window_id" \
        $(echo "$WIDTH * 0.56" | bc | cut -d. -f1) \
        $(echo "$HEIGHT * 0.71" | bc | cut -d. -f1)
    echo "Logging in"
    sleep 5
    xdotool click 1
fi

# Acknowledge the "API Security Setting Updated" dialog, which appears
# shortly after login in both trading modes with OK selected by default.
# The dialog has the same "IBKR Gateway" title as the main window, so it
# is detected by a second visible window with that title
echo "Waiting for API security setting dialog to appear..."
while [ "$(xdotool search --onlyvisible --name "IBKR Gateway" 2>/dev/null |
        wc -l)" -lt 2 ]; do
    sleep 3
done
echo "API security setting dialog detected. Pressing Return to close it"
sleep 3
xdotool key 'Return'

# Keep the container running to allow IB Gateway daily restart
tail -f /dev/null
