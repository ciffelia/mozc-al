# mozc-al

[![CI Status](https://github.com/ciffelia/mozc-al/workflows/CI/badge.svg?branch=master)](https://github.com/ciffelia/mozc-al/actions?query=workflow%3ACI+branch%3Amaster)
[![BSD 3-Clause License](https://img.shields.io/badge/license-BSD%203--Clause-blue)](LICENSE)

A set of prebuilt Mozc binaries for Amazon Linux 2.

## Install

1. Download the prebuilt package from [the Release page](https://github.com/ciffelia/mozc-al/releases/latest).

1. Install the package.

   ```sh
   sudo yum install -y mozc-X.X.X-X.amzn2.x86_64.rpm
   ```

1. Run `ibus-setup` and add "Japanese - Mozc" in the Input Method tab.

## Build

1. Be sure to clone the repository with `--recursive` flag to include submodules.

   ```sh
   git clone --recursive https://github.com/ciffelia/mozc-al.git
   ```

1. `cd` to the cloned repository and run build command.

   ```sh
   cd mozc-al
   docker build -t mozc-builder .
   ```

1. Extract RPM package from the build image.

   ```sh
   id=$(docker create mozc-builder)
   docker cp $id:/home/rpm_builder/rpmbuild/RPMS ./RPMS
   docker rm $id
   ```
