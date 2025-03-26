#!/usr/bin/bash

set -eoux pipefail

cd /tmp

git clone https://github.com/ohaiibuzzle/dotfiles.git dotfiles

# skel configs
mkdir -p /etc/skel/.config/{hypr,wofi}
mkdir -p /etc/xdg/waybar
mkdir -p /usr/share/fonts/MiSans

# copy configs over
cp dotfiles/hypr/hypr{land,lock,idle}.conf /etc/skel/.config/hypr/
cp -rf dotfiles/waybar/* /etc/xdg/waybar/
cp -f dotfiles/wofi/* /etc/skel/.config/wofi/
rm -rf dotfiles

# Xiaomi MiSans typeface
mkdir misans && cd misans
wget https://hyperos.mi.com/font-download/MiSans_Global_ALL.zip
unzip MiSans_Global_ALL.zip
cd 'MiSans Global _ALL'
unzip MiSans.zip
cd MiSans
cp ttf/* /usr/share/fonts/MiSans

fc-cache -f /usr/share/fonts/MiSans

cd /tmp && rm -rf misans

# Plymouth
git clone https://github.com/ohaiibuzzle/Plymouth-SimulatedUniverse.git plymouth
cp -r plymouth/SimulatedUniverse-4k /usr/share/plymouth/themes/SimulatedUniverse
plymouth-set-default-theme -R SimulatedUniverse
rm -rf plymouth

# sddm
mkdir sddm && cd sddm
wget -L -O catppuccin.zip https://github.com/catppuccin/sddm/releases/download/v1.0.0/catppuccin-mocha.zip
unzip catppuccin.zip
mv catppuccin-mocha /usr/share/sddm/themes
echo > /etc/sddm.conf << EOF
[Theme]
Current=catppuccin-mocha
Font=MiSans
EOF
cd /tmp && rm -rf sddm