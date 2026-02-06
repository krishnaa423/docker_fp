# arch.mk for BerkeleyGW codes
#
# suitable for Frontier ORNL (pass all tests on crusher)
#
# MDB
# 2023, ORNL
# 
# Do (make sure cray-libsci is loaded):
## Should be loaded by default: module load PrgEnv-cray 
# module load cray-fftw ; module load cray-hdf5-parallel
# module load craype-accel-amd-gfx90a
# module load rocm
# module load cray-python
#
#
COMPFLAG  =  # -DAMD_OMPHACK # -DORACLE
PARAFLAG  = -DMPI  -DOMP
MATHFLAG  = -DUSESCALAPACK -DUNPACKED -DUSEFFTW3 -DHDF5 # -DOMP_TARGET -DAMD_GPU
#

# HIP_INC = -I/opt/rocm-5.3.0/hipfort/include/hipfort/amdgcn/ 
HIP_INC = -J/sw/frontier/spack-envs/cpe24.11-cpu/opt/cce-18.0.1/hipfort-6.3.2-z3hwgmvivrfok7lc3mm6fobdhuhlymp4/include/hipfort/amdgcn/ -I${ROCM_PATH}/include/
# HIP_LIB = /opt/rocm-5.3.0/hipfort/lib/libhipfort-amdgcn.a
HIP_LIB = /sw/frontier/spack-envs/cpe24.11-cpu/opt/cce-18.0.1/hipfort-6.3.2-z3hwgmvivrfok7lc3mm6fobdhuhlymp4/lib/libhipfort-amdgcn.a -L${ROCM_PATH}/lib -lamdhip64  -lhipfft -lhipblas

# FCPP    = /usr/bin/cpp -C -E -P  -nostdinc   #  -C  -P  -E  -nostdinc
FCPP    = cpp  -C -E -P  -nostdinc
# F90free = ftn -f free -h omp -hvector0 -DSETDEVICEID -sinteger64 -g -ef ${HIP_INC} ${HIP_LIB} 
# LINK    = ftn -f free -h omp -hvector0 -DSETDEVICEID -sinteger64 -g -ef ${HIP_INC} ${HIP_LIB}
F90free = ftn -f free -fopenmp -g -ef ${HIP_INC} ${HIP_LIB} # -hlist=a
LINK    = ftn -f free -fopenmp -g -ef ${HIP_INC} ${HIP_LIB}
FOPTS   = -O1  # -fast 
FNOOPTS = $(FOPTS)
#MOD_OPT =  -J
MOD_OPT = -J 
INCFLAG = -I 

C_PARAFLAG  = -DPARA -DMPICH_IGNORE_CXX_SEEK
CC_COMP = CC # -x hip
C_COMP  = cc
C_LINK  = CC
C_OPTS  = -O1 -fopenmp # -amdclang
C_DEBUGFLAG =

REMOVE  = /bin/rm -f

# this must be linked if non ESSL blas library is missing are missing 
#               -L$(OLCF_NETLIB_LAPACK_ROOT)/lib64/ -llapack -lblas \

FFTWLIB      = \
               -L$(FFTW_DIR)/ -lfftw3 -lfftw3_threads -lfftw3_omp  ${HIP_LIB}
FFTWINCLUDE  = $(FFTW_INC)/
PERFORMANCE  =

HDF5_LDIR    = $(HDF5_DIR)/lib/
HDF5LIB      = $(HDF5_LDIR)/libhdf5hl_fortran.a \
               $(HDF5_LDIR)/libhdf5_hl.a \
               $(HDF5_LDIR)/libhdf5_fortran.a \
               $(HDF5_LDIR)/libhdf5.a -lm -lz -ldl  -lstdc++ 
HDF5INCLUDE  = $(HDF5_LDIR)/../include


LAPACKLIB = 
SCALAPACKLIB =
#
TESTSCRIPT = 
#