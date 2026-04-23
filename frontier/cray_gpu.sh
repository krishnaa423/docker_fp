#!/bin/bash

# list.
# - gpu-env/nvhpc-1.0.0.
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

# gpu-env/cray-1.0.0.
mkdir -p $SCRATCH/opt/modulefiles/gpu-env
touch $SCRATCH/opt/modulefiles/gpu-env/cray-1.0.0.lua
cat > $SCRATCH/opt/modulefiles/gpu-env/cray-1.0.0.lua << 'EOF'
help([[
Setup CRAY GPU env 1.0.0
]])

load('PrgEnv-cray/8.6.0')
load('cce/20.0.0')
load('cpe/25.09')
load('rocm/6.4.2')
load('craype-accel-amd-gfx90a')
load('cray-hdf5-parallel')
load('cray-libsci')
load('cray-fftw')

local cray_ld_library_path = os.getenv('CRAY_LD_LIBRARY_PATH')

prepend_path('LIBRARY_PATH', cray_ld_library_path)
prepend_path('LD_LIBRARY_PATH', cray_ld_library_path)

pushenv('MPICH_GPU_SUPPORT_ENABLED', '0')
pushenv('HCC_AMDGPU_TARGET', 'gfx90a')
pushenv('CUPY_INSTALL_USE_HIP', '1')
pushenv('PETSC_OPTIONS', '-use_gpu_aware_mpi 0')
EOF
cd $SCRATCH/opt
module load gpu-env/cray-1.0.0

# miniconda
conda create -n cray_gpu python=3.10 -y
conda activate cray_gpu
# Fix linker called in conda environment. 
rm -rf $CONDA_ROOT/envs/cray_gpu/compiler_compat/ld
ln -sf /usr/bin/ld $CONDA_ROOT/envs/cray_gpu/compiler_compat/ld
conda install -c conda-forge gh -y
gh auth login
gh repo clone docker_fp

# python packages: numpy, pandas, scipy, sympy, matplotlib, seaborn,
# - torch, torchvision, torchaudio, tensorboard, datasets, transformers, diffusers, 
# - langchain, ase, gpaw, pyscf, mp_api, pymatgen, jupyterlab  
pip install cython --no-cache-dir
pip install numpy pandas scipy sympy matplotlib seaborn --no-cache-dir
export ROCM_HOME=$ROCM_PATH
export HCC_AMDGPU_TARGET=gfx90a
export CUPY_INSTALL_USE_HIP=1
pip install cupy --force-reinstall --no-cache-dir
pip install scikit-learn joblib xgboost --no-cache-dir
pip install torch==2.6.0 torchvision==0.21.0 torchaudio==2.6.0 --index-url https://download.pytorch.org/whl/rocm6.2.4  --no-cache-dir
pip install torch_geometric --no-cache-dir
pip install pyg_lib torch_scatter torch_sparse torch_cluster torch_spline_conv -f https://data.pyg.org/whl/torch-2.6.0+cpu.html --no-cache-dir
pip install transformers datasets accelerate evaluate diffusers e3nn --no-cache-dir
pip install langchain langchain-huggingface --no-cache-dir
pip install ase pymatgen mp_api pyvista[all] --no-cache-dir

# mpi4py
CC=cc MPICC=cc pip install --no-binary=mpi4py mpi4py --force-reinstall --no-cache 

# hdf5, h5py
cd ./h5py
module load cray-hdf5-parallel
wget -O h5py-3.15.1.tar.gz https://github.com/h5py/h5py/archive/refs/tags/3.15.1.tar.gz
tar -xzvf ./h5py-3.15.1.tar.gz
mv ./h5py-3.15.1 ./h5py-cray-gpu-3.15.1
cd ./h5py-cray-gpu-3.15.1
CC=cc HDF5_MPI=ON HDF5_DIR=$CRAY_HDF5_PARALLEL_PREFIX pip install . \
  --no-build-isolation \
  --no-cache-dir \
  --force-reinstall
cd ../../

# openblas
module load cray-libsci

# scalapack
module load cray-libsci

# elpa
# As per: https://github.com/marekandreas/elpa/blob/master/documentation/INSTALL.md
# AMD with multi node has not been tested. So we will skip it. 

