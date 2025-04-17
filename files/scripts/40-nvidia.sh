#!/bin/bash

mkdir /tmp/akmods-rpms
skopeo copy --retry-times 3 docker://ghcr.io/ublue-os/akmods-nvidia:main-"$(rpm -E %fedora)" dir:/tmp/akmods-rpms
NVIDIA_TARGZ=$(jq -r '.layers[].digest' </tmp/akmods-rpms/manifest.json | cut -d : -f 2)
tar -xvzf /tmp/akmods-rpms/"$NVIDIA_TARGZ" -C /tmp/
mv /tmp/rpms/* /tmp/akmods-rpms/

# Install Nvidia RPMs
curl -Lo /tmp/nvidia-install.sh https://raw.githubusercontent.com/ublue-os/hwe/main/nvidia-install.sh # Change when nvidia-install.sh updates
chmod +x /tmp/nvidia-install.sh
IMAGE_NAME="main" RPMFUSION_MIRROR="" /tmp/nvidia-install.sh
rm -f /usr/share/vulkan/icd.d/nouveau_icd.*.json
ln -sf libnvidia-ml.so.1 /usr/lib64/libnvidia-ml.so
rm -rf /tmp/akmods-rpms