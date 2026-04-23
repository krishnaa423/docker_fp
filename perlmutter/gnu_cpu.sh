#!/bin/bash

# list.
# - cpu-env/gnu-1.0.0.
# - miniconda.
# - python packages. 
# - mpi4py.
# - hdf5, h5py.
# - openblas.
# - scalapack.
# - elpa.
# - petsc, petsc4py.
# - slepc, slepc4py.
# - fftw.
# - libxc, pylibxc.
# - qe-7.3.1, perturbo.
# - qe-7.5.
# - bgw.
# - python packages. 
# - add all packages. 

# cpu-env/gnu-1.0.0.
mkdir -p $SCRATCH/opt/modulefiles/cpu-env
touch $SCRATCH/opt/modulefiles/cpu-env/gnu-1.0.0.lua
cat > $SCRATCH/opt/modulefiles/cpu-env/gnu-1.0.0.lua << 'EOF'
help([[
Setup GNU CPU env 1.0.0
]])

load('PrgEnv-gnu/8.6.0')
load('cray-hdf5-parallel/1.12.2.9')
load('cray-libsci/25.09.0')
load('cray-fftw/3.3.10.11')

local cray_ld_library_path = os.getenv('CRAY_LD_LIBRARY_PATH')

prepend_path('LIBRARY_PATH', cray_ld_library_path)
prepend_path('LD_LIBRARY_PATH', cray_ld_library_path)

pushenv('MPICH_GPU_SUPPORT_ENABLED', '0')
pushenv('CRAY_CPU_TARGET', 'x86-64')
EOF
cd $SCRATCH/opt

# miniconda. 
wget -O miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh 
chmod u+x ./miniconda.sh
./miniconda.sh -b -p $SCRATCH/opt/miniconda 
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r 
conda create -n gnu_cpu python=3.10 -y
conda activate gnu_cpu
rm -rf $CONDA_ROOT/envs/gnu_cpu/compiler_compat/ld
ln -sf /usr/bin/ld $CONDA_ROOT/envs/gnu_cpu/compiler_compat/ld
conda install -c conda-forge gh -y
gh auth login
gh repo clone docker_fp

# python packages: numpy, pandas, scipy, sympy, matplotlib, seaborn,
# - torch, torchvision, torchaudio, tensorboard, datasets, transformers, diffusers, 
# - langchain, ase, gpaw, pyscf, mp_api, pymatgen, jupyterlab  
pip install cython --no-cache-dir
pip install numpy pandas scipy sympy matplotlib seaborn  --no-cache-dir
pip install scikit-learn joblib xgboost  --no-cache-dir
pip install torch torchvision torch_geometric transformers datasets accelerate evaluate diffusers e3nn  --no-cache-dir
pip install langchain langchain-huggingface  --no-cache-dir
pip install ase pymatgen mp_api pyvista[all]  --no-cache-dir

# mpi4py. 
CC=cc MPICC=cc pip install --no-binary=mpi4py mpi4py --force-reinstall --no-cache-dir

# hdf5, h5py. 
cd ./h5py
module load cray-hdf5-parallel/1.12.2.9
wget -O h5py-3.15.1.tar.gz https://github.com/h5py/h5py/archive/refs/tags/3.15.1.tar.gz
tar -xzvf ./h5py-3.15.1.tar.gz
mv ./h5py-3.15.1 ./h5py-gnu-cpu-3.15.1
cd ./h5py-gnu-cpu-3.15.1
CC=cc HDF5_MPI=ON HDF5_DIR=$CRAY_HDF5_PARALLEL_PREFIX pip install . \
  --no-build-isolation \
  --no-cache-dir \
  --force-reinstall
cd ../../

# openblas
module load cray-libsci/25.09.0

# scalapack
module load cray-libsci/25.09.0

