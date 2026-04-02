#!/bin/bash

# environment files
#bgw-gpu-env
mkdir -p $SCRATCH/modulefiles/bgw-gpu-env
touch $SCRATCH/modulefiles/bgw-gpu-env/1.0.0.lua
cat > $SCRATCH/modulefiles/bgw-gpu-env/1.0.0.lua << 'EOF'
help([[
Setup BGW GPU env 1.0.0
]])

load('PrgEnv-cray/8.3.3')
-- load('cpe/23.03')
load('cce/15.0.1')
load('rocm/5.3.0')
load('craype-accel-amd-gfx90a')
load('cray-hdf5-parallel')
load('cray-libsci')
load('cray-fftw')

local cray_ld_library_path = os.getenv('CRAY_LD_LIBRARY_PATH')

prepend_path('LIBRARY_PATH', cray_ld_library_path)
prepend_path('LD_LIBRARY_PATH', cray_ld_library_path)

pushenv('MPICH_GPU_SUPPORT_ENABLED', '0')
pushenv('HCC_AMDGPU_TARGET', 'gfx90a')
EOF
#general-gpu-env
mkdir -p $SCRATCH/modulefiles/general-gpu-env
touch $SCRATCH/modulefiles/general-gpu-env/1.0.0.lua
cat > $SCRATCH/modulefiles/general-gpu-env/1.0.0.lua << 'EOF'
help([[
Setup General GPU env 1.0.0
]])

load('PrgEnv-cray/8.6.0')
-- load('cpe/24.1')
load('cce/18.0.1')
load('rocm/6.2.4')
load('craype-accel-amd-gfx90a')
load('cray-hdf5-parallel')
load('cray-libsci')
load('cray-fftw')

local cray_ld_library_path = os.getenv('CRAY_LD_LIBRARY_PATH')

prepend_path('LIBRARY_PATH', cray_ld_library_path)
prepend_path('LD_LIBRARY_PATH', cray_ld_library_path)

pushenv('MPICH_GPU_SUPPORT_ENABLED', '0')
pushenv('HCC_AMDGPU_TARGET', 'gfx90a')
EOF

 # miniconda
 module load general-gpu-env/1.0.0
conda create -n cray_gpu python=3.10
conda activate cray_gpu
# Fix linker called in conda environment. 
rm -rf $CONDA_ROOT/envs/cray_gpu/compiler_compat/ld
ln -sf /usr/bin/ld $CONDA_ROOT/envs/cray_gpu/compiler_compat/ld
conda install -c conda-forge gh
gh auth login
gh repo clone docker_fp

# mpi4py
CC=cc MPICC=cc pip install --no-binary=mpi4py mpi4py --force-reinstall --no-cache 

# hdf5, h5py
module load cray-hdf5-parallel/1.12.2.11
wget -O h5py-3.15.1.tar.gz https://github.com/h5py/h5py/archive/refs/tags/3.15.1.tar.gz
tar -xzvf ./h5py-3.15.1.tar.gz
mv ./h5py-3.15.1 ./h5py-cray-gpu-3.15.1
cd ./h5py-cray-gpu-3.15.1
CC=cc HDF5_MPI=ON HDF5_DIR=$CRAY_HDF5_PARALLEL_PREFIX pip install . --no-build-isolation

# openblas
module load cray-libsci/24.11.0

# scalapack
module load cray-libsci/24.11.0

# elpa
# As per: https://github.com/marekandreas/elpa/blob/master/documentation/INSTALL.md
# AMD with multi node has not been tested. So we will skip it. 

# petsc, petsc4py
wget -O petsc-3.24.4.tar.gz https://web.cels.anl.gov/projects/petsc/download/release-snapshots/petsc-3.24.4.tar.gz 
tar -xzvf petsc-3.24.4.tar.gz 
mv petsc-3.24.4 petsc-cray-gpu-3.24.4 
cd petsc-cray-gpu-3.24.4  
mkdir -p $SCRATCH_CRAY_GPU/petsc-3.24.4
mkdir -p $SCRATCH/modulefiles/petsc-cray-gpu
touch $SCRATCH/modulefiles/petsc-cray-gpu/3.24.4.lua
./configure --with-cc=cc \
    CFLAGS+="-DPETSC_SKIP_REAL___FLOAT128" \
    CXXFLAGS+="-DPETSC_SKIP_REAL___FLOAT128" \
    --with-cxx=CC --with-fc=0 \
    --prefix=$SCRATCH_CRAY_GPU/petsc-3.24.4 \
    --with-scalar-type=complex --with-precision=double \
    --with-hdf5-dir=$CRAY_HDF5_PARALLEL_PREFIX \
    --with-blas-lib=$CRAY_LIBSCI_PREFIX/lib/libsci_cray.a \
    --with-lapack-lib=$CRAY_LIBSCI_PREFIX/lib/libsci_cray.a \
    --with-hip=1
make -j8 
make install 
cd ..
cat > $SCRATCH/modulefiles/petsc-cray-gpu/3.24.4.lua << 'EOF'
help([[
Petsc cray gpu 3.24.4
]])

