
# Raspberry Pi Packer Templates

[![Packer Image 📦](https://github.com/ivan-c/raspi-packer-templates/workflows/%F0%9F%93%A6%20Build%20Packer%20Images/badge.svg)](https://github.com/ivan-c/raspi-packer-templates/actions?query=workflow%3A%22%F0%9F%93%A6+Build+Packer+Images%22)

Packer templates for building Raspberry Pi system images

Uses packer [`qemu` builder](https://www.packer.io/docs/builders/qemu) and [`ansible-local` provisioner](https://www.packer.io/docs/provisioners/ansible-local) to build system images for the raspberry pi

---
**NOTE**

At the moment only the Raspberry Pi 3B+ and 4B are supported, and system images are pre-installed with kubernetes bootstrapping tools (`kubeadm`)

---

## Usage
To build a debian disk image, invoke packer as follows:

    packer build debian-arm64.json

After a successful run, the system image will be saved in `output-qemu/debian-arm64`


By default, a system image for the Raspberry Pi 4B is generated. To build a system image for the Raspberry Pi 3B+, invoke packer as follows:

    packer build -var rpi_hardware_version=3 debian-arm64.json

## Download
Images are built by GitHub Actions with every commit. To download the image from a job, navigate to [Actions](https://github.com/ivan-c/packer-templates/actions), select the latest job and click the desired image in the Artifacts section.

## License
BSD
