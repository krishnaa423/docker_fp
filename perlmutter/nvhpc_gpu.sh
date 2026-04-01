#!/bin/bash

# misc

# miniconda
conda create -n nvhpc_gpu python=3.10
conda activate nvhpc_gpu
# Fix linker called in conda environment. 
rm -rf $CONDA_ROOT/envs/nvhpc_gpu/compiler_compat/ld
ln -sf /usr/bin/ld $CONDA_ROOT/envs/nvhpc_gpu/compiler_compat/ld
conda install -c conda-forge gh
gh auth login
gh repo clone docker_fp

# mpi4py 
CC=cc MPICC=cc CFLAGS="-noswitcherror" pip install --no-binary=mpi4py mpi4py --force-reinstall --no-cache 

# hdf5, h5py
module load cray-hdf5-parallel/1.14.3.7
wget -O h5py-3.15.1.tar.gz https://github.com/h5py/h5py/archive/refs/tags/3.15.1.tar.gz
tar -xzvf ./h5py-3.15.1.tar.gz
mv ./h5py-3.15.1 ./h5py-nvhpc-gpu-3.15.1
cd ./h5py-nvhpc-gpu-3.15.1
CC=cc HDF5_MPI=ON CFLAGS="-noswitcherror" HDF5_DIR=$CRAY_HDF5_PARALLEL_PREFIX pip install . --no-build-isolation

# openblas
module load cray-libsci/25.09.0

# scalapack
module load cray-libsci/25.09.0

# elpa
wget -O elpa-2025.06.002.tar.gz https://gitlab.mpcdf.mpg.de/elpa/elpa/-/archive/new_release_2025.06.002/elpa-new_release_2025.06.002.tar.gz 
tar -xzvf ./elpa-2025.06.002.tar.gz && mv elpa-new_release* ./elpa-nvhpc-gpu-2025.06.002
cd elpa-nvhpc-gpu-2025.06.002
conda install -c conda-forge autoconf
./autogen.sh 
mkdir -p $SCRATCH_NVHPC_GPU/elpa-2025.06.002
mkdir -p $SCRATCH/modulefiles/elpa-nvhpc-gpu
touch $SCRATCH/modulefiles/elpa-nvhpc-gpu/2025.06.002.lua
CC=cc CXX=CC FC=ftn ./configure --prefix=$SCRATCH_NVHPC_GPU/elpa-2025.06.002 \
    --enable-nvidia-gpu-kernels \
    --with-cuda-path=$CUDA_HOME \
    --with-NVIDIA-GPU-compute-capability=sm_80 \
    --disable-shared \
    --disable-sse \
    --disable-sse-assembly \
    --disable-avx \
    --disable-avx2 \
    --disable-avx512 \
    --disable-c-tests \
    --disable-cpp-tests \
    CFLAGS="-O3 -fPIC" \
    CXXFLAGS="-O3 -fPIC" \
    FCFLAGS="-O3 -fPIC" \
    LDFLAGS="-L$CRAY_LIBSCI_PREFIX/lib -L$CUDA_HOME/lib64" \
    LIBS="-lsci_nvidia_mpi -lsci_nvidia -lcudart -lstdc++"
make -j8 
make install 
cat > $SCRATCH/modulefiles/elpa-nvhpc-gpu/3.24.4.lua << 'EOF'
help([[
elpa nvhpc gpu 2025.06.002
]])

prereq('PrgEnv-nvidia', 'cray-libsci')

local scratch_nvhpc_gpu = os.getenv('SCRATCH_NVHPC_GPU')
local elpa_folder = scratch_nvhpc_gpu .. '/elpa-2025.06.002'

