#!/bin/bash

# misc
cd $SCRATCH/other_codes
export CRAY_CPU_TARGET=x86-64

# miniconda
wget -O miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh 
chmod u+x ./miniconda.sh
./miniconda.sh -b -p $SCRATCH/other_codes/miniconda 
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r 
conda create -n gcc_cpu python=3.10
# conda create -n gcc_gpu python=3.10
# conda create -n nvhpc_gpu python=3.10
conda activate gcc_cpu
conda install -c conda-forge gh
gh auth login
gh repo clone docker_fp

# mpi4py 
CC=mpicc MPICC=mpicc pip install --no-binary=mpi4py mpi4py 

# hdf5, h5py
module load cray-hdf5-parallel/1.12.2.9
wget -O h5py-3.15.1.tar.gz https://github.com/h5py/h5py/archive/refs/tags/3.15.1.tar.gz
tar -xzvf ./h5py-3.15.1.tar.gz
mv ./h5py-3.15.1 ./h5py-gcc-cpu-3.15.1
cd ./h5py-gcc-cpu-3.15.1
CC=mpicc HDF5_MPI=ON HDF5_DIR=$CRAY_HDF5_PARALLEL_PREFIX pip install . --no-build-isolation

# openblas
module load cray-libsci/25.09.0

# scalapack
module load cray-libsci/25.09.0

# elpa
wget -O elpa-2025.06.002.tar.gz https://gitlab.mpcdf.mpg.de/elpa/elpa/-/archive/new_release_2025.06.002/elpa-new_release_2025.06.002.tar.gz 
tar -xzvf ./elpa-2025.06.002.tar.gz && mv elpa-new_release* ./elpa-2025.06.002
cd elpa-2025.06.002
conda install -c conda-forge autoconf
./autogen.sh 
mkdir -p $SCRATCH_GCC_CPU/elpa-2025.06.002
mkdir -p $SCRATCH/modulefiles/elpa-gcc-cpu
touch $SCRATCH/modulefiles/elpa-gcc-cpu/2025.06.002.lua
CC=cc CXX=CC FC=ftn ./configure --prefix=$SCRATCH_GCC_CPU/elpa-2025.06.002 \
    --disable-shared \
    --disable-sse \
    --disable-sse-assembly \
    --disable-avx \
    --disable-avx2 \
    --disable-avx512 \
    CFLAGS="-O3 -fPIC" \
    LDFLAGS="-L$CRAY_LIBSCI_PREFIX/lib" \
    LIBS="-lsci_gnu_mpi -lsci_gnu" 
make -j8 
make install 
cat > $SCRATCH/modulefiles/petsc-gcc-cpu/3.24.4.lua << 'EOF'
help([[
elpa gcc cpu 2025.06.002
]])

prereq('PrgEnv-gnu', 'cray-libsci')

local scratch_gcc_cpu = os.getenv('SCRATCH_GCC_CPU')
local elpa_folder = scratch_gcc_cpu .. '/elpa-2025.06.002'