# petsc, petsc4py
wget -O petsc-3.25.0.tar.gz https://web.cels.anl.gov/projects/petsc/download/release-snapshots/petsc-3.25.0.tar.gz 
tar -xzvf petsc-3.25.0.tar.gz 
mv petsc-3.25.0 petsc-cray-gpu-3.25.0
cd petsc-cray-gpu-3.25.0
mkdir -p $SCRATCH/opt/modulefiles/petsc
touch $SCRATCH/opt/modulefiles/petsc/cray-gpu-3.25.0.lua
./configure --with-cc=cc \
    CFLAGS+="-DPETSC_SKIP_REAL___FLOAT128" \
    CXXFLAGS+="-DPETSC_SKIP_REAL___FLOAT128" \
    --with-cxx=CC --with-fc=0 \
    --with-scalar-type=complex --with-precision=double \
    --with-hdf5-dir=$CRAY_HDF5_PARALLEL_PREFIX \
    --with-blas-lib=$CRAY_LIBSCI_PREFIX/lib/libsci_cray.a \
    --with-lapack-lib=$CRAY_LIBSCI_PREFIX/lib/libsci_cray.a \
    --with-hip=1
make -j8 
# make install 
cat > $SCRATCH/opt/modulefiles/petsc/cray-gpu-3.25.0.lua << 'EOF'
help([[
Petsc cray gpu 3.25.0
]])

prereq('PrgEnv-cray', 'cray-hdf5-parallel', 'cray-libsci')

local scratch = os.getenv('SCRATCH')
local libsci_dir = os.getenv('CRAY_LIBSCI_PREFIX')
local petsc_dir = scratch .. '/opt/petsc/petsc-cray-gpu-3.25.0'
local petsc_folder = scratch .. '/opt/petsc/petsc-cray-gpu-3.25.0/arch-linux-c-debug'

prepend_path('CPATH', petsc_folder .. '/include')
prepend_path('LIBRARY_PATH', petsc_folder .. '/lib')
prepend_path('LIBRARY_PATH', libsci_dir .. '/lib')
prepend_path('LD_LIBRARY_PATH', petsc_folder .. '/lib')
prepend_path('LD_LIBRARY_PATH', libsci_dir .. '/lib')
pushenv('PETSC_DIR', petsc_dir)
pushenv('PETSC_ARCH', 'arch-linux-c-debug')
EOF
cd ../../
module load petsc/cray-gpu-3.25.0
cd ./petsc4py
wget -O petsc4py-3.25.0.tar.gz https://web.cels.anl.gov/projects/petsc/download/release-snapshots/petsc4py-3.25.0.tar.gz 
tar -xzvf petsc4py-3.25.0.tar.gz && mv petsc4py-3.25.0 petsc4py-cray-gpu-3.25.0
cd petsc4py-cray-gpu-3.25.0
cp ../../docker_fp/frontier/petsc_confpetsc_cray_cpu.py ./conf/confpetsc.py 
CC=cc CXX=CC pip install . --no-build-isolation --no-cache-dir --force-reinstall
cd ../../

# slepc, slepc4py
wget -O slepc-3.25.0.tar.gz https://slepc.upv.es/download/distrib/slepc-3.25.0.tar.gz 
tar -xzvf slepc-3.25.0.tar.gz && mv slepc-3.25.0 slepc-cray-gpu-3.25.0
cd slepc-cray-gpu-3.25.0 
mkdir -p $SCRATCH/opt/modulefiles/slepc
touch $SCRATCH/opt/modulefiles/slepc/cray-gpu-3.25.0.lua 
CC=cc CXX=CC ./configure
make -j8 
# make install
cd ../../
cat > $SCRATCH/opt/modulefiles/slepc/cray-gpu-3.25.0.lua << 'EOF'
help([[
Slepc cray gpu 3.25.0
]])

prereq('PrgEnv-cray', 'cray-hdf5-parallel', 'cray-libsci')

local scratch = os.getenv('SCRATCH')
local slepc_dir = scratch .. '/opt/slepc/slepc-cray-gpu-3.25.0'
local slepc_folder = scratch .. '/opt/slepc/slepc-cray-gpu-3.25.0/arch-linux-c-debug'

prepend_path('CPATH', slepc_folder .. '/include')
prepend_path('LIBRARY_PATH', slepc_folder .. '/lib')
prepend_path('LD_LIBRARY_PATH', slepc_folder .. '/lib')
pushenv('SLEPC_DIR', slepc_dir)
EOF
module load slepc/cray-gpu-3.25.0
cd ./slepc4py
wget -O slepc4py-3.25.0.tar.gz https://slepc.upv.es/download/distrib/slepc4py-3.25.0.tar.gz 
tar -xzvf slepc4py-3.25.0.tar.gz && mv slepc4py-3.25.0 slepc4py-cray-gpu-3.25.0
cd slepc4py-cray-gpu-3.25.0
cp ../../docker_fp/frontier/slepc_confpetsc_cray_cpu.py ./conf/confpetsc.py
CC=cc pip install . --no-build-isolation --no-cache-dir --force-reinstall
cd ../../

