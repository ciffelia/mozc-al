FROM amazonlinux:2 as mozc-builder

# Install build dependencies
RUN yum install -y \
    # This package includes `adduser` command.
    shadow-utils \
    # `patch` command
    patch \
    # Build tools
    # Using GCC instead of Clang, because it seems to be difficult to setup Clang and libstdc++/libc++ on Amazon Linux 2.
    # We need to install `gcc10` package instead of legacy `gcc` package, because Mozc uses latest features of C++.
    gcc10 gcc10-c++ \
    # Mozc build script needs Python 3 and six
    python3 python3-six \
    # Bazel needs `which` to find Python executable
    which \
    # Dependencies of Linux desktop version of Mozc
    qt5-qtbase-devel ibus-devel && \
    rm -rf /var/cache/yum && \
    yum clean all

# Set environment variables for GCC
ENV CC=gcc10-gcc CXX=gcc10-g++

# Setup symlinks for Qt compilers
RUN ln -s /usr/bin/moc-qt5 /usr/bin/moc && \
    ln -s /usr/bin/rcc-qt5 /usr/bin/rcc && \
    ln -s /usr/bin/uic-qt5 /usr/bin/uic

# Switch to non-root user
RUN adduser --create-home mozc_builder
USER mozc_builder
WORKDIR /home/mozc_builder

# Setup user bin directory
RUN mkdir ~/bin
ENV PATH=$PATH:/home/mozc_builder/bin

# Install Bazel
RUN curl -Lo ~/bin/bazel https://github.com/bazelbuild/bazel/releases/download/4.2.1/bazel-4.2.1-linux-x86_64 && \
    chmod +x ~/bin/bazel

# Copy Mozc source and patch
COPY --chown=mozc_builder:mozc_builder ./mozc ./mozc
COPY --chown=mozc_builder:mozc_builder ./mozc.patch ./mozc.patch

# Apply Mozc patch
RUN patch -p1 --directory=./mozc < ./mozc.patch

# Build Mozc for Linux
WORKDIR /home/mozc_builder/mozc/src
RUN bazel build package --config oss_linux -c opt

#####

FROM amazonlinux:2 as rpm-builder

# Install build dependencies
RUN yum install -y \
    # This package includes `adduser` command.
    shadow-utils \
    # Packages to build RPM package
    rpm-build && \
    rm -rf /var/cache/yum && \
    yum clean all

# Switch to non-root user
RUN adduser --create-home rpm_builder
USER rpm_builder
WORKDIR /home/rpm_builder/rpmbuild

RUN mkdir -p ~/rpmbuild/{SOURCES,SPECS}
WORKDIR /home/rpm_builder/rpmbuild

# Copy RPM spec
COPY --chown=rpm_builder:rpm_builder ./mozc.spec ./SPECS/

# Copy IBus config
COPY --chown=rpm_builder:rpm_builder ./mozc.xml ./SOURCES/

# Copy Mozc binaries
COPY --from=mozc-builder --chown=rpm_builder:rpm_builder \
     /home/mozc_builder/mozc/src/bazel-bin/server/mozc_server \
     /home/mozc_builder/mozc/src/bazel-bin/gui/tool/mozc_tool \
     /home/mozc_builder/mozc/src/bazel-bin/renderer/mozc_renderer \
     /home/mozc_builder/mozc/src/bazel-bin/unix/ibus/ibus_mozc \
     /home/mozc_builder/mozc/src/bazel-bin/unix/emacs/mozc_emacs_helper \
     /home/mozc_builder/mozc/src/data/images/product_icon_32bpp-128.png \
     ./SOURCES/

# Build RPM package
RUN rpmbuild -bb ./SPECS/mozc.spec
