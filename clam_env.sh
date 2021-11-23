#!/bin/bash

# I am following the installation instructions [here](https://github.com/mahmoodlab/CLAM/blob/master/docs/INSTALLATION.md) using a compute node on Biowulf allocated using "sinteractive --mem=20g --gres=gpu:k80:1"

# This does not work as it comes with a conflicting Python installation; trying to install manually now using the link https://github.com/openslide/openslide/releases/download/v3.4.1/openslide-3.4.1.tar.gz
# module load openslide

# Load OpenSlide prerequisites:
# not yet installing/loading: GDK-PixBuf, libxml2, cairo >= 1.2, glib >= 2.16
module load zlib libpng libjpeg-turbo libtiff openjpeg SQLite

# Didn't seem to work for installing OpenSlide:
# ./configure OPENJPEG2_LIBS=/usr/local/openjpeg/2.3.1/lib  # didn't work
# ./configure CPPFLAGS=-I/usr/local/openjpeg/2.3.1/include LDFLAGS=-L/usr/local/openjpeg/2.3.1/lib  # didn't work
# ./configure --prefix=/home/weismanal/notebook/2021-11-10/testing_clam/installing_openslide/installation PKG_CONFIG_PATH=/usr/local/openjpeg/2.3.1/lib/pkgconfig  # worked for ./configure but not for make

# Seemed to work for installing OpenSlide:
# Note during "make" I got many warnings like:
#   /usr/local/GCC/7.2.0/lib/gcc/x86_64-redhat-linux/7.2.0/../../../../x86_64-redhat-linux/bin/ld: warning: libjpeg.so.62, needed by /lib/../lib64/libtiff.so, may conflict with libjpeg.so.8
# ./configure --prefix=/home/weismanal/notebook/2021-11-10/testing_clam/installing_openslide/installation PKG_CONFIG_PATH=/usr/local/openjpeg/2.3.1/lib/pkgconfig CPPFLAGS=-I/usr/local/openjpeg/2.3.1/include/openjpeg-2.3 LDFLAGS=-L/usr/local/openjpeg/2.3.1/lib
# make
# make install

# Set up OpenSlide environment
export PATH=$PATH:/home/weismanal/notebook/2021-11-10/testing_clam/installing_openslide/installation/bin
export CPATH=$CPATH:/home/weismanal/notebook/2021-11-10/testing_clam/installing_openslide/installation/include
export C_INCLUDE_PATH=$C_INCLUDE_PATH:/home/weismanal/notebook/2021-11-10/testing_clam/installing_openslide/installation/include
export CMAKE_INCLUDE_PATH=$CMAKE_INCLUDE_PATH:/home/weismanal/notebook/2021-11-10/testing_clam/installing_openslide/installation/include
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/weismanal/notebook/2021-11-10/testing_clam/installing_openslide/installation/lib
export LD_RUN_PATH=$LD_RUN_PATH:/home/weismanal/notebook/2021-11-10/testing_clam/installing_openslide/installation/lib
export MANPATH=$MANPATH:/home/weismanal/notebook/2021-11-10/testing_clam/installing_openslide/installation/share/man

# Set up clam Python environment
conda activate clam

export CLAM=/home/weismanal/notebook/2021-11-10/testing_clam/repo