prereq('PrgEnv-cray', 'cray-hdf5-parallel', 'cray-libsci')

local scratch_cray_gpu = os.getenv('SCRATCH_CRAY_GPU')
local libsci_dir = os.getenv('CRAY_LIBSCI_PREFIX')
local petsc_folder = scratch_cray_gpu .. '/petsc-3.24.4'

prepend_path('CPATH', petsc_folder .. '/include')
prepend_path('LIBRARY_PATH', petsc_folder .. '/lib')
prepend_path('LIBRARY_PATH', libsci_dir .. '/lib')
prepend_path('LD_LIBRARY_PATH', petsc_folder .. '/lib')
prepend_path('LD_LIBRARY_PATH', libsci_dir .. '/lib')
pushenv('PETSC_DIR', petsc_folder)
pushenv('PETSC_OPTIONS', '-use_gpu_aware_mpi 0')
EOF
module load petsc-cray-gpu/3.24.4
wget -O petsc4py-3.24.4.tar.gz https://web.cels.anl.gov/projects/petsc/download/release-snapshots/petsc4py-3.24.4.tar.gz 
tar -xzvf petsc4py-3.24.4.tar.gz && mv petsc4py-3.24.4 petsc4py-cray-gpu-3.24.4 
cd petsc4py-cray-gpu-3.24.4 
cp ../docker_fp/frontier/petsc_confpetsc_cray_cpu.py ./conf/confpetsc.py 
CC=cc PETSC_DIR=$SCRATCH_CRAY_GPU/petsc-3.24.4 pip install . --no-build-isolation
cd ../

# slepc, slepc4py
wget -O slepc-3.24-2.tar.gz https://slepc.upv.es/download/distrib/slepc-3.24.2.tar.gz 
tar -xzvf slepc-3.24-2.tar.gz && mv slepc-3.24.2 slepc-cray-gpu-3.24.2
cd slepc-cray-gpu-3.24.2 
mkdir -p $SCRATCH_CRAY_GPU/slepc-3.24.2 
mkdir -p $SCRATCH/modulefiles/slepc-cray-gpu 
touch $SCRATCH/modulefiles/slepc-cray-gpu/3.24.2.lua 
CC=cc CXX=CC ./configure --prefix=$SCRATCH_CRAY_GPU/slepc-3.24.2 
make -j8 
make install
cd .. 
cat > $SCRATCH/modulefiles/slepc-cray-gpu/3.24.2.lua << 'EOF'
help([[
Slepc cray gpu 3.24.2
]])

prereq('PrgEnv-cray', 'cray-hdf5-parallel', 'cray-libsci')

local scratch_cray_gpu = os.getenv('SCRATCH_CRAY_GPU')
local slepc_folder = scratch_cray_gpu .. '/slepc-3.24.2'

prepend_path('CPATH', slepc_folder .. '/include')
prepend_path('LIBRARY_PATH', slepc_folder .. '/lib')
prepend_path('LD_LIBRARY_PATH', slepc_folder .. '/lib')
pushenv('SLEPC_DIR', slepc_folder)
EOF
module load slepc-cray-gpu/3.24.2
wget -O slepc4py-3.24.2.tar.gz https://slepc.upv.es/download/distrib/slepc4py-3.24.2.tar.gz 
tar -xzvf slepc4py-3.24.2.tar.gz && mv slepc4py-3.24.2 slepc4py-cray-gpu-3.24.2
cd slepc4py-cray-gpu-3.24.2
cp ../docker_fp/frontier/slepc_confpetsc_cray_cpu.py ./conf/confpetsc.py
CC=cc PETSC_DIR=$SCRATCH_CRAY_GPU/petsc-3.24.4 SLEPC_DIR=$SCRATCH_CRAY_GPU/slepc-3.24.2 pip install . --no-build-isolation
cd ../

# fftw
module load cray-fftw/3.3.10.9

# libxc, pylibxc
wget -O libxc-7.0.0.tar.gz https://gitlab.com/libxc/libxc/-/archive/7.0.0/libxc-7.0.0.tar.bz2 
tar -xvf libxc-7.0.0.tar.gz && mv libxc-7.0.0 libxc-cray-gpu-7.0.0
cd libxc-cray-gpu-7.0.0
mkdir -p $SCRATCH_CRAY_GPU/libxc-7.0.0 
mkdir -p $SCRATCH/modulefiles/libxc-cray-gpu
touch $SCRATCH/modulefiles/libxc-cray-gpu/7.0.0.lua
autoreconf -i 
CC=cc FC=ftn ./configure CFLAGS="-fPIC" --prefix=$SCRATCH_CRAY_GPU/libxc-7.0.0 
make -j8 
make install 
cat > $SCRATCH/modulefiles/libxc-cray-gpu/7.0.0.lua << 'EOF'
help([[
libxc cray gpu 7.0.0
]])

prereq('PrgEnv-cray')

local scratch_cray_gpu = os.getenv('SCRATCH_CRAY_GPU')
local libxc_folder = scratch_cray_gpu .. '/libxc-7.0.0'

