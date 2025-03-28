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
FFTWLIB      = ${SCRATCH}/lib/libfftw3_mpi.a ${SCRATCH}/lib/libfftw3_omp.a ${SCRATCH}/lib/libfftw3.a
FFTWINCLUDE  = ${SCRATCH}/include
LAPACKLIB    = ${SCRATCH}/lib/libopenblas.a
SCALAPACKLIB = ${SCRATCH}/lib/libscalapack.a
HDF5LIB      = -L${SCRATCH} -lhdf5_hl_fortran -lhdf5_hl -lhdf5_fortran -lhdf5 -lz -ldl -lm 
HDF5INCLUDE  = ${SCRATCH}/include
ELPALIB      = ${SCRATCH}/lib/libelpa.a
ELPAINCLUDE  = ${SCRATCH}/include