# fftw
module load cray-fftw/3.3.10.9

# libxc, pylibxc
cd ./libxc
wget -O libxc-7.0.0.tar.gz https://gitlab.com/libxc/libxc/-/archive/7.0.0/libxc-7.0.0.tar.bz2 
tar -xvf libxc-7.0.0.tar.gz && mv libxc-7.0.0 libxc-cray-gpu-7.0.0
cd libxc-cray-gpu-7.0.0
mkdir -p $SCRATCH/opt/modulefiles/libxc
touch $SCRATCH/opt/modulefiles/libxc/cray-gpu-7.0.0.lua
autoreconf -i 
CC=cc FC=ftn ./configure CFLAGS="-fPIC" --prefix=$(pwd)
make -j8 
make install 
cat > $SCRATCH/opt/modulefiles/libxc/cray-gpu-7.0.0.lua << 'EOF'
help([[
libxc cray gpu 7.0.0
]])

prereq('PrgEnv-cray')

local scratch = os.getenv('SCRATCH')
local libxc_folder = scratch .. '/opt/libxc/libxc-cray-gpu-7.0.0'

prepend_path('PATH', libxc_folder .. '/bin')
prepend_path('CPATH', libxc_folder .. '/include')
prepend_path('LIBRARY_PATH', libxc_folder .. '/lib')
prepend_path('LD_LIBRARY_PATH', libxc_folder .. '/lib')
pushenv('LIBXC_ROOT', libxc_folder)
EOF
module load libxc/cray-gpu-7.0.0 
sed -i 's/nprocs = mp.cpu_count()/nprocs = 4  # Limited to prevent OOM/g' setup.py
pip install --no-cache-dir . --no-build-isolation
cd ../../

# qe-7.3.1
cd ./qe
git clone https://gitlab.com/QEF/q-e.git
mv q-e ./qe-cray-gpu-7.3.1
cd qe-cray-gpu-7.3.1
git checkout tags/qe-7.3.1
mkdir -p $SCRATCH/opt/modulefiles/qe
touch $SCRATCH/opt/modulefiles/qe/cray-gpu-7.3.1.lua
CC=cc CXX=CC FC=ftn F90=ftn ./configure \
    ARCH=craype \
    --prefix=$(pwd) \
    --with-hdf5=yes --with-hdf5-include=$CRAY_HDF5_PARALLEL_PREFIX/include \
    --with-hdf5-libs="-L$CRAY_HDF5_PARALLEL_PREFIX/lib -lhdf5hl_fortran -lhdf5_hl -lhdf5_fortran -lhdf5 -lz -ldl -lm" \
    BLAS_LIBS="-L$CRAY_LIBSCI_PREFIX/lib -lsci_cray" \
    LAPACK_LIBS="-L$CRAY_LIBSCI_PREFIX/lib -lsci_cray" \
    SCALAPACK_LIBS="-L$CRAY_LIBSCI_PREFIX/lib -lsci_cray_mpi" \
    FFTW_INCLUDE="$FFTW_ROOT/include" \
    FFTW_LIBS="-L$FFTW_ROOT/lib -lfftw3_mpi -lfftw3_threads -lfftw3"
make all 
make epw -j8 
# perturbo
gh repo clone perturbo
cd perturbo
git checkout develop
cp ../../../docker_fp/frontier/perturbo_cray_cpu_make.sys ./make.sys
make 
cd ../
make install
cp ./external/wannier90/utility/kmesh.pl ./bin/kmesh.pl
cat > $SCRATCH/opt/modulefiles/qe/cray-gpu-7.3.1.lua << 'EOF'
help([[
qe cray cpu 7.3.1
]])

prereq('PrgEnv-cray', 'cray-hdf5-parallel', 'cray-fftw', 'cray-libsci')

local scratch = os.getenv('SCRATCH')
local qe_folder = scratch .. '/opt/qe/qe-cray-gpu-7.3.1'
local perturbo_folder = scratch .. '/opt/qe/qe-cray-gpu-7.3.1/perturbo'

prepend_path('PATH', qe_folder .. '/bin') 
prepend_path('PATH', perturbo_folder .. '/bin') 
pushenv('QE_ROOT', qe_folder)
EOF
module load qe/cray-gpu-7.3.1
cd ../../

