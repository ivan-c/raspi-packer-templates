
Raspberry Pi Packer Templates
=============================
Packer templates for building Raspberry Pi system images

Uses packer [`qemu` builder](https://www.packer.io/docs/builders/qemu) and [`ansible-local` provisioner](https://www.packer.io/docs/provisioners/ansible-local) to build system images for the raspberry pi

---
**NOTE**

At the moment only the Raspberry Pi 4B is supported, and system images are pre-installed with kubernetes bootstrapping tools (`kubeadm`)

---

Usage
-----
To build a debian disk image, invoke packer as follows:

    packer build debian-arm64.json

After a successful run, the system image will be saved in `output-qemu/debian-arm64`

Download
--------
Images are built by GitHub Actions with every commit. To download the image from a job, navigate to [Actions](https://github.com/ivan-c/packer-templates/actions), select the latest job and click the desired image in the Artifacts section.

License
-------
BSD
