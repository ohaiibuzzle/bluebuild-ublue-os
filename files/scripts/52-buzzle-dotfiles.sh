#!/usr/bin/bash

set -eoux pipefail

cd /tmp

# Xiaomi MiSans typeface
git clone https://github.com/dsrkafuu/misans.git misans
mkdir -p /usr/share/fonts/MiSans
cp misans/raw/Normal/ttf/* /usr/share/fonts/MiSans
fc-cache -f /usr/share/fonts/MiSans

cd /tmp && rm -rf misans

# Plymouth
git clone https://github.com/ohaiibuzzle/Plymouth-SimulatedUniverse.git plymouth
cp -r plymouth/SimulatedUniverse-4k /usr/share/plymouth/themes/SimulatedUniverse
plymouth-set-default-theme SimulatedUniverse
rm -rf plymouth

# sddm
mkdir sddm && cd sddm
curl -L -o catppuccin.zip https://github.com/catppuccin/sddm/releases/download/v1.0.0/catppuccin-mocha.zip
unzip catppuccin.zip
mv catppuccin-mocha /usr/share/sddm/themes
cd /tmp && rm -rf sddm