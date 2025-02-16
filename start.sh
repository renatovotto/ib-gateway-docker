#!/bin/bash

# Confirm TRADING_MODE environment variable (default is "p")
TRADING_MODE="${m:-p}"

# Set `tradingMode` in jts.ini based on the `TRADING_MODE` environment
# variable
if [ "$TRADING_MODE" == "l" ]; then
    echo "Setting IB Gateway to Live Trading mode"
    sed -i 's/tradingMode=[pl]/tradingMode=l/' /home/docker/Jts/jts.ini
else
    echo "Setting IB Gateway to Paper Trading mode"
    sed -i 's/tradingMode=[pl]/tradingMode=p/' /home/docker/Jts/jts.ini
fi

# Launch IB Gateway with any provided arguments
ibgateway/ibgateway username="$u" password="$p" &

# Acceot the "Paper Trading Account" warning
if [ "$TRADING_MODE" == "p" ]; then
    sleep 30
    xdotool key 'Return'
fi

# Capture the PID of the IB Gateway process
GATEWAY_PID=$!

# Wait for the IB Gateway process to complete
wait $GATEWAY_PID

# Keep the container running to allow IB Gateway daily restart
tail -f /dev/null
