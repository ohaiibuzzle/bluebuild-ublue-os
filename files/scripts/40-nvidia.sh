#!/bin/bash

set -euox pipefail

mkdir /tmp/akmods-nvidia /tmp/akmods-extract
skopeo copy --retry-times 3 docker://ghcr.io/ublue-os/akmods-nvidia:main-"$(rpm -E %fedora)" dir:/tmp/akmods-nvidia
NVIDIA_TARGZ=$(jq -r '.layers[].digest' </tmp/akmods-nvidia/manifest.json | cut -d : -f 2)
tar -xvzf /tmp/akmods-nvidia/"$NVIDIA_TARGZ" -C /tmp/akmods-extract

dnf5 -y remove --no-autoremove kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra
dnf5 -y install /tmp/akmods-extract/kernel-rpms/kernel*.rpm
dnf5 -y install /tmp/akmods-extract/rpms/kmods/kmod-nvidia*.rpm
dnf5 -y install /tmp/akmods-extract/rpms/ublue-os/ublue-os*.rpm
dnf5 -y install libva-nvidia-driver

rm -rf /tmp/akmods-nvidia /tmp/akmods-extract

systemctl enable ublue-nvctk-cdi.service
semodule --verbose --install /usr/share/selinux/packages/nvidia-container.pp

cp /etc/modprobe.d/nvidia-modeset.conf /usr/lib/modprobe.d/nvidia-modeset.conf
sed -i 's@omit_drivers@force_drivers@g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf
sed -i 's@ nvidia @ i915 amdgpu nvidia @g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf

PKG="VK_hdr_layer"
TMPDIR="$(mktemp -d)"

dnf download "${PKG}" --destdir "$TMPDIR"

RPM_FILE=$(ls "$TMPDIR"/*.rpm)
mkdir "$TMPDIR/$PKG"
cd "$TMPDIR/$PKG"

# Extract RPM
rpm2cpio "$RPM_FILE" | cpio -idmv

# Libraries
mkdir -p /usr/lib64/${PKG}
cp -v usr/lib64/${PKG}/* /usr/lib64/${PKG}/

# Vulkan implicit layer
mkdir -p /usr/share/vulkan/implicit_layer.d
cp -v usr/share/vulkan/implicit_layer.d/VkLayer_hdr_wsi.*.json \
    /usr/share/vulkan/implicit_layer.d/

# License & Docs
mkdir -p /usr/share/licenses/${PKG}
cp -v usr/share/licenses/${PKG}/* /usr/share/licenses/${PKG}/
mkdir -p /usr/share/doc/${PKG}
cp -v usr/share/doc/${PKG}/* /usr/share/doc/${PKG}/