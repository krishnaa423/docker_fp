# arch.mk for WSL2 Ubuntu. 
#
# Krishnaa Vadivel 

# Math and parallelization flags. 
COMPFLAG  = -DGNU
PARAFLAG  = -DMPI -DOMP
MATHFLAG  = -DUSESCALAPACK -DUNPACKED -DUSEFFTW3 -DHDF5 -DUSEELPA
# Only uncomment DEBUGFLAG if you need to develop/debug BerkeleyGW.
# The output will be much more verbose, and the code will slow down by ~20%.
#DEBUGFLAG = -DDEBUG

# Compiler flags. 
FCPP    = cpp -C -nostdinc
F90free = mpif90 -ffree-form -ffree-line-length-none -fno-second-underscore -fopenmp
LINK    = mpif90 -fopenmp
FOPTS   = -O0 -g
FNOOPTS = $(FOPTS)
MOD_OPT = -J
INCFLAG = -I

C_PARAFLAG = -DPARA
CC_COMP = mpic++ -fopenmp
C_COMP  = mpicc -fopenmp
C_LINK  = mpic++ -fopenmp
C_OPTS  = -O0 -g
# C_DEBUGFLAG =

REMOVE  = /bin/rm -f

# Math Libraries
FFTWLIB      = ${SCRATCH_GCC_GPU}/lib/libfftw3_mpi.a ${SCRATCH_GCC_GPU}/lib/libfftw3_omp.a ${SCRATCH_GCC_GPU}/lib/libfftw3.a
FFTWINCLUDE  = ${SCRATCH_GCC_GPU}/include
LAPACKLIB    = ${SCRATCH_GCC_GPU}/lib/libopenblas.a
SCALAPACKLIB = ${SCRATCH_GCC_GPU}/lib/libscalapack.a
HDF5LIB      = ${SCRATCH_GCC_GPU}/lib/libhdf5hl_fortran.a ${SCRATCH_GCC_GPU}/lib/libhdf5_hl.a ${SCRATCH_GCC_GPU}/lib/libhdf5_fortran.a ${SCRATCH_GCC_GPU}/lib/libhdf5.a # -lz -ldl
HDF5INCLUDE  = ${SCRATCH_GCC_GPU}/include
ELPALIB      = ${SCRATCH_GCC_GPU}/lib/libelpa.a
ELPAINCLUDE  = ${SCRATCH_GCC_GPU}/include