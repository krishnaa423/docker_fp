# arch.mk for NVHPC sm86. 
#
COMPFLAG  = -DNVHPC
PARAFLAG  = -DMPI  -DOMP
MATHFLAG  = -DUSESCALAPACK -DUNPACKED -DUSEFFTW3 -DHDF5 # -DOMP_TARGET  # -DUSEELPA # -DUSEPRIMME
# DEBUGFLAG = -DDEBUG -DNVTX
#

NVCC=nvcc 
NVCCOPT= -O3 -use_fast_math
CUDALIB= -lcufft -lcublasLt -lcublas -lcudart -lcuda -lnvToolsExt

FCPP    = /usr/bin/cpp  -P -ansi -nostdinc -C -E -std=c11    #  -C  -P  -E -ansi  -nostdinc  /usr/bin/cpp
F90free = mpif90 -Mfree -mp=multicore -traceback -Minfo=all,mp -gopt -traceback
LINK    = mpif90        -mp=multicore -Minfo=mp # -lnvToolsExt  
FOPTS   = -fast -Mfree -Mlarge_arrays
FNOOPTS = $(FOPTS)
MOD_OPT = -module  
INCFLAG = -I #./

C_PARAFLAG  = -DPARA -DMPICH_IGNORE_CXX_SEEK
CC_COMP = mpic++
C_COMP  = mpicc
C_LINK  = mpicc -lstdc++ # ${CUDALIB} -lstdc++
C_OPTS  = -fast -mp 
C_DEBUGFLAG =

REMOVE  = /bin/rm -f

FFTW_DIR=/usr/local/lib
FFTWLIB      = $(FFTW_DIR)/libfftw3_mpi.a $(FFTW_DIR)/libfftw3_omp.a $(FFTW_DIR)/libfftw3.a 
FFTWINCLUDE  = /usr/local/include
PERFORMANCE  = 

SCALAPACKLIB = /usr/local/lib/libscalapack.a
LAPACKLIB = ${NVHPC_ROOT}/compilers/lib/liblapack.a ${NVHPC_ROOT}/compilers/lib/libblas.a

HDF5_LDIR    =  /usr/local/lib
HDF5LIB      =  $(HDF5_LDIR)/libhdf5hl_fortran.a \
                $(HDF5_LDIR)/libhdf5_hl.a \
                $(HDF5_LDIR)/libhdf5_fortran.a \
                $(HDF5_LDIR)/libhdf5.a \
                -lm -lz -ldl  -lstdc++
HDF5INCLUDE  = /usr/local/include/