# qe-7.5
# Remove -eF and add -eZ to F90FLAGS. -O0 too.
cd ./qe
git clone https://gitlab.com/QEF/q-e.git
mv q-e ./qe-cray-gpu-7.5
cd qe-cray-gpu-7.5
git checkout tags/qe-7.5
mkdir -p $SCRATCH/opt/modulefiles/qe
touch $SCRATCH/opt/modulefiles/qe/cray-gpu-7.5.lua
CC=cc CXX=CC FC=ftn F90=ftn ./configure \
    ARCH=craype \
    --prefix=$(pwd) \
    --with-hdf5=yes --with-hdf5-include=$CRAY_HDF5_PARALLEL_PREFIX/include \
    --with-hdf5-libs="-L$CRAY_HDF5_PARALLEL_PREFIX/lib -lhdf5hl_fortran -lhdf5_hl -lhdf5_fortran -lhdf5 -lz -ldl -lm" \
    BLAS_LIBS="-L$CRAY_LIBSCI_PREFIX/lib -lsci_cray" \
    LAPACK_LIBS="-L$CRAY_LIBSCI_PREFIX/lib -lsci_cray" \
    SCALAPACK_LIBS="-L$CRAY_LIBSCI_PREFIX/lib -lsci_cray_mpi" \
    FFTW_INCLUDE="$FFTW_ROOT/include" \
    FFTW_LIBS="-L$FFTW_ROOT/lib -lfftw3_mpi -lfftw3_threads -lfftw3"
python3 -c "
with open('PW/src/dynamics_module.f90', 'r') as f:
    lines = f.readlines()

fixes = {
    440: \"                     & 5X,\\\"Ekin + Etot (const)   = \\\",F20.8,\\\" Ry\\\")' ) &\\n\",
    444: \"                     &   5X,\\\"Ekin + Etot + Ions Nose =\\\",F20.8,\\\" Ry\\\")')  &\\n\",
    738: \"                     & 5X,\\\"Ekin + Etot (const)   = \\\",F20.8,\\\" Ry\\\")' ) &\\n\",
    742: \"                     &   5X,\\\"Ekin + Etot + Ions Nose =\\\",F20.8,\\\" Ry\\\")')  &\\n\",
}

for lineno, newline in fixes.items():
    lines[lineno-1] = newline

with open('PW/src/dynamics_module.f90', 'w') as f:
    f.writelines(lines)
print('Done')
"
make all 
make epw -j8 
cp ./external/wannier90/utility/kmesh.pl ./bin/kmesh.pl
cat > $SCRATCH/opt/modulefiles/qe/cray-gpu-7.5.lua << 'EOF'
help([[
qe cray gpu 7.5
]])

prereq('PrgEnv-cray', 'cray-hdf5-parallel', 'cray-fftw', 'cray-libsci')

local scratch = os.getenv('SCRATCH')
local qe_folder = scratch .. '/opt/qe/qe-cray-gpu-7.5'

prepend_path('PATH', qe_folder .. '/bin') 
pushenv('QE_ROOT', qe_folder)
EOF
module load qe/cray-gpu-7.5
cd ../../

# hipfort
cd ./hipfort
git clone https://github.com/ROCm/hipfort --branch rocm-6.2.4
mv ./hipfort ./hipfort-rocm-6.2.4
cd ./hipfort-rocm-6.2.4
mkdir -p $SCRATCH/opt/modulefiles/hipfort
touch $SCRATCH/opt/modulefiles/hipfort/cray-gpu-6.2.4.lua
rm -rf ./build && mkdir -p build 
cd ./build
# cmake ../ \
#     -DCMAKE_INSTALL_PREFIX=$SCRATCH/opt/hipfort/hipfort-rocm-6.2.4 \
#     -DCMAKE_Fortran_COMPILER=$(which ftn) \
#     -DCMAKE_Fortran_FLAGS='-f free -fopenmp -g -eF'
cmake ../ \
    -DCMAKE_INSTALL_PREFIX=$SCRATCH/opt/hipfort/hipfort-rocm-6.2.4 \
    -DCMAKE_Fortran_COMPILER=$(which ftn) \
    -DHIPFORT_COMPILER_FLAGS='-f free -eZ'
make -j8
make install 
cat > $SCRATCH/opt/modulefiles/hipfort/cray-gpu-6.2.4.lua << 'EOF'
help([[
hipfort cray gpu 6.2.4
]])

prereq('PrgEnv-cray', 'rocm')

local scratch = os.getenv('SCRATCH')
local hipfort_folder = scratch .. '/opt/hipfort/hipfort-rocm-6.2.4'

prepend_path('PATH', hipfort_folder .. '/bin')
prepend_path('CPATH', hipfort_folder .. '/include')
prepend_path('LIBRARY_PATH', hipfort_folder .. '/lib')
prepend_path('LD_LIBRARY_PATH', hipfort_folder .. '/lib')
pushenv('HIPFORT_ROOT', hipfort_folder)
EOF
module load hipfort/cray-gpu-6.2.4 
cd ../../

