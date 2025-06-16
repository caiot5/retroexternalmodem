# 🛠 RetroExternalModem

[![The RetroExternalModem](https://icq.byte5.com.br/modem1.jpeg)](https://icq.byte5.com.br/modem1.jpeg)
[![The RetroExternalModem](https://icq.byte5.com.br/modem2.jpeg)](https://icq.byte5.com.br/modem2.jpeg)

## Setup Guide

## Component Shopping List

- A Raspberry Pi 3 (B or B+)  
  *Note: It can work with older and newer models (or even with other SBCs) but might require advanced knowledge to modify both the scripts and the 3d-printed case to match the size.*
- A MAX3232 circuit board ([reference link](https://produto.mercadolivre.com.br/MLB-3444562089-2-x-modulo-db9-conversor-max232-rs232-ttl-serial-nf-_JM?quantity=1))
  *P.S: The MAX3232 doesn't support HW Flow control, so make sure you disable it at your OS.*
- A Serial Straight Through Male/Female cable [can also work with usb-serial adapters AND THEY SUPPORT HW FLOW CONTROL but go with the max3232 if you want to use the 3d-printed-case] ([reference link](https://produto.mercadolivre.com.br/MLB-3857304740-cabo-rs232-macho-x-femea-db9-13m-cor-branco-_JM?searchVariation=179787273503&highlight=false&pdp_filters=SHIPPING_ORIGIN%3A10215068&headerTopBrand=false#polycard_client=search-nordic&searchVariation=179787273503&position=17&search_layout=stack&type=item&tracking_id=c063ba76-1738-4dab-bc9f-f146cad59850))
- Some leds (required if using the 3d-printed case) ([reference link](https://produto.mercadolivre.com.br/MLB-1990525341-50x-led-retangular-vermelho-2x5x7mm-transparente-alto-brilho-_JM?searchVariation=95405518672#polycard_client=bookmarks))
- Some 1k resistors (required if using leds) ([reference link](https://www.mercadolivre.com.br/resistor-1k-cr25-14w-5-pacote-com-100-pecas/p/MLB27774191?pdp_filters=item_id:MLB3489620871))
- A power switch (required if using the 3d-printed case) ([reference link](https://produto.mercadolivre.com.br/MLB-3398695253-10-pecas-mini-chave-gangorra-branca-kcd11-101-ligadesliga-_JM))
- A DC Power Jack (required if using the 3d-printed case) ([reference link](https://produto.mercadolivre.com.br/MLB-2060922461-10-conector-dc-jack-pino-painel-com-rosca-_JM))
- An sound amplifier (optional because you can use the amplified p2 line out instead but required if using the GPIO PCM headers, please note that the autoinstall script will provision the raspberry to be used with the GPIO headers and not the amplified p2) ([reference link](https://produto.mercadolivre.com.br/MLB-1398675192-3x-modulo-amplificador-som-estereo-pam8403-2-canais-3w-8403-_JM))
- Some jumper cables (required if using the 3d-printed case) ([reference link](https://www.mercadolivre.com.br/kit-fio-jumper-fmea-fmea-20cm-com-40-unidades-1x40-arduino/p/MLB27769864?pdp_filters=item_id:MLB3782138963))
- A 50k ohms potentiometer (optional if you want to control the speaker gain) ([reference link](https://produto.mercadolivre.com.br/MLB-5411707582-10-pecas-potencimetro-linear-duplo-l20-50k-6t-wh148-2-_JM#polycard_client=search-nordic&position=6&search_layout=grid&type=item&tracking_id=ef183e19-3d57-4cec-895d-d00b7d9faba8&wid=MLB5411707582&sid=search))
- A 36mm 4ohms 2w Mini PC Speaker or a Polyphonic Buzzer ([reference link](https://produto.mercadolivre.com.br/MLB-2153455725-alto-falante-36mm-4-ohms-2w-cone-plastico-_JM))
- A V8 micro usb connector (required if using the 3d-printed case) ([reference link](https://produto.mercadolivre.com.br/MLB-2626229031-kit-com-10pcs-conector-micro-usb-macho-v8-solda-_JM?quantity=1))
- A 5V 3A p4 power supply (required to keep the aesthetic of the 3d-printed case) ([reference link](https://produto.mercadolivre.com.br/MLB-1680809250-fonte-chaveada-5v-3a-amperagem-real-plug-p4-55x21-_JM))
- A Phenolic Sheet Board (optional) ([reference link]( FOLHETE-ilhada-28x129-cm-pcb-perfurada-padro-_JM#is_advertising=true&backend_model=search-backend&position=10&search_layout=grid&type=pad&tracking_id=7fde8bf7-4c40-444b-8c78-eb38af4617c8&is_advertising=true&ad_domain=VQCATCORE_LST&ad_position=10&ad_click_id=Nzc4MWExNmUtM2IzNy00NTcyLWIzNjgtMzVlODdlYTIxNmJk))

## Table of Contents

- [1. Prepare the Raspberry Pi OS](#prepare-rpi-os)
- [2. Raspberry Pi Imager OS Selection](#flash-os)
- [3. Configure Wi-Fi & SSH](#configure-wifi-ssh)
- [4. Boot the Raspberry Pi](#boot-pi)
- [5. SSH Access](#ssh-access)
- [Auto Setup (Easy)](#auto-setup)
- [Manual Setup (Advanced)](#manual-setup)
- [6. System Configuration](#system-config)
- [7. Software Installation](#software-install)
- [8. Project Setup](#project-setup)
- [9. Network Configuration](#network-config)
- [10. Configure PPP Options](#ppp-options)
- [11. Running the Services](#run-services)
- [12. Add Blinky Lights](#blinky-lights)
- [13. Upgrade or Uninstall](#uninstall)
- [14. Modem Settings (Baud Rate, Phone Number and Wi-Fi)](#settings)
- [15. License & Acknowledgments](#license)

## 1. Prepare the Raspberry Pi OS

1. **Download Raspberry Pi Imager**  
   [Official Raspberry Pi Imager](https://www.raspberrypi.com/software/)
2. **Install & Launch**  
   Follow your OS installer prompts, then run “Raspberry Pi Imager.”

## 2. Raspberry Pi Imager OS Selection

[![The Raspberry Pi Imager](https://icq.byte5.com.br/rpi-imager.png)](https://icq.byte5.com.br/rpi-imager.png)

1. **Choose Device:** Click *CHOOSE DEVICE* → *Select your specific RPi model (if you're going for the recommended it's the Raspberry Pi 3b(+)*
2. **Choose OS:** Click *CHOOSE OS* → *Select Raspberry Pi OS (other)* → *Select Raspberry Pi OS Lite (64-bit) [or 32-bit if you're going with an older RPi model]*  
   [![Raspbian Other OS](https://icq.byte5.com.br/imager-other-os.png)](https://icq.byte5.com.br/imager-other-os.png)  
   [![Raspbian Lite](https://icq.byte5.com.br/imager-raspbian-lite.png)](https://icq.byte5.com.br/imager-raspbian-lite.png)
3. **Choose Storage:** Click *CHOOSE STORAGE* and select your SD/USB device.

## 3. Configure Wi-Fi and Enable SSH

Press `Ctrl + Shift + X` to open Advanced Options

**General TAB**

1. **Hostname:** e.g. `RAS`
2. **Set Username/Password:** Enter desired credentials. (you **WILL** use those credentials to connect to your dial-up server later)
3. **Wireless LAN:** Enter SSID, password, and country.  
   (if wifi fails, run sudo raspi-config and verify locale)
4. **Locale, VNC, etc. (Optional)**  
   [![Advanced Options](https://icq.byte5.com.br/advanced-options.png)](https://icq.byte5.com.br/advanced-options.png)

(if [the wifi is] not working afterwards please sudo raspi-config and make sure you select the correct locale, also **DO NOT USE HIDDEN SSID**)

**Services TAB**

1. **Enable SSH:** Check — use password auth.
2. **Save** and then **Write** the image.  
   [![SSH login example](https://icq.byte5.com.br/imager-ssh.png)](https://icq.byte5.com.br/imager-ssh.png)

The Raspberry Pi Imager will ask if you want to apply your customizations to the OS, please make sure you select 'Yes' and then 'Yes' again to format your SD and copy the image  
[![Raspbian Customization](https://icq.byte5.com.br/imager-customization.png)](https://icq.byte5.com.br/imager-customization.png)

## 4. Boot the Raspberry Pi

1. Insert the flashed card & power on.
2. Wait ~2 minutes for first-boot setup

## 5. SSH Access

1. Find Pi’s IP via your router or `ping <hostname>.local`. (in my case it would be: `ping RAS.local`)
2. SSH in:  
   ```
   ssh <username>@<pi_ip>
   ```

## Auto Setup (Easy)

Now you've got two options, the auto setup (easy) way and the manual setup (harder) way  
If you're going for the auto setup you just got to do this single line solution:

```
sudo wget "http://icq.byte5.com.br/setup.sh" && sudo chmod a+x setup.sh && sudo ./setup.sh
```

Answer 'Yes' to IPv4/IPv6 prompts  
[![iptables rules prompt](https://icq.byte5.com.br/ipv4-rules.jpeg)](https://icq.byte5.com.br/ipv4-rules.jpeg)

The auto setup ends here and you're good to go, add a generic (standard) modem to 38400 baud rate **WITHOUT HARDWARE FLOW CONTROL**  
and either dial (PPP) to 2242525 to use the internet (remember: **you WILL need to use your login and password credentials from raspberry to authenticate the dial-up)**  
or dial via Hyper Terminal (or such) using ATDTyour.bbs.com:port or dial ATDT3372234 to Luiz Pacheco's micronet BBS ;)  
But if for some reason you wanted to do the manual setup, follow the next detailed steps:

## Manual Setup (Advanced)

Use the steps below for granular control.

## 6. System Configuration

### 6.1 Edit GPIO Overlay for PWM (speakers) and enable UART (while disabling bluetooth)

```
sudo nano /boot/firmware/config.txt

# this first line is kind of optional because you can use the p2 amplified output anyway, but we're going to use an external amplifier wired to GPIO
# add at end:
dtoverlay=pwm-2chan,pin=18,func=2,pin2=13,func2=4

# now these settings are to make sure we get the "good" UART ttyAMA0 so it would work as it should.
dtoverlay=disable-bt
dtoverlay=pi3-disable-bt
enable_uart=1
```

### 6.2 Enable IP Forwarding

```
sudo sh -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'

# to make it persistent:
sudo nano /etc/sysctl.conf  

# uncomment net.ipv4.ip_forward=1
sudo sysctl -p
```

### 6.3 Remove the TTY console serial output

```
sudo nano /boot/firmware/cmdline.txt

# remove the console=serial0,115200 so for the console=argument will remain only as console=tty1 (and the other settings unchanged).
```

## 7. Software Installation

```
sudo apt update && sudo apt upgrade -y
sudo apt install -y pptp-linux iptables git build-essential python3
```

## 8. Project Setup

1. **Clone and Link**  
```
cd ~/
git clone https://github.com/caiot5/RetroExternalModem.git

# make sure you create a symlink for it in /WiFi2DialUp THIS IS MANDATORY!
sudo ln -s ~/RetroExternalModem/ /WiFi2DialUp

cd RetroExternalModem
```
2. **Unpack tcpser:**  
```
tar -zxvf tcpser.tar.gz
```
3. **Compile tcpser:**  
```
cd tcpser

# remove pre-compiled tcpser binary
rm tcpser

# compile
make

# make the start and settings scripts executable
chmod a+x start.sh
chmod a+x settings.sh
```

## 9. Network Configuration

```
sudo iptables -t nat -A POSTROUTING -s 172.16.0.0/12 -j MASQUERADE
sudo apt install -y iptables-persistent
sudo sh -c 'iptables-save > /etc/iptables/rules.v4'
```

## 10. Configure PPP Options

```
sudo cp ~/RetroExternalModem/options /etc/ppp/options
```

## 11. Running the Services

1. **Enable tcpser & wrapper services**  
   Move unit files and enable them:  
```
cd ~/RetroExternalModem/
sudo mv tcpser.service pppd-wrapper.service /etc/systemd/system/
sudo systemctl daemon-reload 
sudo systemctl enable tcpser 
sudo systemctl enable pppd-wrapper
```

## 12. Add Blinky Lights (optional)

To add visual indicators using LEDs on your Raspberry Pi, follow these steps:

```
# get the required files
wget "http://ftp.podsix.org/pub/pimodem/LED.py"
wget "http://ftp.podsix.org/pub/pimodem/set_leds.sh"
wget "http://ftp.podsix.org/pub/pimodem/set_leds.service"

# move the files to the /usr/local/bin
sudo mv LED.py set_leds.sh /usr/local/bin

# give the permissions to the scripts
sudo chmod +x /usr/local/bin/LED.py /usr/local/bin/set_leds.sh

# enable the leds as a service
sudo mv set_leds.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable set_leds
sudo systemctl start set_leds
```

### Optional: 3D Case & LED Schematic

- **3D Printed Case:**  
  You can download a printable case for the RetroExternalModem at:  
  [Luiz Pacheco's Sportster 3D Case](https://www.thingiverse.com/thing:7063155)  
  Print it using standard PLA settings. Designed for RPi 3B+ and standard GPIO header spacing.
- **LED, UART (MAX3232) and Speaker/Amplifier Wiring Schematic:**
  [![Wiring Schematics](https://icq.byte5.com.br/schematic.png)](https://icq.byte5.com.br/schematic.png)

## 13. Upgrade or Uninstall

If you need to uninstall or upgrade this project, get and run the uninstaller script:

```
sudo wget "http://icq.byte5.com.br/uninstaller.sh" && sudo chmod a+x uninstaller.sh && sudo ./uninstaller.sh
```

Then, to install again (to upgrade) just download and run the latest setup script:

```
sudo wget "http://icq.byte5.com.br/setup.sh" && sudo chmod a+x setup.sh && sudo ./setup.sh
```

## 14. Modem Settings (Wi-Fi, BAUD and phone number)

You can connect to your RetroExternalModem via HyperTerminal and use AT commands to configure the modem settings  
**BAUD RATE:**

```
Use the command ATC BAUD,(BAUD)
For instance: ATC BAUD,9600
```

**Phone Number:**

```
Use the command ATC TEL,(PHONE)
For instance: ATC TEL,2242525
```

**WIFI Settings:**

```
Use the command ATC WIFI,(SSID),(PASSWORD)
For instance: ATC WIFI,MyNetwork,MyPass123
```

**Show current settings:**

```
Use the command ATJ (based on Luis Miguel's ATI approach)
```

## 15. License & Acknowledgments

Licensed under GPLv3. Thanks to all contributors & the open-source community for [RetroExternalModem](https://github.com/caiot5/RetroExternalModem) and related tools.

**First of all I would like to thank my friend Luiz Pacheco for all the encouragement and feedback (also for electronic schematics).**  
The Sportster (RetroExternalModem) Case has been modeled **all by him and only him alone**, make sure you get the stl and print yourself, mate ;)  
- [Luiz Pacheco's Sportster 3D Case](https://www.thingiverse.com/thing:7063155)

**Special thanks to Luis Miguel Silva** for his extensive technical contributions. His work laid the foundation for much (almost all) of this project. Explore his insights and projects:  
- [WiFi2DialUp Progress Update](https://mygpslostitself.blogspot.com/2017/08/wifi2dialup-progress-update.html)  
- [Raspberry Pi Zero W Serial Modem](https://mygpslostitself.blogspot.com/2017/07/raspberry-pi-zero-w-serial-modem.html)  
- [TrashPandamonium YouTube Channel](https://www.youtube.com/@TrashPandamonium)

**Also very special thanks to Jim Brain (original author of tcpser which has been later modified by FozzTexx and Luis Miguel Silva)**  
- [Jim Brain's Linux Serial Resources](http://www.jbrain.com/pub/linux/serial/)  
- [FozzTexx/tcpser (modified tcpser)](https://github.com/FozzTexx/tcpser)

**The TR and CD lights are inspired by this PodSix article**  
- [PodSix PiModem Article](http://podsix.org/articles/pimodem/)

**Additional references and inspirations:**  
- [Putting Your Retro Computer on the Line](http://www.insentricity.com/a.cl/215/putting-your-retro-computer-on-the-line)  
- [mholling/rpirtscts (if you want to add hardware flow control to your project)](https://github.com/mholling/rpirtscts)

---
