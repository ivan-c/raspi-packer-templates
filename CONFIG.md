# Configuration
[User Variables](https://www.packer.io/docs/templates/legacy_json_templates/user-variables) can be overridden invidiually by passing `-var 'key=value'` or passing a JSON file via `-var-file=path`.

## Packer Overrides
User Variables for overriding existing Packer values

### `vm_name`
VM name to pass to qemu. See [`vm_name`](https://www.packer.io/docs/builders/qemu#vm_name)

### `iso_url`
URL of disc image to boot. See [`iso_url`](https://www.packer.io/docs/builders/qemu#iso_url)

### `iso_checksum`
URL of checksum file associated with `iso_url`. See [`iso_checksum`](https://www.packer.io/docs/builders/qemu#iso_checksum)

### `ssh_username`
Username for default account. See [`ssh_username`](https://www.packer.io/docs/builders/qemu#ssh_username)

### `ssh_password`
Password for default account. See [`ssh_password`](https://www.packer.io/docs/builders/qemu#ssh_password)

### `ssh_timeout`
Max time to wait for ssh to become available before failing. See [`ssh_timeout`](https://www.packer.io/docs/builders/qemu#ssh_timeout)

### `output_directory`
Directory to save VM disk image to. Can be used to build on top of a ramdisk for significant decrease in build time, eg `/dev/shm/packer`. See [`output_directory`](https://www.packer.io/docs/builders/qemu#output_directory)

### `disk_size`
Size of VM disk image. See [`disk_size`](https://www.packer.io/docs/builders/qemu#disk_size)

## Provisioning Overrides
Custom User Variables not used to override Packer provisioning settings

### `local_cache`
Set to `true` to cache packages between packer builds. Requires `sshpass` installed on system running packer.

### `ansible_version`
Version of ansible to install and use during provisioning.

### `rpi_firmware_version`
Raspberry Pi firmware version to install.

### `rpi_hardware_version`
Raspberry Pi hardware version to target for build.

### `extra_env_vars`
Extra environment variables to pass to shell provisioning scripts. Can be used to configure a caching HTTP proxy, eg `http_proxy=http://squid.local:8000`.

### `extra_ansible_vars`
Extra ansible variables to pass to ansible provisioning playbooks. Can be used to configure a caching HTTP proxy, eg `http_proxy=http://squid.local:8000`.

### `extra_boot_args`
Extra arguments to pass to kernel when booting. Can be used to configure a caching HTTP proxy, eg `mirror/http/proxy=http://squid.local:8000`.
