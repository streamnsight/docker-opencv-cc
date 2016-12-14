FROM resin/armv7hf-debian-qemu

RUN [ "cross-build-start" ]

RUN export NPROC=$(nproc --all)
# build tools
RUN apt-get update && apt-get install -y --no-install-recommends \
	build-essential \
	cmake \
	pkg-config \
	wget \
    unzip \
	cmake-curses-gui

# Image format support:
# JPEG, TIFF, JPEG2000, PNG
# GUI Framework: gtk GUI framework
RUN apt-get install -y --no-install-recommends \
	libjpeg-dev \
	libtiff5-dev \
	libjasper-dev \
	libpng12-dev \
	libgtk2.0-dev

# OpenGL extension to GTK (optional)
RUN apt-get install -y --no-install-recommends \
	libgtkglext1-dev

# Video Driver
# video4linux device driver for video capture
RUN apt-get install -y --no-install-recommends \
	libv4l-dev \
	libv4l-0 \
	v4l-utils

# AUDIO / VIDEO CODECS:
# ffmpeg libraries (optional but recommended)
# xvid and x264 codecs (optional)
RUN apt-get install -y --no-install-recommends \
	libavcodec-dev \
	libavformat-dev \
	libswscale-dev \
	libxvidcore-dev \
	libx264-dev


# Build libjpeg-turbo
#By default libjpeg-turbo will install into /opt/libjpeg-turbo. You may install to a different directory by
# passing the --prefix option to the configure script.
# However, the remainder of these instructions will assume that libjpeg-turbo was installed in its default location.

RUN mkdir -p /home/code/ \
	&& wget http://sourceforge.net/projects/libjpeg-turbo/files/1.3.0/libjpeg-turbo-1.3.0.tar.gz \
	&& tar xzvf libjpeg-turbo-1.3.0.tar.gz \
	&& cd libjpeg-turbo-1.3.0 \
	&& mkdir build \
	&& cd build \
	&& ../configure CPPFLAGS="-O3 -pipe -fPIC -mfpu=neon -mfloat-abi=hard" \
	&& make -j${NPROC} \
	&& make install

#RUN mkdir -p /usr/include/ffmpeg \
#	&& ln -s /usr/include/libavformat/* /usr/include/ffmpeg/ \
#	&& ln -s /usr/include/libavcodec/* /usr/include/ffmpeg/ \
#	&& ln -s /usr/include/libavresample/* /usr/include/ffmpeg/

# Audio MP3, AAC encoding codecs (optional)
RUN apt-get install -y --no-install-recommends \
    libmp3lame-dev
    #libfaac-dev

# gstreamer (optional) multimedia framework
RUN apt-get install -y --no-install-recommends \
	libgstreamer1.0-0-dbg \
	libgstreamer1.0-0 \
	libgstreamer1.0-dev \
	libgstreamer-plugins-base1.0-dev

# Theora video compression codec (optional, not recommended)
#sudo apt-get install -y libtheora-dev

# Vorbis General Audio Compression Codec (optional, not recommended)
#sudo apt-get install -y libvorbis-dev

# Speech CODECS	:
# Speech CODECs

# Adaptive Multi Rate codec (Wide band and Narrow band) (optional)
#RUN apt-get install -y --no-install-recommends \
#	libopencore-amrnb-dev \
#	libopencore-amrwb-dev

# 1394 FireWire / iLink support:
# FireWire support (optional)
#RUN apt-get install -y \
#	libdc1394-22 \
#	libdc1394-22-dev

# Optimizations:

# TBB Multi-core / multi-processor framework (optional but recommended)
RUN apt-get install -y --no-install-recommends \
	libtbb-dev

# ATLAS Automatically Tuned Linear Algebra Software; optimized version of BLAS and LAPACK
RUN apt-get install -y --no-install-recommends \
	libatlas-base-dev

# PThread
RUN apt-get install -y --no-install-recommends \
	libpthread-stubs0-dev \
	libevent-pthreads-2.0-5

# Python bindings
# python dev library
RUN apt-get install -y --no-install-recommends \
	python2.7-dev

# install -y PIP
RUN wget https://bootstrap.pypa.io/get-pip.py \
	&& python get-pip.py

# GNU Fortran compiler, used to optimize SciPy code
RUN apt-get install -y --no-install-recommends \
	gfortran

# Python bindings dependencies
RUN apt-get install -y --no-install-recommends \
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
RUN cd /home/code/ \
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
    -D WITH_JPEG=ON \
    -D BUILD_JPEG=OFF \
    -D JPEG_INCLUDE_DIR=/opt/libjpeg-turbo/include/ \
    -D JPEG_LIBRARY=/opt/libjpeg-turbo/lib/libjpeg.a \
    -D BUILD_EXAMPLES=OFF \
    -D BUILD_DOCS=OFF \
    -D ENABLE_VFPV3=ON \
    -D BUILD_TESTS=OFF \
    -D BUILD_OPENEXR=ON \
    -D WITH_1394=OFF \
    -D WITH_CUDA=OFF \
    -D WITH_CUBLAS=OFF \
    -D WITH_CUFFT=OFF \
    -D WITH_GSTREAMER=ON \
    -D WITH_GTK=ON \
    -D WITH_GTK_2_X=ON \
    -D BUILD_GTK_2_X=ON \
    -D WITH_OPENCL=ON \
    -D WITH_OPENCLAMBDABLAS=OFF \
    -D WITH_OPENCLAMDFFT=OFF \
    -D WITH_OPENCL_SVM=OFF \
    -D WITH_V4L=ON \
    -D ENABLE_NEON=ON \
    -D WITH_NEON=ON \
    -D WITH_TBB=ON \
    -D BUILD_TBB=ON \
    -D BUILD_TIFF=ON \
    -D WITH_TIFF=ON \
    -D BUILD_PNG=ON \
    -D WITH_PNG=ON \
    -D BUILD_FFMPEG=ON \
    -D WITH_FFMPEG=ON \
    ../opencv-3.1.0

RUN cd /home/code/build \
	&& make -j${NPROC} \
	&& make -j${NPROC} package \
	&& make -j${NPROC} install

RUN cd /home/code \
	&& rm -rf *

RUN [ "cross-build-end" ]