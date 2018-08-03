FROM ubuntu
MAINTAINER Kishore Kadiyala <kishore.kadiyala@intel.com>
LABEL Version="0.0.1"

# Set proxy
#ENV http_proxy xxxx
#ENV https_proxy xxxx

# Make ssh dir
RUN mkdir /root/.ssh/

# Copy over private key, and set permissions
ADD id_rsa /root/.ssh/id_rsa

#Create known_hosts
RUN touch /root/.ssh/known_hosts

RUN apt-get update && \ 
    apt-get -y --quiet install \
	automake \
	autoconf \
	libtool \
	xutils-dev \
	libpciaccess-dev \
	python-mako \
	bison \
	flex \
	libomxil-bellagio-dev \
	libexpat1-dev \
	llvm-dev \
#	gcc-4.9 \
#	g++-4.9 \
	python3 \
	python3-pip \
	libudev-dev \
	libmtdev-dev \
	mtdev-tools \
	libevdev-dev \
	libx11-xcb-dev \
	libxkbcommon-dev \
	libxrandr-dev \
	x11proto-*-dev \
	libxcb* \
	libxdamage* \
	libxext-dev \
	libxshmfence-dev \
	libwacom-dev \
	libgtk-3-dev \
	check \
	libpam0g-dev \
	clang-format-4.0 \
#	cppcheck/trusty-backports \
	zlib1g-dev \
	libx11-dev \
	libncurses5-dev \
	libelf-dev \
	libglib2.0-dev \
	git \
	cmake \
	build-essential \
	libircclient-dev \
	libwayland-dev \
	libudev-dev \
	libmtdev-dev \
	libevdev-dev \
	libwacom-dev \
	libinput-dev \
	libxml2-dev

RUN pip3 install meson==0.43.0 \
	ninja \
	pathlib

#Set env

ENV WLD=/root/wl-install
ENV LD_LIBRARY_PATH=$WLD/lib
ENV PKG_CONFIG_PATH=$WLD/lib/pkgconfig/:$WLD/share/pkgconfig/
ENV PATH=$WLD/bin:$PATH
ENV ACLOCAL_PATH=$WLD/share/aclocal
ENV ACLOCAL="aclocal -I $ACLOCAL_PATH"
RUN mkdir -p $WLD/share/aclocal 

#Create a workspace
RUN mkdir /root/workspace

#clone latest DRM
RUN git clone https://github.com/projectceladon/external-libdrm.git /root/workspace/libdrm
WORKDIR /root/workspace/libdrm
RUN ./autogen.sh --disable-radeon --disable-nouveau --disable-amdgpu --enable-udev --enable-libkms --prefix=$WLD
RUN make && make install
WORKDIR /

#clone latest Wayland
RUN git clone https://anongit.freedesktop.org/git/wayland/wayland.git /root/workspace/wayland
WORKDIR /root/workspace/wayland
RUN ./autogen.sh --prefix=$WLD  --disable-documentation
RUN make && make install
WORKDIR /

#clone latest Wayland-protocols
RUN git clone https://anongit.freedesktop.org/git/wayland/wayland-protocols.git /root/workspace/wayland-protocols
WORKDIR /root/workspace/wayland-protocols
RUN ./autogen.sh --prefix=$WLD
RUN make install
WORKDIR /

#clone latest libunwind
RUN git clone  https://github.com/libunwind/libunwind /root/workspace/libunwind
WORKDIR /root/workspace/libunwind
RUN ./autogen.sh --prefix=$WLD
RUN make && make install
WORKDIR /


#clone latest libinput
RUN git clone https://anongit.freedesktop.org/git/wayland/libinput.git /root/workspace/libinput
WORKDIR /root/workspace/libinput
RUN mkdir  ./builddir
RUN meson --prefix=$WLD -Dlibwacom=false -Ddocumentation=false -Ddebug-gui=false -Dtests=false builddir/
RUN ninja -C builddir/
RUN ninja -C builddir/ install
WORKDIR /



#clone latest MESA
RUN git clone https://github.com/intel/external-mesa.git /root/workspace/mesa
WORKDIR /root/workspace/mesa
RUN ./autogen.sh --prefix=$WLD --with-platforms=surfaceless,drm,wayland,x11 --disable-dri3 --enable-shared-glapi --disable-glx --disable-glx-tls --enable-gbm --without-gallium-drivers --with-dri-drivers=i965
RUN make install
WORKDIR /

#clone latest libva
RUN git clone https://github.com/intel/libva.git /root/workspace/libva
WORKDIR /root/workspace/libva
RUN ./autogen.sh --prefix=$WLD
RUN make -j5 && make install
WORKDIR /

# clone latest IAHWC
RUN git clone https://github.com/intel/IA-Hardware-Composer.git /root/workspace/iahwc
WORKDIR /root/workspace/iahwc
RUN ./autogen.sh --prefix=$WLD --enable-gbm --enable-linux-frontend
RUN make install
WORKDIR /

# clone latest Weston
RUN git clone -b iahwc-plugin https://github.com/intel/external-weston.git /root/workspace/weston
WORKDIR /root/workspace/weston
RUN ./autogen.sh --prefix=$WLD $AUTOGEN_CMDLINE --enable-iahwc-compositor --disable-wayland-compositor --disable-rdp-compositor \
    --disable-headless-compositor --disable-x11-compositor --disable-fbdev-compositor \
    --disable-drm-compositor WESTON_NATIVE_BACKEND="iahwc-backend.so"
RUN make install
WORKDIR /