# bgw
cd ./bgw
gh repo clone BerkeleyGW/BerkeleyGW
mv BerkeleyGW bgw-cray-gpu-4.0.0
cd ./bgw-cray-gpu-4.0.0
mkdir -p $SCRATCH/opt/modulefiles/bgw
touch $SCRATCH/opt/modulefiles/bgw/cray-gpu-4.0.0.lua
cp ../../docker_fp/frontier/bgw_cray_gpu_arch.mk ./arch.mk
make all-flavors -j16
# make install INSTDIR=$(pwd)
cat > $SCRATCH/opt/modulefiles/bgw/cray-gpu-4.0.0.lua << 'EOF'
help([[
bgw cray gpu 4.0.0
]])

prereq('PrgEnv-cray', 'cray-hdf5-parallel', 'cray-fftw', 'cray-libsci')

local scratch = os.getenv('SCRATCH')
local bgw_folder = scratch .. '/opt/bgw/bgw-cray-gpu-4.0.0'

prepend_path('PATH', bgw_folder .. '/bin') 
prepend_path('CPATH', bgw_folder .. '/include') 
prepend_path('LIBRARY_PATH', bgw_folder .. '/lib') 
prepend_path('LD_LIBRARY_PATH', bgw_folder .. '/lib') 
pushenv('BGW_ROOT', bgw_folder)
EOF
module load bgw/cray-gpu-4.0.0
cd ../../

# Add all packages. 
# gpu-env/cray-1.0.0
mkdir -p $SCRATCH/opt/modulefiles/gpu-env
touch $SCRATCH/opt/modulefiles/gpu-env/cray-1.0.0.lua
cat > $SCRATCH/opt/modulefiles/gpu-env/cray-1.0.0.lua << 'EOF'
help([[
Setup CRAY GPU env 1.0.0
]])

load('PrgEnv-cray/8.6.0')
load('cce/20.0.0')
load('cpe/25.09')
load('rocm/6.4.2')
load('craype-accel-amd-gfx90a')
load('cray-hdf5-parallel')
load('cray-libsci')
load('cray-fftw')
load('petsc/cray-gpu-3.25.0')
load('slepc/cray-gpu-3.25.0')
load('libxc/cray-gpu-7.0.0 ')
load('qe/cray-gpu-7.3.1')
load('hipfort/cray-gpu-6.2.4')
load('bgw/cray-gpu-4.0.0')

local cray_ld_library_path = os.getenv('CRAY_LD_LIBRARY_PATH')

prepend_path('LIBRARY_PATH', cray_ld_library_path)
prepend_path('LD_LIBRARY_PATH', cray_ld_library_path)

pushenv('MPICH_GPU_SUPPORT_ENABLED', '0')
pushenv('HCC_AMDGPU_TARGET', 'gfx90a')
pushenv('CUPY_INSTALL_USE_HIP', '1')
pushenv('PETSC_OPTIONS', '-use_gpu_aware_mpi 0')
EOF
# gpu-env/cray-2.0.0
mkdir -p $SCRATCH/opt/modulefiles/gpu-env
touch $SCRATCH/opt/modulefiles/gpu-env/cray-2.0.0.lua
cat > $SCRATCH/opt/modulefiles/gpu-env/cray-2.0.0.lua << 'EOF'
help([[
Setup CRAY GPU env 2.0.0
]])

load('PrgEnv-cray/8.6.0')
load('cce/20.0.0')
load('cpe/25.09')
load('rocm/6.4.2')
load('craype-accel-amd-gfx90a')
load('cray-hdf5-parallel')
load('cray-libsci')
load('cray-fftw')
load('petsc/cray-gpu-3.25.0')
load('slepc/cray-gpu-3.25.0')
load('libxc/cray-gpu-7.0.0 ')
load('qe/cray-gpu-7.5')
load('hipfort/cray-gpu-6.2.4')
load('bgw/cray-gpu-4.0.0')

local cray_ld_library_path = os.getenv('CRAY_LD_LIBRARY_PATH')

prepend_path('LIBRARY_PATH', cray_ld_library_path)
prepend_path('LD_LIBRARY_PATH', cray_ld_library_path)

pushenv('MPICH_GPU_SUPPORT_ENABLED', '0')
pushenv('HCC_AMDGPU_TARGET', 'gfx90a')
pushenv('CUPY_INSTALL_USE_HIP', '1')
pushenv('PETSC_OPTIONS', '-use_gpu_aware_mpi 0')
EOF