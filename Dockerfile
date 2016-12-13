FROM resin/armv7hf-debian-qemu

RUN [ "cross-build-start" ]

# build tools
RUN apt-get update && apt-get install -y \
	build-essential \
	cmake \
	pkg-config

# ccmake curses (make our life easier to select options for CMAKE)
RUN apt-get install -y \
	cmake-curses-gui


# Image format support:

# JPEG, TIFF, JPEG2000, PNG
RUN apt-get install -y \
	libjpeg-dev \
	libtiff5-dev \
	libjasper-dev \
	libpng12-dev

# GUI Framework:

# gtk GUI framework
RUN apt-get install -y \
	libgtk2.0-dev

# OpenGL extension to GTK (optional)
RUN apt-get install -y \
	libgtkglext1-dev

# Video Driver

# video4linux device driver for video capture
RUN apt-get install -y \
	libv4l-dev

# other optional v4l stuff
RUN apt-get install -y \
	libv4l-0 \
	v4l-utils

# AUDIO / VIDEO CODECS:
# ffmpeg libraries (optional but recommended)
RUN apt-get install -y \
	libavcodec-dev \
	libavformat-dev \
	libswscale-dev

# xvid and x264 codecs (optional)
RUN apt-get install -y \
	libxvidcore-dev \
	libx264-dev


# Build libjpeg-turbo
#By default libjpeg-turbo will install into /opt/libjpeg-turbo. You may install to a different directory by
# passing the --prefix option to the configure script.
# However, the remainder of these instructions will assume that libjpeg-turbo was installed in its default location.
RUN apt-get install -y \
	wget

RUN wget http://sourceforge.net/projects/libjpeg-turbo/files/1.3.0/libjpeg-turbo-1.3.0.tar.gz \
	&& tar xzvf libjpeg-turbo-1.3.0.tar.gz \
	&& cd libjpeg-turbo-1.3.0 \
	&& mkdir build \
	&& cd build \
	&& ../configure CPPFLAGS="-O3 -pipe -fPIC -mfpu=neon -mfloat-abi=hard" \
	&& make \
	&& make install

#RUN mkdir -p /usr/include/ffmpeg \
#	&& ln -s /usr/include/libavformat/* /usr/include/ffmpeg/ \
#	&& ln -s /usr/include/libavcodec/* /usr/include/ffmpeg/ \
#	&& ln -s /usr/include/libavresample/* /usr/include/ffmpeg/

# Audio MP3, AAC encoding codecs (optional)
#sudo apt-get install -y libmp3lame-dev libfaac-dev

# gstreamer (optional) multimedia framework
RUN apt-get install -y \
	libgstreamer0.10-0-dbg \
	libgstreamer0.10-0 \
	libgstreamer0.10-dev

# Theora video compression codec (optional, not recommended)
#sudo apt-get install -y libtheora-dev

# Vorbis General Audio Compression Codec (optional, not recommended)
#sudo apt-get install -y libvorbis-dev

# Speech CODECS	:
# Speech CODECs

# Adaptive Multi Rate codec (Wide band and Narrow band) (optional)
RUN apt-get install -y \
	libopencore-amrnb-dev \
	libopencore-amrwb-dev

# 1394 FireWire / iLink support:
# FireWire support (optional)
RUN apt-get install -y \
	libdc1394-22 \
	libdc1394-22-dev

# Optimizations:

# TBB Multi-core / multi-processor framework (optional but recommended)
RUN apt-get install -y \
	libtbb-dev

# ATLAS Automatically Tuned Linear Algebra Software; optimized version of BLAS and LAPACK
RUN apt-get install -y \
	libatlas-base-dev

# PThread
RUN apt-get install -y \
	libpthread-stubs0-dev \
	libevent-pthreads-2.0-5

# Python bindings
# python dev library
RUN apt-get install -y \
	python2.7-dev

# install -y PIP
RUN wget https://bootstrap.pypa.io/get-pip.py \
	&& python get-pip.py

# GNU Fortran compiler, used to optimize SciPy code
RUN apt-get install -y \
	gfortran

# Python bindings dependencies
RUN apt-get install -y \
	python-numpy \
	python-scipy \
	python-matplotlib

# python numpy already installed above ?!?
#RUN pip install numpy

# JAVA bindings
# jdk, ant for java support (optional)
#sudo apt-get install -y default-jdk ant

# Get OpenCV source and contrib:
# Download OpenCV 3.1.0 and unpack it
RUN apt-get install -y \
	unzip

RUN mkdir -p /home/code/ \
	&& cd /home/code/ \
	&& wget -O opencv.zip https://github.com/opencv/opencv/archive/3.1.0.zip \
	&& unzip opencv.zip \
	&& rm opencv.zip

# Contrib Libraries (Non-free Modules)

RUN cd /home/code/ \
	&& wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/3.1.0.zip \
	&& unzip opencv_contrib.zip \
	&& rm opencv_contrib.zip

# Create MAKEFILE:
# preparing the build

#cd ~/opencv-3.1.0/
RUN cd /home/code/ \
	&& mkdir build \
	&& cd build \
	&& cmake -D CMAKE_BUILD_TYPE=RELEASE \
	-D CMAKE_INSTALL_PREFIX=/usr/local \
	-D INSTALL_C_EXAMPLES=OFF \
	-D INSTALL_PYTHON_EXAMPLES=ON \
	-D OPENCV_EXTRA_MODULES_PATH=../opencv_contrib-3.1.0/modules \
	-D BUILD_EXAMPLES=ON ../opencv-3.1.0

RUN cd /home/code/build \
	&& make -j8

RUN cd /home/code/build \
	&& make -j8 package


RUN [ "cross-build-end" ]