prepend_path('PATH', libxc_folder .. '/bin')
prepend_path('CPATH', libxc_folder .. '/include')
prepend_path('LIBRARY_PATH', libxc_folder .. '/lib')
prepend_path('LD_LIBRARY_PATH', libxc_folder .. '/lib')
pushenv('LIBXC_ROOT', libxc_folder)
EOF
module load libxc-cray-gpu/7.0.0 
sed -i 's/nprocs = mp.cpu_count()/nprocs = 4  # Limited to prevent OOM/g' setup.py
CC=cc pip install --no-cache-dir . --no-build-isolation 
cd ../

# hipfort
module load bgw-gpu-env/1.0.0
git clone https://github.com/ROCm/hipfort --branch rocm-6.2.4
mv ./hipfort ./hipfort-cpe23.03-cce15.0.1-rocm5.3.0
cd ./hipfort-cpe23.03-cce15.0.1-rocm5.3.0
mkdir -p $SCRATCH_CRAY_GPU/hipfort-5.3.0
mkdir -p $SCRATCH/modulefiles/hipfort-cray-gpu
touch $SCRATCH/modulefiles/hipfort-cray-gpu/5.3.0.lua
rm -rf ./build && mkdir -p build 
cd ./build
cmake ../ \
    -DCMAKE_INSTALL_PREFIX=$SCRATCH_CRAY_GPU/hipfort-5.3.0 \
    -DCMAKE_Fortran_COMPILER=$(which ftn) \
    -DCMAKE_Fortran_FLAGS='-f free -fopenmp -g -eF'
make -j8
make install 
cat > $SCRATCH/modulefiles/hipfort-cray-gpu/5.3.0.lua << 'EOF'
help([[
hipfort cray gpu 5.3.0
]])

prereq('PrgEnv-cray', 'rocm')

local scratch_cray_gpu = os.getenv('SCRATCH_CRAY_GPU')
local hipfort_folder = scratch_cray_gpu .. '/hipfort-5.3.0'

prepend_path('PATH', hipfort_folder .. '/bin')
prepend_path('CPATH', hipfort_folder .. '/include')
prepend_path('LIBRARY_PATH', hipfort_folder .. '/lib')
prepend_path('LD_LIBRARY_PATH', hipfort_folder .. '/lib')
pushenv('HIPFORT_ROOT', hipfort_folder)
EOF
module load hipfort-cray-gpu/5.3.0 
cd ../

# bgw
gh repo clone BerkeleyGW
mv BerkeleyGW BerkeleyGW-cray-gpu-4.0.0
cd ./BerkeleyGW-cray-gpu-4.0.0
mkdir -p $SCRATCH_CRAY_GPU/bgw-4.0.0
mkdir -p $SCRATCH/modulefiles/bgw-cray-gpu
touch $SCRATCH/modulefiles/bgw-cray-gpu/4.0.0.lua
cp ../docker_fp/frontier/bgw_cray_gpu_arch.mk ./arch.mk
make all-flavors -j16
make install INSTDIR=$SCRATCH_CRAY_GPU/bgw-4.0.0
cat > $SCRATCH/modulefiles/bgw-cray-gpu/4.0.0.lua << 'EOF'
help([[
bgw cray gpu 4.0.0
]])

prereq('PrgEnv-cray', 'cray-hdf5-parallel', 'cray-fftw', 'cray-libsci')

local scratch_cray_gpu = os.getenv('SCRATCH_CRAY_GPU')
local bgw_folder = scratch_cray_gpu .. '/bgw-4.0.0'

prepend_path('PATH', bgw_folder .. '/bin') 
prepend_path('CPATH', bgw_folder .. '/include') 
prepend_path('LIBRARY_PATH', bgw_folder .. '/lib') 
prepend_path('LD_LIBRARY_PATH', bgw_folder .. '/lib') 
pushenv('BGW_ROOT', bgw_folder)
EOF
module load bgw-cray-gpu/4.0.0

# python packages: numpy, pandas, scipy, sympy, matplotlib, seaborn,
# - torch, torchvision, torchaudio, tensorboard, datasets, transformers, diffusers, 
# - langchain, ase, gpaw, pyscf, mp_api, pymatgen, jupyterlab  
module load general-gpu-env/1.0.0
pip install cython
pip install numpy pandas scipy sympy matplotlib seaborn
export ROCM_HOME=$ROCM_PATH
export HCC_AMDGPU_TARGET=gfx90a
export CUPY_INSTALL_USE_HIP=1
pip install cupy --force-reinstall --no-cache
pip install scikit-learn joblib xgboost
pip install torch==2.6.0 torchvision==0.21.0 torchaudio==2.6.0 --index-url https://download.pytorch.org/whl/rocm6.2.4
pip install torch_geometric 
pip install pyg_lib torch_scatter torch_sparse torch_cluster torch_spline_conv -f https://data.pyg.org/whl/torch-2.6.0+cpu.html
pip install transformers datasets accelerate evaluate diffusers e3nn 
pip install langchain langchain-huggingface
pip install ase pymatgen mp_api pyvista[all] 