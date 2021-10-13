# This file was copied from https://github.com/google/mozc/blob/aa48b23dcf92ea1d85d8e8dbca8c0a0c37e159f8/docker/ubuntu20.04/Dockerfile
# and modified by Ciffelia.

# Copyright 2010-2020, Google Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#     * Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
# copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the
# distribution.
#     * Neither the name of Google Inc. nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

FROM buildpack-deps:20.04 as mozc-builder

# Add Bazel repository
# https://docs.bazel.build/versions/master/install-ubuntu.html
RUN curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > /etc/apt/trusted.gpg.d/bazel.gpg && \
    echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" > /etc/apt/sources.list.d/bazel.list

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # Common packages for linux build environment
    clang libc++-dev libc++abi-dev python python-six pkg-config \
    # Packages for linux desktop version
    libibus-1.0-dev qtbase5-dev libgtk2.0-dev libxcb-xfixes0-dev \
    # Packages for Bazel
    bazel && \
    rm -rf /var/lib/apt/lists/*

# Switch to non-root user
RUN useradd --create-home mozc_builder
USER mozc_builder
WORKDIR /home/mozc_builder

# Copy mozc source
COPY --chown=mozc_builder:mozc_builder ./mozc ./mozc

# Build mozc for Linux
WORKDIR /home/mozc_builder/mozc/src
RUN bazel build package --config oss_linux -c opt

###

FROM amazonlinux:2 as rpm-builder

# Install build dependencies
RUN yum install -y shadow-utils rpm-build && \
    rm -rf /var/cache/yum && \
    yum clean all

# Switch to non-root user
RUN adduser --create-home rpm_builder
USER rpm_builder
WORKDIR /home/rpm_builder/rpmbuild

# Copy mozc binaries
COPY --from=mozc-builder --chown=rpm_builder:rpm_builder \
     /home/mozc_builder/mozc/src/bazel-bin/server/mozc_server \
     /home/mozc_builder/mozc/src/bazel-bin/gui/tool/mozc_tool \
     /home/mozc_builder/mozc/src/bazel-bin/renderer/mozc_renderer \
     /home/mozc_builder/mozc/src/bazel-bin/unix/ibus/ibus_mozc \
     /home/mozc_builder/mozc/src/bazel-bin/unix/emacs/mozc_emacs_helper \
     /home/mozc_builder/mozc/src/data/images/product_icon_32bpp-128.png \
     ./SOURCES/

# Copy xml file for iBus
COPY --chown=rpm_builder:rpm_builder ./mozc.xml ./SOURCES/

# Copy rpm spec file
COPY --chown=rpm_builder:rpm_builder ./mozc.spec ./SPECS/

RUN rpmbuild -bb SPECS/mozc.spec
