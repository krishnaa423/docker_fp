#!/bin/bash

# Using PrgEnv-cray.

# miniconda
wget -O miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
&& chmod +x miniconda.sh \
&& ./miniconda.sh -b -p $SCRATCH_CRAY/miniconda \
&& $SCRATCH_CRAY/miniconda/bin/conda init \
&& rm -rf ./miniconda.sh

# python
pip install numpy pandas scipy sympy matplotlib seaborn

# mpi4py
MPICC=mpicc CC=mpicc pip install --no-binary=mpi4py mpi4py

# libz
wget -O zlib.tar.gz https://github.com/madler/zlib/releases/download/v1.3.1/zlib-1.3.1.tar.gz \
&& tar -xzvf zlib.tar.gz && mv zlib-* zlib \
&& cd zlib \
&& CC=mpicc CXX=mpic++ FC=mpif90 CFLAGS="-fPIC" CXXFLAGS="-fPIC" FCFLAGS="-fPIC" ./configure --prefix=$SCRATCH_CRAY \
&& make -j8 && make install \
&& cd .. \
&& rm -rf zlib*

# hdf5
wget -O hdf5.tar.gz https://github.com/HDFGroup/hdf5/releases/download/2.0.0/hdf5.tar.gz \
&& tar -xzvf hdf5.tar.gz && mv hdf5-* hdf5 \
&& cd hdf5 \
&& mkdir build \
&& cmake -S . -B build \
  -DCMAKE_INSTALL_PREFIX=$SCRATCH_CRAY \
  -DCMAKE_C_COMPILER=mpicc \
  -DCMAKE_CXX_COMPILER=mpic++ \
  -DCMAKE_Fortran_COMPILER=mpif90 \
  -DHDF5_BUILD_FORTRAN=ON \
  -DHDF5_ENABLE_PARALLEL=ON \
  -DHDF5_ENABLE_ZLIB_SUPPORT=ON \
&& cmake --build build \
&& cmake --install build \
&& cd .. \
&& rm -rf hdf5* \
# h5py
&& CC=mpicc CFLAGS="-I$CRAY_HDF5_PARALLEL_PREFIX/include" HDF5_MPI="ON" HDF5_DIR="$SCRATCH_CRAY"  pip install --no-binary=h5py h5py

# openblas
wget -O openblas.tar.gz https://github.com/OpenMathLib/OpenBLAS/releases/download/v0.3.31/OpenBLAS-0.3.31.tar.gz \
&& tar -xzvf openblas.tar.gz && mv OpenBLAS-* openblas \
&& cd openblas \
&& module unload craype-accel-amd-gfx90a \
&& CC=mpicc CXX=mpic++ FC=mpif90 make USE_OPENMP=1 COMMON_OPT="-fPIC" -j8 \
&& make install PREFIX=$SCRATCH_CRAY \
&& module load craype-accel-amd-gfx90a \
&& cd .. \
&& rm -rf openblas* 

# scalapack. Make sure -std=gnu89 flags for CCFLAGS.
wget -O scalapack.tar.gz https://github.com/Reference-ScaLAPACK/scalapack/archive/refs/tags/v2.2.2.tar.gz \
&& tar -xzvf scalapack.tar.gz && mv scalapack-* scalapack \
&& cd scalapack \
&& cp ../SLmake.inc* ./SLmake.inc \
&& make lib \
&& cp ./libscalapack.a $SCRATCH_CRAY/lib/libscalapack.a \
&& cd .. \
&& rm -rf scalapack* SLmake.inc*

# fftw
wget -O fftw3.tar.gz https://fftw.org/fftw-3.3.10.tar.gz \
&& tar -xzvf fftw3.tar.gz && mv fftw-* fftw3 \
&& cd fftw3 \
&& autoreconf -i \
&& CC=mpicc CXX=mpic++ FC=mpif90 ./configure --prefix=$SCRATCH_CRAY CFLAGS="-fPIC" FCFLAGS="-fPIC" --enable-shared --enable-openmp --enable-mpi \
&& CC=mpicc CXX=mpic++ FC=mpif90 ./configure --prefix=$SCRATCH_CRAY CFLAGS="-fPIC" FCFLAGS="-fPIC" --enable-shared --enable-threads --enable-mpi \
&& make -j8 && make install \
&& CC=mpicc CXX=mpic++ FC=mpif90 ./configure --prefix=$SCRATCH_CRAY CFLAGS="-fPIC" FCFLAGS="-fPIC" --enable-shared --enable-openmp --enable-mpi --enable-single \
&& CC=mpicc CXX=mpic++ FC=mpif90 ./configure --prefix=$SCRATCH_CRAY CFLAGS="-fPIC" FCFLAGS="-fPIC" --enable-shared --enable-threads --enable-mpi --enable-single \
&& make -j8 && make install \
&& cd .. \
&& rm -rf fftw3*