# elpa
cd ./elpa
wget -O elpa-2026.02.001.tar.gz https://gitlab.mpcdf.mpg.de/elpa/elpa/-/archive/new_release_2026_02_001/elpa-new_release_2026_02_001.tar.gz
tar -xzvf ./elpa-2026.02.001.tar.gz && mv elpa-new_release* ./elpa-gnu-cpu-2026.02.001
cd elpa-gnu-cpu-2026.02.001
conda install -c conda-forge autoconf -y
./autogen.sh 
mkdir -p $SCRATCH/opt/modulefiles/elpa
touch $SCRATCH/opt/modulefiles/elpa/gnu-cpu-2026.02.001.lua
CC=cc CXX=CC FC=ftn ./configure --prefix=$(pwd) \
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
cat > $SCRATCH/opt/modulefiles/elpa/gnu-cpu-2026.02.001.lua << 'EOF'
help([[
elpa gnu cpu 2026.02.001
]])

prereq('PrgEnv-gnu', 'cray-libsci')

local scratch = os.getenv('SCRATCH')
local elpa_folder = scratch .. '/opt/elpa/elpa-gnu-cpu-2026.02.001'

prepend_path('CPATH', elpa_folder .. '/include')
prepend_path('LIBRARY_PATH', elpa_folder .. '/lib')
prepend_path('LD_LIBRARY_PATH', elpa_folder .. '/lib')
pushenv('ELPA_ROOT', elpa_folder)
EOF
ln -sf $SCRATCH/opt/elpa/elpa-gnu-cpu-2026.02.001/include/elpa-2026.02.001/elpa $SCRATCH/opt/elpa/elpa-gnu-cpu-2026.02.001/include
cp ./include/elpa-*/modules/* ./include
module load elpa/gnu-cpu-2026.02.001
cd ../../

# petsc, petsc4py
cd ./petsc
wget -O petsc-3.25.0.tar.gz https://web.cels.anl.gov/projects/petsc/download/release-snapshots/petsc-3.25.0.tar.gz 
tar -xzvf petsc-3.25.0.tar.gz 
mv petsc-3.25.0 petsc-gnu-cpu-3.25.0
cd petsc-gnu-cpu-3.25.0
mkdir -p $SCRATCH/opt/modulefiles/petsc
touch $SCRATCH/opt/modulefiles/petsc/gnu-cpu-3.25.0.lua
./configure --with-cc=cc \
    CFLAGS+="-DPETSC_SKIP_REAL___FLOAT128" \
    CXXFLAGS+="-DPETSC_SKIP_REAL___FLOAT128" \
    --with-cxx=CC --with-fc=0 \
    --with-scalar-type=complex --with-precision=double \
    --with-hdf5-dir=$CRAY_HDF5_PARALLEL_PREFIX \
    --with-blas-lib=$CRAY_LIBSCI_PREFIX/lib/libsci_gnu.a \
    --with-lapack-lib=$CRAY_LIBSCI_PREFIX/lib/libsci_gnu_mpi.a 
make -j8 
make install 
cd ../../
cat > $SCRATCH/opt/modulefiles/petsc/gnu-cpu-3.25.0.lua << 'EOF'
help([[
Petsc gnu cpu 3.25.0
]])

prereq('PrgEnv-gnu', 'cray-hdf5-parallel', 'cray-libsci')

local scratch = os.getenv('SCRATCH')
local libsci_dir = os.getenv('CRAY_LIBSCI_PREFIX')
local petsc_dir = scratch .. '/opt/petsc/petsc-gnu-cpu-3.25.0'
local petsc_folder = scratch .. '/opt/petsc/petsc-gnu-cpu-3.25.0/arch-linux-c-debug'

prepend_path('CPATH', petsc_folder .. '/include')
prepend_path('LIBRARY_PATH', petsc_folder .. '/lib')
prepend_path('LIBRARY_PATH', libsci_dir .. '/lib')
prepend_path('LD_LIBRARY_PATH', petsc_folder .. '/lib')
prepend_path('LD_LIBRARY_PATH', libsci_dir .. '/lib')
pushenv('PETSC_DIR', petsc_dir)
pushenv('PETSC_ARCH', 'arch-linux-c-debug')
EOF
module load petsc/gnu-cpu-3.25.0
cd ./petsc4py
wget -O petsc4py-3.25.0.tar.gz https://web.cels.anl.gov/projects/petsc/download/release-snapshots/petsc4py-3.25.0.tar.gz
tar -xzvf petsc4py-3.25.0.tar.gz && mv petsc4py-3.25.0 petsc4py-gnu-cpu-3.25.0 
cd petsc4py-gnu-cpu-3.25.0 
CC=cc CXX=CC pip install . --no-build-isolation --no-cache-dir --force-reinstall
cd ../../

# slepc, slepc4py
cd ./slepc
wget -O slepc-3.25.0.tar.gz https://slepc.upv.es/download/distrib/slepc-3.25.0.tar.gz
tar -xzvf slepc-3.25.0.tar.gz && mv slepc-3.25.0 slepc-gcc-cpu-3.25.0
cd slepc-gcc-cpu-3.25.0 
mkdir -p $SCRATCH/opt/modulefiles/slepc
touch $SCRATCH/opt/modulefiles/slepc/gcc-cpu-3.25.0.lua 
CC=cc CXX=CC ./configure
make -j8 
make install
cd ../../
cat > $SCRATCH/opt/modulefiles/slepc/gcc-cpu-3.25.0.lua << 'EOF'
help([[
Slepc gcc cpu 3.25.0
]])

prereq('PrgEnv-gnu', 'cray-hdf5-parallel', 'cray-libsci')

local scratch = os.getenv('SCRATCH')
local slepc_dir = scratch .. '/opt/slepc/slepc-gcc-cpu-3.25.0'
local slepc_folder = scratch .. '/opt/slepc/slepc-gcc-cpu-3.25.0/arch-linux-c-debug'

prepend_path('CPATH', slepc_folder .. '/include')
prepend_path('LIBRARY_PATH', slepc_folder .. '/lib')
prepend_path('LD_LIBRARY_PATH', slepc_folder .. '/lib')
pushenv('SLEPC_DIR', slepc_dir)
EOF
module load slepc/gcc-cpu-3.25.0
cd ./slepc4py
wget -O slepc4py-3.25.0.tar.gz https://slepc.upv.es/download/distrib/slepc4py-3.25.0.tar.gz 
tar -xzvf slepc4py-3.25.0.tar.gz && mv slepc4py-3.25.0 slepc4py-gcc-cpu-3.25.0
cd slepc4py-gcc-cpu-3.25.0
CC=cc CXX=CC pip install . --no-build-isolation --no-cache-dir
cd ../../

# fftw
module load cray-fftw/3.3.10.11

# libxc, pylibxc
cd ./libxc
wget -O libxc-7.0.0.tar.gz https://gitlab.com/libxc/libxc/-/archive/7.0.0/libxc-7.0.0.tar.bz2 
tar -xvf libxc-7.0.0.tar.gz && mv libxc-7.0.0 libxc-gnu-cpu-7.0.0
cd libxc-gnu-cpu-7.0.0
mkdir -p $SCRATCH/opt/modulefiles/libxc
touch $SCRATCH/opt/modulefiles/libxc/gnu-cpu-7.0.0.lua
autoreconf -i 
CC=cc FC=ftn ./configure CFLAGS="-fPIC" --prefix=$(pwd)
make -j8 
make install 
cat > $SCRATCH/opt/modulefiles/libxc/gnu-cpu-7.0.0.lua << 'EOF'
help([[
libxc gnu cpu 7.0.0
]])

prereq('PrgEnv-gnu')

local scratch = os.getenv('SCRATCH')
local libxc_folder = scratch .. '/opt/libxc/libxc-gnu-cpu-7.0.0'

prepend_path('PATH', libxc_folder .. '/bin')
prepend_path('CPATH', libxc_folder .. '/include')
prepend_path('LIBRARY_PATH', libxc_folder .. '/lib')
prepend_path('LD_LIBRARY_PATH', libxc_folder .. '/lib')
pushenv('LIBXC_ROOT', libxc_folder)
EOF
module load libxc/gnu-cpu-7.0.0 
sed -i 's/nprocs = mp.cpu_count()/nprocs = 4  # Limited to prevent OOM/g' setup.py
pip install --no-cache-dir . --no-build-isolation 
cd ../../

# qe-7.3.1, perturbo
# Optimization level: -O0. mpif90 -> ftn. 
cd ./qe
wget -O qe-7.3.1.tar.gz https://gitlab.com/QEF/q-e/-/archive/qe-7.3.1/q-e-qe-7.3.1.tar.gz
tar -xzvf qe-7.3.1.tar.gz && mv q-e-qe-7.3.1 qe-gnu-cpu-7.3.1
cd qe-gnu-cpu-7.3.1
mkdir -p $SCRATCH/opt/modulefiles/qe
touch $SCRATCH/opt/modulefiles/qe/gnu-cpu-7.3.1.lua
CC=cc CXX=CC FC=ftn F90=ftn ./configure \
    --prefix=$(pwd) \
    --with-hdf5=yes --with-hdf5-include=$CRAY_HDF5_PARALLEL_PREFIX/include \
    --with-hdf5-libs="-L$CRAY_HDF5_PARALLEL_PREFIX/lib -lhdf5hl_fortran -lhdf5_hl -lhdf5_fortran -lhdf5 -lz -ldl -lm" \
    --with-libxc=yes --with-libxc-prefix=$SCRATCH/opt/libxc/libxc-gnu-cpu-7.0.0 \
    --with-libxc-include=$SCRATCH/opt/libxc/libxc-gnu-cpu-7.0.0/include
make all -j8 
make epw -j8 
# perturbo
gh repo clone perturbo
cd perturbo
git checkout develop
cp ../../../docker_fp/perlmutter/perturbo_gnu_cpu_make.sys ./make.sys
make 
cd ../
make install 
cat > $SCRATCH/opt/modulefiles/qe/gnu-cpu-7.3.1.lua << 'EOF'
help([[
qe gnu cpu 7.3.1
]])

prereq('PrgEnv-gnu', 'cray-hdf5-parallel', 'cray-fftw', 'cray-libsci', 'libxc')

local scratch = os.getenv('SCRATCH')
local qe_folder = scratch .. '/opt/qe/qe-gnu-cpu-7.3.1'

prepend_path('PATH', qe_folder .. '/bin') 
pushenv('QE_ROOT', qe_folder)
EOF
module load qe/gnu-cpu-7.3.1
cd ../../

# qe-7.5
# Optimization level: -O0. mpif90 -> ftn. 
cd ./qe
wget -O qe-7.5.tar.gz https://gitlab.com/QEF/q-e/-/archive/qe-7.5/q-e-qe-7.5.tar.gz
tar -xzvf qe-7.5.tar.gz && mv q-e-qe-7.5 qe-gnu-cpu-7.5
cd qe-gnu-cpu-7.5
mkdir -p $SCRATCH/opt/modulefiles/qe
touch $SCRATCH/opt/modulefiles/qe/gnu-cpu-7.5.lua
CC=cc CXX=CC FC=ftn F90=ftn ./configure \
    --prefix=$(pwd) \
    --with-hdf5=yes --with-hdf5-include=$CRAY_HDF5_PARALLEL_PREFIX/include \
    --with-hdf5-libs="-L$CRAY_HDF5_PARALLEL_PREFIX/lib -lhdf5hl_fortran -lhdf5_hl -lhdf5_fortran -lhdf5 -lz -ldl -lm" \
    --with-libxc=yes --with-libxc-prefix=$SCRATCH/opt/libxc/libxc-gnu-cpu-7.0.0 \
    --with-libxc-include=$SCRATCH/opt/libxc/libxc-gnu-cpu-7.0.0/include
make all -j8 
make epw -j8 
cat > $SCRATCH/opt/modulefiles/qe/gnu-cpu-7.5.lua << 'EOF'
help([[
qe gnu cpu 7.5
]])

prereq('PrgEnv-gnu', 'cray-hdf5-parallel', 'cray-fftw', 'cray-libsci', 'libxc')

local scratch = os.getenv('SCRATCH')
local qe_folder = scratch .. '/opt/qe/qe-gnu-cpu-7.5'

prepend_path('PATH', qe_folder .. '/bin') 
pushenv('QE_ROOT', qe_folder)
EOF
module load qe/gnu-cpu-7.5
cd ../../

# bgw 
cd ./bgw
gh repo clone BerkeleyGW/BerkeleyGW
mv BerkeleyGW bgw-gnu-cpu-4.0.0
cd ./bgw-gnu-cpu-4.0.0
mkdir -p $SCRATCH/opt/modulefiles/bgw
touch $SCRATCH/opt/modulefiles/bgw/gnu-cpu-4.0.0.lua
cp ../../docker_fp/perlmutter/bgw_gnu_cpu_arch.mk ./arch.mk
make all-flavors -j16
# make install INSTDIR=$(pwd)
cat > $SCRATCH/opt/modulefiles/bgw/gnu-cpu-4.0.0.lua << 'EOF'
help([[
bgw gnu cpu 4.0.0
]])

prereq('PrgEnv-gnu', 'cray-hdf5-parallel', 'cray-fftw', 'cray-libsci')

local scratch = os.getenv('SCRATCH')
local bgw_folder = scratch .. '/opt/bgw/bgw-gnu-cpu-4.0.0'

prepend_path('PATH', bgw_folder .. '/bin') 
prepend_path('CPATH', bgw_folder .. '/include') 
prepend_path('LIBRARY_PATH', bgw_folder .. '/lib') 
prepend_path('LD_LIBRARY_PATH', bgw_folder .. '/lib') 
pushenv('BGW_ROOT', bgw_folder)
EOF
module load bgw/gnu-cpu-4.0.0
cd ../../

# Add all packages. 
# cpu-env/gnu-1.0.0
mkdir -p $SCRATCH/opt/modulefiles/cpu-env
touch $SCRATCH/opt/modulefiles/cpu-env/gnu-1.0.0.lua
cat > $SCRATCH/opt/modulefiles/cpu-env/gnu-1.0.0.lua << 'EOF'
help([[
Setup GNU CPU env 1.0.0
]])

load('PrgEnv-gnu/8.6.0')
load('cray-hdf5-parallel/1.12.2.9')
load('cray-libsci/25.09.0')
load('cray-fftw/3.3.10.11')
load('elpa/gnu-cpu-2026.02.001')
load('petsc/gnu-cpu-3.25.0')
load('slepc/gcc-cpu-3.25.0')
load('libxc/gnu-cpu-7.0.0')
load('qe/gnu-cpu-7.3.1')
load('bgw/gnu-cpu-4.0.0')

local cray_ld_library_path = os.getenv('CRAY_LD_LIBRARY_PATH')

prepend_path('LIBRARY_PATH', cray_ld_library_path)
prepend_path('LD_LIBRARY_PATH', cray_ld_library_path)

pushenv('MPICH_GPU_SUPPORT_ENABLED', '0')
pushenv('CRAY_CPU_TARGET', 'x86-64')
EOF
# cpu-env/gnu-2.0.0
mkdir -p $SCRATCH/opt/modulefiles/cpu-env
touch $SCRATCH/opt/modulefiles/cpu-env/gnu-2.0.0.lua
cat > $SCRATCH/opt/modulefiles/cpu-env/gnu-2.0.0.lua << 'EOF'
help([[
Setup GNU CPU env 2.0.0
]])

load('PrgEnv-gnu/8.6.0')
load('cray-hdf5-parallel/1.12.2.9')
load('cray-libsci/25.09.0')
load('cray-fftw/3.3.10.11')
load('elpa/gnu-cpu-2026.02.001')
load('petsc/gnu-cpu-3.25.0')
load('slepc/gcc-cpu-3.25.0')
load('libxc/gnu-cpu-7.0.0')
load('qe/gnu-cpu-7.5')
load('bgw/gnu-cpu-4.0.0')

local cray_ld_library_path = os.getenv('CRAY_LD_LIBRARY_PATH')

prepend_path('LIBRARY_PATH', cray_ld_library_path)
prepend_path('LD_LIBRARY_PATH', cray_ld_library_path)

pushenv('MPICH_GPU_SUPPORT_ENABLED', '0')
pushenv('CRAY_CPU_TARGET', 'x86-64')
EOF