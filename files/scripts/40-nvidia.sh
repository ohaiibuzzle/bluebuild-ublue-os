#!/bin/bash

set -euox pipefail

mkdir /tmp/akmods-nvidia /tmp/akmods-extract
skopeo copy --retry-times 3 docker://ghcr.io/ublue-os/akmods-nvidia:main-"$(rpm -E %fedora)" dir:/tmp/akmods-nvidia
NVIDIA_TARGZ=$(jq -r '.layers[].digest' </tmp/akmods-nvidia/manifest.json | cut -d : -f 2)
tar -xvzf /tmp/akmods-nvidia/"$NVIDIA_TARGZ" -C /tmp/akmods-extract

dnf5 -y remove --no-autoremove kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra
dnf5 -y install /tmp/akmods-extract/kernel-rpms/kernel*.rpm
dnf5 -y install /tmp/akmods-extract/rpms/ublue-os/ublue-os-nvidia*.rpm
dnf5 -y install /tmp/akmods-extract/rpms/kmods/kmod-nvidia*.rpm
rm -rf /tmp/akmods-nvidia /tmp/akmods-extract