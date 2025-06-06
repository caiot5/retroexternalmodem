#!/bin/bash

###############################################################################
# RetroExternalModem Configuration Menu Script
#
# Provides a CLI menu for:
#   1) Configuring Raspberry Pi Wi-Fi SSID/Password
#   2) Changing the dial-up ISP Provider telephone number 
#   3) Changing the modem baud rate
#
###############################################################################

# Must be run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root: sudo $0"
  exit 1
fi

TCP_SERVICE_FILE="/etc/systemd/system/tcpser.service"
WPA_SUPPLICANT_CONF="/etc/wpa_supplicant/wpa_supplicant.conf"
BACKUP_WPA="${WPA_SUPPLICANT_CONF}.bak"

# Detect wireless interface (wlan0, wlan1, etc.)
get_wifi_iface() {
  iface=$(iw dev 2>/dev/null | awk '$1=="Interface" {print $2; exit}')
  if [ -z "$iface" ]; then
    echo "Error: No wireless interface found."
    exit 1
  fi
  echo "$iface"
}

# Pause helper
pause() {
  read -rp "Press Enter to continue..."
}

# Main menu loop
while true; do
  clear
  echo "======================================"
  echo "  RetroExternalModem Configuration"
  echo "======================================"
  echo "1) Configure Wi-Fi"
  echo "2) Change dial-up ISP telephone"
  echo "3) Change modem baud rate"
  echo "q) Quit"
  echo "--------------------------------------"
  read -rp "Select an option: " choice

  case "$choice" in

    1)
      #########################################################################
      # Option 1: Configure Wi-Fi via raspi-config
      #########################################################################
      iface="$(get_wifi_iface)"
      echo ""
      echo "==== Configure Wi-Fi ===="
      current_ssid=$(iwgetid -r 2>/dev/null)
      if [ -z "$current_ssid" ]; then
        echo "Current Wi-Fi: (not connected)"
      else
        echo "Current Wi-Fi SSID: $current_ssid"
      fi

      read -rp "Do you want to change the Wi-Fi network? [y/N]: " yn
      case "$yn" in
        [Yy]* )
          # Backup existing wpa_supplicant.conf (if it exists)
          if [ -f "$WPA_SUPPLICANT_CONF" ]; then
            echo "Backing up existing $WPA_SUPPLICANT_CONF to $BACKUP_WPA ..."
            if cp "$WPA_SUPPLICANT_CONF" "$BACKUP_WPA"; then
              echo "[OK] Backup created."
            else
              echo "[FAIL] Could not back up $WPA_SUPPLICANT_CONF. Aborting."
              pause
              continue
            fi
          else
            echo "[INFO] No existing wpa_supplicant.conf found; skipping backup."
          fi

          # Scan for SSIDs
          echo ""
          echo "Scanning for available Wi-Fi networks (this may take 5–10 seconds)..."
          networks=()
          while IFS= read -r line; do
            ssid=$(echo "$line" | sed -n 's/.*ESSID:"\(.*\)".*/\1/p')
            if [ -n "$ssid" ] && [[ ! " ${networks[*]} " =~ " $ssid " ]]; then
              networks+=("$ssid")
            fi
          done < <(iwlist "$iface" scan 2>/dev/null | grep 'ESSID:')

          if [ "${#networks[@]}" -eq 0 ]; then
            echo "[ERROR] No networks found. Aborting."
            pause
            continue
          fi

          echo ""
          echo "Available networks:"
          for i in "${!networks[@]}"; do
            printf "  %2d) %s\n" $((i+1)) "${networks[i]}"
          done
          echo ""

          read -rp "Enter number of the SSID you want to join: " net_idx
          if ! [[ "$net_idx" =~ ^[0-9]+$ ]] || [ "$net_idx" -le 0 ] || [ "$net_idx" -gt "${#networks[@]}" ]; then
            echo "[ERROR] Invalid selection."
            pause
            continue
          fi
          selected_ssid="${networks[$((net_idx-1))]}"
          echo "You chose SSID: $selected_ssid"
          echo ""

          # Ask for encryption type & password
          echo "Encryption types:"
          echo "  1) Open (no password)"
          echo "  2) WEP"
          echo "  3) WPA/WPA2"
          read -rp "Select encryption type [1–3]: " enc_choice

          case "$enc_choice" in
            1)  wifi_pass="";;
            2|3)
              read -rsp "Enter password for \"$selected_ssid\": " wifi_pass
              echo ""
              ;;
            *)
              echo "[ERROR] Invalid choice of encryption."
              pause
              continue
              ;;
          esac

          # Use raspi-config nonint 
          echo ""
          echo "Applying Wi-Fi settings via raspi-config..."
          if [ "$enc_choice" -eq 1 ]; then
            raspi-config nonint do_wifi_ssid_passphrase "$selected_ssid" "" \
              && echo "[OK] raspi-config applied open network." \
              || { echo "[FAIL] raspi-config failed."; pause; continue; }
          else
            raspi-config nonint do_wifi_ssid_passphrase "$selected_ssid" "$wifi_pass" \
              && echo "[OK] raspi-config applied network settings." \
              || { echo "[FAIL] raspi-config failed."; pause; continue; }
          fi

          echo "Waiting 10 seconds to acquire new IP..."
          sleep 10

          echo "Pinging 8.8.8.8..."
          if ping -c 3 8.8.8.8 &>/dev/null; then
            echo "[OK] Connected successfully to \"$selected_ssid\"."
          else
            echo "[FAIL] Could not reach the internet. Restoring previous Wi-Fi config..."
            if [ -f "$BACKUP_WPA" ]; then
              cp "$BACKUP_WPA" "$WPA_SUPPLICANT_CONF"
              wpa_cli -i "$iface" reconfigure &>/dev/null
              echo "[RESTORED] Original wpa_supplicant.conf restored."
            else
              echo "[WARN] No backup available to restore."
            fi
          fi

          pause
          ;;
        *)
          echo "No changes made to Wi-Fi."
          pause
          ;;
      esac
      ;;

    2)
      #########################################################################
      # Option 2: Change dial-up ISP Provider telephone
      #########################################################################
      echo ""
      echo "==== Change Dial-Up ISP Telephone ===="
      if [ ! -f "$TCP_SERVICE_FILE" ]; then
        echo "[ERROR] Service file not found: $TCP_SERVICE_FILE"
        pause
        continue
      fi

      # Extract current telephone (pattern: -n<digits>=)
      current_tel=$(grep -oP '(?<=-n)[0-9]+(?==)' "$TCP_SERVICE_FILE" | head -n1)
      if [ -z "$current_tel" ]; then
        echo "Current telephone number: (none found)"
      else
        echo "Current telephone number: $current_tel"
      fi

      read -rp "Do you want to change it? [y/N]: " yn2
      case "$yn2" in
        [Yy]* )
          read -rp "Enter new telephone number: " new_tel
          if ! [[ "$new_tel" =~ ^[0-9]+$ ]]; then
            echo "[ERROR] Only digits allowed."
            pause
            continue
          fi

          echo "Updating $TCP_SERVICE_FILE..."
          # Replace first occurrence of -n<digits>= with -n<new_tel>=
          sed -i "0,/-n[0-9]\+=/s//-n${new_tel}=/" "$TCP_SERVICE_FILE" \
            && echo "[OK] Telephone number updated to $new_tel." \
            || { echo "[FAIL] Could not update $TCP_SERVICE_FILE."; pause; continue; }

          echo "Reloading systemd and restarting tcpser.service..."
          systemctl daemon-reload
          systemctl restart tcpser.service
          if systemctl is-active --quiet tcpser.service; then
            echo "[OK] tcpser.service restarted."
          else
            echo "[FAIL] tcpser.service failed to start. See 'journalctl -u tcpser.service'."
          fi
          pause
          ;;
        *)
          echo "No changes made to telephone number."
          pause
          ;;
      esac
      ;;

    3)
      #########################################################################
      # Option 3: Change modem baud rate
      #########################################################################
      echo ""
      echo "==== Change Modem Baud Rate ===="
      if [ ! -f "$TCP_SERVICE_FILE" ]; then
        echo "[ERROR] Service file not found: $TCP_SERVICE_FILE"
        pause
        continue
      fi

      # Extract current baud (pattern: -s <digits>)
      current_baud=$(grep -oP '(?<=-s )[0-9]+' "$TCP_SERVICE_FILE" | head -n1)
      if [ -z "$current_baud" ]; then
        echo "Current baud rate: (not found)"
      else
        echo "Current baud rate: $current_baud"
      fi

      read -rp "Do you want to change it? [y/N]: " yn3
      case "$yn3" in
        [Yy]* )
          echo ""
          echo "Select new baud rate:"
          baud_rates=(1200 2400 4800 9600 19200 38400 57600 115200)
          for i in "${!baud_rates[@]}"; do
            printf "  %2d) %s\n" $((i+1)) "${baud_rates[i]}"
          done
          echo ""
          read -rp "Enter choice [1–${#baud_rates[@]}]: " baud_idx
          if ! [[ "$baud_idx" =~ ^[0-9]+$ ]] || [ "$baud_idx" -le 0 ] || [ "$baud_idx" -gt "${#baud_rates[@]}" ]; then
            echo "[ERROR] Invalid selection."
            pause
            continue
          fi
          new_baud="${baud_rates[$((baud_idx-1))]}"
          echo "Updating baud rate to $new_baud..."

          # Replace "-s <old>" with "-s <new>"
          sed -i "s/-s $current_baud/-s $new_baud/" "$TCP_SERVICE_FILE" \
            && echo "[OK] Baud rate updated to $new_baud." \
            || { echo "[FAIL] Could not update $TCP_SERVICE_FILE."; pause; continue; }

          echo "Reloading systemd and restarting tcpser.service..."
          systemctl daemon-reload
          systemctl restart tcpser.service
          if systemctl is-active --quiet tcpser.service; then
            echo "[OK] tcpser.service restarted."
          else
            echo "[FAIL] tcpser.service failed to start. See 'journalctl -u tcpser.service'."
          fi
          pause
          ;;
        *)
          echo "No changes made to baud rate."
          pause
          ;;
      esac
      ;;

    q|Q)
      echo "Exiting."
      exit 0
      ;;
    *)
      echo "Invalid option."
      pause
      ;;
  esac
done
