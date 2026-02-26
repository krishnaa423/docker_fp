# arch.mk for BerkeleyGW codes
#
# suitable for Perlmutter
#
# MDB
# 2024, Perlmutter@NERSC
# NVHPC compiler
# 
# Do:
# module swap PrgEnv-gnu PrgEnv-nvhpc ; module load cray-hdf5-parallel ; module load cray-fftw ; module load cray-libsci ; module load python
#
#
COMPFLAG  = -DNVHPC -DNVHPC_API -DNVIDIA_GPU
PARAFLAG  = -DMPI  -DOMP
MATHFLAG  = -DUSESCALAPACK -DUNPACKED -DUSEFFTW3 -DHDF5 -DOMP_TARGET -DOPENACC -DUSEELPA  # -DUSEPRIMME # -DUSEELPA # USEELPA_GPU
# DEBUGFLAG = -DDEBUG -DNVTX
#

NVCC=nvcc
NVCCOPT= -O3 -use_fast_math
CUDA_LIBDIR ?= ${CUDA_HOME}/lib64
CUDALIB= -L$(CUDA_LIBDIR) -lcufft -lcublasLt -lcublas -lcusolver -lcudart -lcuda

FCPP    = /usr/bin/cpp  -C   -nostdinc   #  -C  -P  -E -ansi  -nostdinc  /usr/bin/cpp
F90free = ftn -Mfree -acc -mp=multicore,gpu -gpu=cc80  -cudalib=cublas,cufft -traceback -Minfo=all,mp,acc -gopt -traceback
LINK    = ftn        -acc -mp=multicore,gpu -gpu=cc80  -cudalib=cublas,cufft -Minfo=mp,acc # -lnvToolsExt  
FOPTS   = -fast -Mfree -Mlarge_arrays
FNOOPTS = $(FOPTS)
MOD_OPT = -module  
INCFLAG = -I #./

C_PARAFLAG  = -DPARA -DMPICH_IGNORE_CXX_SEEK
CC_COMP = CC
C_COMP  = cc
C_LINK  = cc -lstdc++ # ${CUDALIB} -lstdc++
C_OPTS  = -fast -mp 
C_DEBUGFLAG =

REMOVE  = /bin/rm -f

# FFTW_DIR=
FFTWLIB      = $(FFTW_DIR)/libfftw3.so \
               $(FFTW_DIR)/libfftw3_threads.so \
               $(FFTW_DIR)/libfftw3_omp.so \
               ${CUDALIB}  -lstdc++
FFTWINCLUDE  = $(FFTW_INC)
PERFORMANCE  = 

SCALAPACKLIB = 
LAPACKLIB = 

HDF5_LDIR    =  ${HDF5_DIR}/lib/
HDF5LIB      =  -L${HDF5_LDIR} -lhdf5hl_fortran \
                -lhdf5_hl \
                -lhdf5_fortran \
                -lhdf5 -lz -ldl -lm
HDF5INCLUDE  = ${HDF5_DIR}/include/

ELPAINCLUDE=${SCRATCH_NVHPC_GPU}/elpa-2025.06.002/include
ELPALIB=${SCRATCH_NVHPC_GPU}/elpa-2025.06.002/lib/libelpa.a ${CUDALIB} -lstdc++

# ELPALIB = /pscratch/home/mdelben/LIBS_local/ELPA/elpa-2021.11.001/build/lib/libelpa.a -lstdc++
# ELPAINCLUDE = /pscratch/home/mdelben/LIBS_local/ELPA/elpa-2021.11.001/build/include/elpa-2021.11.001/modules/

# PRIMMELIB = /global/homes/m/mdelben/perlmutter/PRIMME/primme-3.1.1/lib/libprimme.a
# PRIMMEINC = /global/homes/m/mdelben/perlmutter/PRIMME/primme-3.1.1/include/