prepend_path('CPATH', elpa_folder .. '/include')
prepend_path('LIBRARY_PATH', elpa_folder .. '/lib')
prepend_path('LD_LIBRARY_PATH', elpa_folder .. '/lib')
setenv('ELPA_ROOT', elpa_folder)
EOF
module load elpa-nvhpc-gpu/2025.06.002
ln -sf $SCRATCH_NVHPC_GPU/elpa-2025.06.002/include/elpa-*/elpa $SCRATCH_NVHPC_GPU//elpa-2025.06.002/include 
cp $SCRATCH_NVHPC_GPU/elpa-2025.06.002/include/elpa-*/modules/* $SCRATCH_NVHPC_GPU/elpa-2025.06.002/include
cd ../ 

# petsc, petsc4py
wget -O petsc-3.24.4.tar.gz https://web.cels.anl.gov/projects/petsc/download/release-snapshots/petsc-3.24.4.tar.gz 
tar -xzvf petsc-3.24.4.tar.gz 
mv petsc-3.24.4 petsc-nvhpc-gpu-3.24.4 
cd petsc-nvhpc-gpu-3.24.4  
mkdir -p $SCRATCH_NVHPC_GPU/petsc-3.24.4
mkdir -p $SCRATCH/modulefiles/petsc-nvhpc-gpu
touch $SCRATCH/modulefiles/petsc-nvhpc-gpu/3.24.4.lua
./configure --with-cc=cc \
    CFLAGS+="-DPETSC_SKIP_REAL___FLOAT128" \
    CXXFLAGS+="-DPETSC_SKIP_REAL___FLOAT128" \
    --with-cxx=CC --with-fc=0 \
    --prefix=$SCRATCH_NVHPC_GPU/petsc-3.24.4 \
    --with-scalar-type=complex --with-precision=double \
    --with-hdf5-dir=$CRAY_HDF5_PARALLEL_PREFIX \
    --with-blas-lib=$CRAY_LIBSCI_PREFIX/lib/libsci_nvidia.a \
    --with-lapack-lib=$CRAY_LIBSCI_PREFIX/lib/libsci_nvidia.a \
    --with-cuda=1 \
    --with-cuda-dir=/opt/nvidia/hpc_sdk/Linux_x86_64/25.5/cuda/12.9
make -j8 
make install 
cd ..
cat > $SCRATCH/modulefiles/petsc-nvhpc-gpu/3.24.4.lua << 'EOF'
help([[
Petsc nvhpc gpu 3.24.4
]])

prereq('PrgEnv-nvidia', 'cray-hdf5-parallel', 'cray-libsci')

local scratch_nvhpc_gpu = os.getenv('SCRATCH_NVHPC_GPU')
local libsci_dir = os.getenv('CRAY_LIBSCI_PREFIX')
local petsc_folder = scratch_nvhpc_gpu .. '/petsc-3.24.4'

prepend_path('CPATH', petsc_folder .. '/include')
prepend_path('LIBRARY_PATH', petsc_folder .. '/lib')
prepend_path('LIBRARY_PATH', libsci_dir .. '/lib')
prepend_path('LD_LIBRARY_PATH', petsc_folder .. '/lib')
prepend_path('LD_LIBRARY_PATH', libsci_dir .. '/lib')
setenv('PETSC_DIR', petsc_folder)
EOF
module load petsc-nvhpc-gpu/3.24.4
wget -O petsc4py-3.24.4.tar.gz https://web.cels.anl.gov/projects/petsc/download/release-snapshots/petsc4py-3.24.4.tar.gz 
tar -xzvf petsc4py-3.24.4.tar.gz && mv petsc4py-3.24.4 petsc4py-nvhpc-gpu-3.24.4 
cd petsc4py-nvhpc-gpu-3.24.4 
cp ../docker_fp/perlmutter/petsc_confpetsc_nvhpc_gpu.py ./conf/confpetsc.py 
CC=cc CFLAGS="-noswitcherror" PETSC_DIR=$SCRATCH_NVHPC_GPU/petsc-3.24.4 pip install . --no-build-isolation
cd ../

# slepc, slepc4py
wget -O slepc-3.24-2.tar.gz https://slepc.upv.es/download/distrib/slepc-3.24.2.tar.gz 
tar -xzvf slepc-3.24-2.tar.gz && mv slepc-3.24.2 slepc-nvhpc-gpu-3.24.2
cd slepc-nvhpc-gpu-3.24-2 
mkdir -p $SCRATCH_NVHPC_GPU/slepc-3.24.2 
mkdir -p $SCRATCH/modulefiles/slepc-nvhpc-gpu 
touch $SCRATCH/modulefiles/slepc-nvhpc-gpu/3.24.2.lua 
CC=cc CXX=CC ./configure --prefix=$SCRATCH_NVHPC_GPU/slepc-3.24.2 
make -j8 
make install
cd .. 
cat > $SCRATCH/modulefiles/slepc-nvhpc-gpu/3.24.2.lua << 'EOF'
help([[
Slepc nvhpc gpu 3.24.2
]])

prereq('PrgEnv-nvidia', 'cray-hdf5-parallel', 'cray-libsci')

local scratch_nvhpc_gpu = os.getenv('SCRATCH_NVHPC_GPU')
local slepc_folder = scratch_nvhpc_gpu .. '/slepc-3.24.2'

prepend_path('CPATH', slepc_folder .. '/include')
prepend_path('LIBRARY_PATH', slepc_folder .. '/lib')
prepend_path('LD_LIBRARY_PATH', slepc_folder .. '/lib')
setenv('SLEPC_DIR', slepc_folder)
EOF
module load slepc-nvhpc-gpu/3.24.2
wget -O slepc4py-3.24.2.tar.gz https://slepc.upv.es/download/distrib/slepc4py-3.24.2.tar.gz 
tar -xzvf slepc4py-3.24.2.tar.gz && mv slepc4py-3.24.2 slepc4py-nvhpc-gpu-3.24.2
cd slepc4py-nvhpc-gpu-3.24.2
cp ../docker_fp/slepc_confpetsc_nvhpc_gpu.py ./conf/confpetsc.py
CC=cc CFLAGS="-noswitcherror" PETSC_DIR=$SCRATCH_NVHPC_GPU/petsc-3.24.4 SLEPC_DIR=$SCRATCH_NVHPC_GPU/slepc-3.24.2 pip install . --no-build-isolation
cd ../

# fftw
module load cray-fftw/3.3.10.11

# libxc, pylibxc
wget -O libxc-7.0.0.tar.gz https://gitlab.com/libxc/libxc/-/archive/7.0.0/libxc-7.0.0.tar.bz2 
tar -xvf libxc-7.0.0.tar.gz && mv libxc-7.0.0 libxc-nvhpc-gpu-7.0.0
cd libxc-nvhpc-gpu-7.0.0
mkdir -p $SCRATCH_NVHPC_GPU/libxc-7.0.0 
mkdir -p $SCRATCH/modulefiles/libxc-nvhpc-gpu
touch $SCRATCH/modulefiles/libxc-nvhpc-gpu/7.0.0.lua
autoreconf -i 
CC=cc FC=ftn ./configure CFLAGS="-fPIC" --prefix=$SCRATCH_NVHPC_GPU/libxc-7.0.0 
make -j8 
make install 
cat > $SCRATCH/modulefiles/libxc-nvhpc-gpu/7.0.0.lua << 'EOF'
help([[
libxc nvhpc gpu 7.0.0
]])

prereq('PrgEnv-nvidia')

local scratch_nvhpc_gpu = os.getenv('SCRATCH_NVHPC_GPU')
local libxc_folder = scratch_nvhpc_gpu .. '/libxc-7.0.0'

prepend_path('PATH', libxc_folder .. '/bin')
prepend_path('CPATH', libxc_folder .. '/include')
prepend_path('LIBRARY_PATH', libxc_folder .. '/lib')
prepend_path('LD_LIBRARY_PATH', libxc_folder .. '/lib')
setenv('LIBXC_ROOT', libxc_folder)
EOF
module load libxc-nvhpc-gpu/7.0.0 
sed -i 's/nprocs = mp.cpu_count()/nprocs = 4  # Limited to prevent OOM/g' setup.py
pip install --no-cache-dir . --no-build-isolation 
cd ../

# qe, perturbo
gh repo clone q-e
mv q-e qe-nvhpc-gpu-7.3.1
cd qe-nvhpc-gpu-7.3.1
git checkout qe-7.3.1-dev
mkdir -p $SCRATCH_NVHPC_GPU/qe-7.3.1 
mkdir -p $SCRATCH/modulefiles/qe-nvhpc-gpu
touch $SCRATCH/modulefiles/qe-nvhpc-gpu/7.3.1.lua
# Skipped libxc install. 
# --with-libxc=yes --with-libxc-prefix=$SCRATCH_NVHPC_GPU/libxc-7.0.0 \
# --with-libxc-include=$SCRATCH_NVHPC_GPU/libxc-7.0.0/include \
CC=cc CXX=CC FC=ftn F90=ftn ./configure \
    --prefix=$SCRATCH_NVHPC_GPU/qe-7.3.1 \
    --with-hdf5=yes --with-hdf5-include=$CRAY_HDF5_PARALLEL_PREFIX/include \
    --with-hdf5-libs="-L$CRAY_HDF5_PARALLEL_PREFIX/lib -lhdf5hl_fortran -lhdf5_hl -lhdf5_fortran -lhdf5 -lz -ldl -lm" \
    --with-cuda=$CUDA_HOME \
    --with-cuda-cc=80 \
    --with-cuda-runtime=$LMOD_FAMILY_CUDATOOLKIT_VERSION 
# make sure to change mpif90 to ftn in make.inc
make all -j8 
make epw -j8 
# perturbo
gh repo clone perturbo
cd perturbo
git checkout develop
cp ../../docker_fp/perlmutter/perturbo_nvhpc_gpu_make.sys ./make.sys
make 
cd ../
make install 
cat > $SCRATCH/modulefiles/qe-nvhpc-gpu/7.3.1.lua << 'EOF'
help([[
qe nvhpc cpu 7.3.1
]])

prereq('PrgEnv-nvidia', 'cray-hdf5-parallel', 'cray-fftw', 'cray-libsci')

local scratch_nvhpc_gpu = os.getenv('SCRATCH_NVHPC_GPU')
local qe_folder = scratch_nvhpc_gpu .. '/qe-7.3.1'

prepend_path('PATH', qe_folder .. '/bin') 
setenv('QE_ROOT', qe_folder)
EOF
module load qe-nvhpc-gpu/7.3.1
cd ../

# bgw
gh repo clone BerkeleyGW
mv BerkeleyGW BerkeleyGW-nvhpc-gpu-4.0.0
cd ./BerkeleyGW-nvhpc-gpu-4.0.0
mkdir -p $SCRATCH_NVHPC_GPU/bgw-4.0.0
mkdir -p $SCRATCH/modulefiles/bgw-nvhpc-gpu
touch $SCRATCH/modulefiles/bgw-nvhpc-gpu/4.0.0.lua
cp ../docker_fp/perlmutter/bgw_gcc_cpu_arch.mk ./arch.mk
make all-flavors -j16
make install INSTDIR=$SCRATCH_NVHPC_GPU/bgw-4.0.0
cat > $SCRATCH/modulefiles/bgw-nvhpc-gpu/4.0.0.lua << 'EOF'
help([[
bgw nvhpc gpu 4.0.0
]])

prereq('PrgEnv-nvidia', 'cray-hdf5-parallel', 'cray-fftw', 'cray-libsci', 'elpa-nvhpc-gpu')

local scratch_nvhpc_gpu = os.getenv('SCRATCH_NVHPC_GPU')
local bgw_folder = scratch_nvhpc_gpu .. '/bgw-4.0.0'

prepend_path('PATH', bgw_folder .. '/bin') 
prepend_path('CPATH', bgw_folder .. '/include') 
prepend_path('LIBRARY_PATH', bgw_folder .. '/lib') 
prepend_path('LD_LIBRARY_PATH', bgw_folder .. '/lib') 
setenv('BGW_ROOT', bgw_folder)
EOF
module load bgw-nvhpc-gpu/4.0.0

# python packages: numpy, pandas, scipy, sympy, matplotlib, seaborn,
# - torch, torchvision, torchaudio, tensorboard, datasets, transformers, diffusers, 
# - langchain, ase, gpaw, pyscf, mp_api, pymatgen, jupyterlab  
pip install cython
pip install numpy pandas scipy sympy matplotlib seaborn cupy 
pip install scikit-learn joblib xgboost
pip install torch torchvision torch_geometric transformers datasets accelerate evaluate diffusers e3nn 
pip install langchain langchain-huggingface
pip install ase pymatgen mp_api pyvista[all] 