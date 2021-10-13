# mozc-al

[![CI Status](https://github.com/ciffelia/mozc-al/workflows/CI/badge.svg?branch=master)](https://github.com/ciffelia/mozc-al/actions?query=workflow%3ACI+branch%3Amaster)
[![BSD 3-Clause License](https://img.shields.io/badge/license-BSD%203--Clause-blue)](LICENSE)

A set of prebuilt Mozc binaries for Amazon Linux 2.

## Install (Amazon WorkSpaces)

Not available (yet)

## Build

1. Be sure to clone the repository with `--recursive` flag to include submodules.

   ```sh
   git clone --recursive https://github.com/ciffelia/mozc-al.git
   ```

2. `cd` to the cloned repository and run build command.

   ```sh
   cd mozc-al
   docker build -t mozc-builder .
   ```

3. Extract RPM package from the build image.

   ```sh
   id = $(docker create mozc-builder)
   docker cp $id:/home/rpm_builder/rpmbuild/RPMS ./RPMS
   docker rm $id
   ```
