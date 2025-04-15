# rpi-os-demo
Demo OS images with Forklift integration layered over Raspberry Pi OS


## Pallet

This OS image deploys the following pallet:
[github.com/openUC2/pallet](https://github.com/openUC2/pallet)

## Development

The entrypoint for the OS setup process is [`setup.sh`](./setup.sh). To add more steps to the OS
setup process, add those steps to that file. You can refer to the [`tools` step](./tools/install.sh)
for an example of installing packages with APT. You can refer to the
[`forklift` step](./forklift/install.sh) for an example of copying files from this repo into the OS
image. However, in general you should only directly copy files into the OS image if they're needed
during early boot before forklift runs; otherwise, you should deploy those files via
[github.com/openUC2/pallet](https://github.com/openUC2/pallet) (for an example of how to do this,
refer to [PR openUC2/pallet#7](https://github.com/openUC2/pallet/pull/7)).
