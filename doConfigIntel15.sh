#!/bin/bash -e
[ $# -ne 1 ] && echo "Usage: $0 <install prefix path>" && exit 0
module swap intel intel/15.0.2 
module swap mvapich2 impi/5.0.2 
src=$PWD/..
ins=$1
mpichflags="-mmic -O3 "
export MPICHLIB_CFLAGS="$mpichflags"
export MPICHLIB_CXXFLAGS="$mpichflags"
export MPICHLIB_FFLAGS="$mpichflags"
export MPICHLIB_FCFLAGS="$mpichflags"
export MPICHLIB_LDFLAGS="$mpichflags -Wl,-rpath-link=/opt/apps/intel/15/composer_xe_2015.2.164/compiler/lib/mic/ -Wl,--as-needed "

../configure --prefix=$ins \
 --enable-threads=multiple \
 --with-device=ch3:nemesis:ib \
 --with-cross=$src/src/mpid/ch3/channels/nemesis/netmod/ib/cross_values.txt \
 --host=x86_64-k1om-linux \
 CC=icc CXX=icpc FC=ifort
