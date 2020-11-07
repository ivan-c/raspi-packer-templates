
Raspberry Pi 4 Packer Templates
===============================
Packer templates for building Raspberry Pi system images


Usage
-----
To build a debian disk image (`output-qemu/debian-arm64`), invoke packer as follows:

    packer build debian-arm64.json

Download
--------
Images are built by GitHub Actions with every commit. To download the image from a job, navigate to [Actions](https://github.com/ivan-c/packer-templates/actions), select the latest job and click the desired image in the Artifacts section.

License
-------
BSD
