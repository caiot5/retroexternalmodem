#!/bin/bash
# /WiFi2DialUp/settings.sh
echo "==== Current Settings ===="
echo "Wi-Fi SSID: $(iwgetid -r 2>/dev/null || echo 'not connected')"

service_line=$(grep '^ExecStart=' /etc/systemd/system/tcpser.service)
tel_num=$(echo "$service_line" \
          | grep -oP '(?<=-n)[0-9]+(?==)' \
          | head -n1)

if [ -z "$tel_num" ]; then
  echo "Dial-up telephone: (not set)"
else
  echo "Dial-up telephone: $tel_num"
fi

baud=$(echo "$service_line" \
        | grep -oP '(?<=-s )[0-9]+' \
        | head -n1)

if [ -z "$baud" ]; then
  echo "Baud rate: (not set)"
else
  echo "Baud rate: $baud"
fi