# libxc
wget -O libxc.tar.gz https://gitlab.com/libxc/libxc/-/archive/7.0.0/libxc-7.0.0.tar.bz2 \
&& tar -xvf libxc.tar.gz && mv libxc-* libxc \
&& cd libxc \
&& autoreconf -i \
&& CC=mpicc FC=mpif90 ./configure CFLAGS="-fPIC" --prefix=$SCRATCH_CRAY \
&& make -j8 && make install \
&& cd .. \
&& rm -rf libxc* 

# qe-7.3.1
wget -O qe.tar.gz https://gitlab.com/QEF/q-e/-/archive/qe-7.3.1/q-e-qe-7.3.1.tar.gz \
&& tar -xzvf qe.tar.gz && mv q-e-* qe \
&& cd qe \
&& CC=mpicc CXX=mpic++ FC=mpif90 ./configure \
LIBDIRS="$CRAY_LIBSCI_PREFIX" \
BLAS_LIBS=" -L$CRAY_LIBSCI_PREFIX/lib -lsci_cray_mpi -lsci_cray " \
--prefix=$SCRATCH_CRAY --with-scalapack=yes \
--with-hdf5=yes --with-hdf5-include=$CRAY_HDF5_PARALLEL_PREFIX/include \
--with-hdf5-libs="-L$CRAY_HDF5_PARALLEL_PREFIX/lib -lhdf5hl_fortran -lhdf5_hl -lhdf5_fortran -lhdf5 -lz -ldl -lm" \
--with-libxc=yes --with-libxc-prefix=$SCRATCH_CRAY --with-libxc-include=$SCRATCH_CRAY/include \
&& make all -j8 && make epw -j8 \
# perturbo
&& gh repo clone perturbo \
&& cd perturbo \
&& cp ../../make.sys ./make.sys \
&& make \
&& cd .. \
&& make install \
&& cp ./external/wannier90/utility/kmesh.pl $SCRATCH_CRAY/bin/kmesh.pl \
&& cd .. \
&& rm -rf qe*

# bgw
wget -O bgw.tar.gz https://app.box.com/shared/static/22edl07muvhfnd900tnctsjjftbtcqc4.gz \
&& tar -xzvf bgw.tar.gz && mv BerkeleyGW* bgw \
&& cd bgw \
&& cp ../arch_frontier_cpu.mk ./arch.mk \
&& make all-flavors -j16 \
&& make install INSTDIR=$SCRATCH_CRAY \
&& cd .. \ 
&& rm -rf arch* bgw*

# petsc
wget -O petsc.tar.gz https://web.cels.anl.gov/projects/petsc/download/release-snapshots/petsc-3.24.4.tar.gz \
&& tar -xzvf petsc.tar.gz \
&& mv petsc-* petsc \
&& cd petsc \
&&  ./configure --with-cc=mpicc \
CFLAGS+="-DPETSC_SKIP_REAL___FLOAT128" \
CXXFLAGS+="-DPETSC_SKIP_REAL___FLOAT128" \
--with-cxx=mpic++ --with-fc=0 \
--prefix=$SCRATCH_CRAY --with-scalar-type=complex --with-precision=double \
--with-hdf5-dir=$CRAY_HDF5_PARALLEL_PREFIX \
--with-blas-lib=$CRAY_LIBSCI_PREFIX/lib/libsci_cray.a \
--with-lapack-lib=$CRAY_LIBSCI_PREFIX/lib/libsci_cray.a \
&& make -j8 && make install \
&& cd .. \
&& rm -rf petsc* 

# petsc4py
wget -O petsc4py.tar.gz https://web.cels.anl.gov/projects/petsc/download/release-snapshots/petsc4py-3.24.4.tar.gz \
&& tar -xzvf petsc4py.tar.gz && mv petsc4py-* petsc4py \
&& cd petsc4py \
&& CC=mpicc CXX=mpic++ PETSC_DIR=$SCRATCH_CRAY pip install . \
&& cd .. \
&& rm -rf petsc4py*

# slepc
&& wget -O slepc.tar.gz https://slepc.upv.es/download/distrib/slepc-3.24.2.tar.gz \
&& tar -xzvf slepc.tar.gz \
&& mv slepc-* slepc \
&& cd slepc \
&& CC=mpicc CXX=mpic++ ./configure --prefix=$SCRATCH_CRAY \
&& make -j8 && make install \
&& cd .. \
&& rm -rf slepc*

# slepc4py
wget -O slepc4py.tar.gz https://slepc.upv.es/download/distrib/slepc4py-3.24.2.tar.gz \
&& tar -xzvf slepc4py.tar.gz && mv slepc4py-* slepc4py \
&& cd slepc4py \
&& CC=mpicc CXX=mpic++ PETSC_DIR=$SCRATCH_CRAY SLEPC_DIR=$SCRATCH_CRAY pip install . \
&& cd .. \
&& rm -rf slepc4py* 