prepend_path('CPATH', elpa_folder .. '/include')
prepend_path('LIBRARY_PATH', elpa_folder .. '/lib')
prepend_path('LD_LIBRARY_PATH', elpa_folder .. '/lib')
setenv('ELPA_ROOT', elpa_folder)
EOF
module load elpa-gcc-cpu/2025.06.002
ln -sf $SCRATCH_GCC_CPU/elpa-2025.06.002/include/elpa-*/elpa $SCRATCH_GCC_CPU//elpa-2025.06.002/include 
cp $SCRATCH_GCC_CPU/elpa-2025.06.002/include/elpa-*/modules/* $SCRATCH_GCC_CPU/elpa-2025.06.002/include
cd ../ 

# petsc, petsc4py
wget -O petsc-3.24.4.tar.gz https://web.cels.anl.gov/projects/petsc/download/release-snapshots/petsc-3.24.4.tar.gz 
tar -xzvf petsc-3.24.4.tar.gz 
mv petsc-* petsc-gcc-cpu-3.24.4 
cd petsc-gcc-cpu-3.24.4  
mkdir -p $SCRATCH_GCC_CPU/petsc-3.24.4
mkdir -p $SCRATCH/modulefiles/petsc-gcc-cpu
touch $SCRATCH/modulefiles/petsc-gcc-cpu/3.24.4.lua
./configure --with-cc=cc \
    CFLAGS+="-DPETSC_SKIP_REAL___FLOAT128" \
    CXXFLAGS+="-DPETSC_SKIP_REAL___FLOAT128" \
    --with-cxx=CC --with-fc=0 \
    --prefix=$SCRATCH_GCC_CPU/petsc-3.24.4 \
    --with-scalar-type=complex --with-precision=double \
    --with-hdf5-dir=$CRAY_HDF5_PARALLEL_PREFIX \
    --with-blas-lib=$CRAY_LIBSCI_PREFIX/lib/libsci_gnu.a \
    --with-lapack-lib=$CRAY_LIBSCI_PREFIX/lib/libsci_gnu_mpi.a 
make -j8 
make install 
cd ..
cat > $SCRATCH/modulefiles/petsc-gcc-cpu/3.24.4.lua << 'EOF'
help([[
Petsc gcc cpu 3.24.4
]])

prereq('PrgEnv-gnu', 'cray-hdf5-parallel', 'cray-libsci')

local scratch_gcc_cpu = os.getenv('SCRATCH_GCC_CPU')
local petsc_folder = scratch_gcc_cpu .. '/petsc-3.24.4'

prepend_path('CPATH', petsc_folder .. '/include')
prepend_path('LIBRARY_PATH', petsc_folder .. '/lib')
prepend_path('LD_LIBRARY_PATH', petsc_folder .. '/lib')
setenv('PETSC_DIR', petsc_folder)
EOF
module load petsc-gcc-cpu/3.24.4
wget -O petsc4py-3.24.4.tar.gz https://web.cels.anl.gov/projects/petsc/download/release-snapshots/petsc4py-3.24.4.tar.gz 
tar -xzvf petsc4py-3.24.4.tar.gz && mv petsc4py-* petsc4py-gcc-cpu-3.24.4 
cd petsc4py-gcc-cpu-3.24.4 
CC=mpicc CXX=mpic++ PETSC_DIR=$SCRATCH_GCC_CPU/petsc-3.24.4 pip install . --no-build-isolation
cd ../

# slepc, slepc4py
wget -O slepc-3.24-2.tar.gz https://slepc.upv.es/download/distrib/slepc-3.24.2.tar.gz 
tar -xzvf slepc-3.24-2.tar.gz && mv slepc-* slepc-gcc-cpu-3.24.2
cd slepc-gcc-cpu-3.24-2 
mkdir -p $SCRATCH_GCC_CPU/slepc-3.24.2 
mkdir -p $SCRATCH/modulefiles/slepc-gcc-cpu 
touch $SCRATCH/modulefiles/slepc-gcc-cpu/3.24.2.lua 
CC=cc CXX=CC ./configure --prefix=$SCRATCH_GCC_CPU/slepc-3.24.2 
make -j8 
make install
cd .. 
cat > $SCRATCH/modulefiles/slepc-gcc-cpu/3.24.2.lua << 'EOF'
help([[
Slepc gcc cpu 3.24.2
]])

prereq('PrgEnv-gnu', 'cray-hdf5-parallel', 'cray-libsci')

local scratch_gcc_cpu = os.getenv('SCRATCH_GCC_CPU')
local slepc_folder = scratch_gcc_cpu .. '/slepc-3.24.2'

prepend_path('CPATH', slepc_folder .. '/include')
prepend_path('LIBRARY_PATH', slepc_folder .. '/lib')
prepend_path('LD_LIBRARY_PATH', slepc_folder .. '/lib')
setenv('SLEPC_DIR', slepc_folder)
EOF
module load slepc-gcc-cpu/3.24.2
wget -O slepc4py-3.24.2.tar.gz https://slepc.upv.es/download/distrib/slepc4py-3.24.2.tar.gz 
tar -xzvf slepc4py-3.24.2.tar.gz && mv slepc4py-* slepc4py-gcc-cpu-3.24.2
cd slepc4py-gcc-cpu-3.24.2
CC=mpicc CXX=mpic++ PETSC_DIR=$SCRATCH_GCC_CPU/petsc-3.24.4 SLEPC_DIR=$SCRATCH_GCC_CPU/slepc-3.24.2 pip install . --no-build-isolation
cd ../

# fftw
module load cray-fftw/3.3.10.11

# libxc, pylibxc
wget -O libxc-7.0.0.tar.gz https://gitlab.com/libxc/libxc/-/archive/7.0.0/libxc-7.0.0.tar.bz2 
tar -xvf libxc-7.0.0.tar.gz && mv libxc-7.0.0 libxc-gcc-cpu-7.0.0
cd libxc-gcc-cpu-7.0.0
mkdir -p $SCRATCH_GCC_CPU/libxc-7.0.0 
mkdir -p $SCRATCH/modulefiles/libxc-gcc-cpu
touch $SCRATCH/modulefiles/libxc-gcc-cpu/7.0.0.lua
autoreconf -i 
CC=cc FC=ftn ./configure CFLAGS="-fPIC" --prefix=$SCRATCH_GCC_CPU/libxc-7.0.0 
make -j8 
make install 
cat > $SCRATCH/modulefiles/libxc-gcc-cpu/7.0.0.lua << 'EOF'
help([[
libxc gcc cpu 7.0.0
]])

prereq('PrgEnv-gnu')

local scratch_gcc_cpu = os.getenv('SCRATCH_GCC_CPU')
local libxc_folder = scratch_gcc_cpu .. '/libxc-7.0.0'

prepend_path('PATH', libxc_folder .. '/bin')
prepend_path('CPATH', libxc_folder .. '/include')
prepend_path('LIBRARY_PATH', libxc_folder .. '/lib')
prepend_path('LD_LIBRARY_PATH', libxc_folder .. '/lib')
setenv('LIBXC_ROOT', libxc_folder)
EOF
module load libxc-gcc-cpu/7.0.0 
sed -i 's/nprocs = mp.cpu_count()/nprocs = 4  # Limited to prevent OOM/g' setup.py
pip install --no-cache-dir . --no-build-isolation 
cd ../

# qe 
gh repo clone q-e
mv q-e qe-gcc-cpu-7.3.1
cd qe-gcc-cpu-7.3.1
git checkout qe-7.3.1-dev
mkdir -p $SCRATCH_GCC_CPU/qe-7.3.1 
mkdir -p $SCRATCH/modulefiles/qe-gcc-cpu
touch $SCRATCH/modulefiles/qe-gcc-cpu/7.3.1.lua
CC=cc CXX=CC FC=ftn F90=ftn ./configure \
    --prefix=$SCRATCH_GCC_CPU/qe-7.3.1 \
    --with-hdf5=yes --with-hdf5-include=$CRAY_HDF5_PARALLEL_PREFIX/include \
    --with-hdf5-libs="-L$CRAY_HDF5_PARALLEL_PREFIX/lib -lhdf5hl_fortran -lhdf5_hl -lhdf5_fortran -lhdf5 -lz -ldl -lm" \
    --with-libxc=yes --with-libxc-prefix=$SCRATCH_GCC_CPU/libxc-7.0.0 \
    --with-libxc-include=$SCRATCH_GCC_CPU/libxc-7.0.0/include 
make all -j8 
make epw -j8 
# perturbo
gh repo clone perturbo
cd perturbo
git checkout develop
cp ../../docker_fp/make.sys ./make.sys
make 
cd ../
make install 
cat > $SCRATCH/modulefiles/qe-gcc-cpu/7.3.1.lua << 'EOF'
help([[
qe gcc cpu 7.3.1
]])

prereq('PrgEnv-gnu', 'cray-hdf5-parallel', 'cray-fftw', 'cray-libsci', 'libxc-gcc-cpu')

local scratch_gcc_cpu = os.getenv('SCRATCH_GCC_CPU')
local qe_folder = scratch_gcc_cpu .. '/qe-7.3.1'

prepend_path('PATH', qe_folder .. '/bin') 
setenv('QE_ROOT', qe_folder)
EOF
module load qe-gcc-cpu/7.3.1
cd ../

# bgw 
gh repo clone BerkeleyGW
mv BerkeleyGW BerkeleyGW-gcc-cpu-4.0.0
cd ./BerkeleyGW-gcc-cpu-4.0.0
mkdir -p $SCRATCH_GCC_CPU/bgw-4.0.0
mkdir -p $SCRATCH/modulefiles/bgw-gcc-cpu
touch $SCRATCH/modulefiles/bgw-gcc-cpu/4.0.0.lua
cp ../docker_fp/arch_perlmutter_gcc_cpu.mk ./arch.mk
make all-flavors -j16
make install INSTDIR=$SCRATCH_GCC_CPU/bgw-4.0.0
cat > $SCRATCH/modulefiles/bgw-gcc-cpu/4.0.0.lua << 'EOF'
help([[
bgw gcc cpu 4.0.0
]])

prereq('PrgEnv-gnu', 'cray-hdf5-parallel', 'cray-fftw', 'cray-libsci')

local scratch_gcc_cpu = os.getenv('SCRATCH_GCC_CPU')
local bgw_folder = scratch_gcc_cpu .. '/bgw-4.0.0'

prepend_path('PATH', bgw_folder .. '/bin') 
prepend_path('CPATH', bgw_folder .. '/include') 
prepend_path('LIBRARY_PATH', bgw_folder .. '/lib') 
prepend_path('LD_LIBRARY_PATH', bgw_folder .. '/lib') 
setenv('BGW_ROOT', bgw_folder)
EOF
module load bgw-gcc-cpu/4.0.0

# python packages: numpy, pandas, scipy, sympy, matplotlib, seaborn,
# - torch, torchvision, torchaudio, tensorboard, datasets, transformers, diffusers, 
# - langchain, ase, gpaw, pyscf, mp_api, pymatgen, jupyterlab  
pip install cython
pip install numpy pandas scipy sympy matplotlib seaborn
pip install scikit-learn joblib xgboost
pip install torch torchvision torch_geometric transformers datasets accelerate evaluate diffusers e3nn 
pip install langchain langchain-huggingface
pip install ase pymatgen mp_api pyvista[all] 