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
F90free = ftn -ffree-form -ffree-line-length-none -fno-second-underscore -fopenmp -fallow-argument-mismatch
LINK    = ftn -fopenmp -fallow-argument-mismatch
FOPTS   = -O0 -g
FNOOPTS = $(FOPTS)
MOD_OPT = -J
INCFLAG = -I

C_PARAFLAG = -DPARA
CC_COMP = CC -fopenmp
C_COMP  = cc -fopenmp
C_LINK  = CC -fopenmp
C_OPTS  = -O0 -g
# C_DEBUGFLAG =

REMOVE  = /bin/rm -f

# Math Libraries
FFTWLIB      = 
FFTWINCLUDE  = 
LAPACKLIB    = 
SCALAPACKLIB = 
HDF5LIB      = -L${CRAY_HDF5_PARALLEL_PREFIX}/lib -lhdf5hl_fortran -lhdf5_hl -lhdf5_fortran -lhdf5 -lz -ldl -lm 
HDF5INCLUDE  = ${CRAY_HDF5_PARALLEL_PREFIX}/include
ELPALIB      = ${ELPA_ROOT}/lib/libelpa.a
ELPAINCLUDE  = ${ELPA_ROOT}/include