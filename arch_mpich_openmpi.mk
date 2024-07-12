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
FFTWLIB      = /usr/local/lib/libfftw3_mpi.a /usr/local/lib/libfftw3_omp.a /usr/local/lib/libfftw3.a
FFTWINCLUDE  = /usr/local/include 
LAPACKLIB    = /usr/local/lib/libopenblas.a
SCALAPACKLIB = /usr/local/lib/libscalapack.a
HDF5LIB      = /usr/local/lib/libhdf5hl_fortran.a /usr/local/lib/libhdf5_hl.a /usr/local/lib/libhdf5_fortran.a /usr/local/lib/libhdf5.a 
HDF5INCLUDE  = /usr/local/include
ELPAINCLUDE  = /usr/local/include
ELPALIB      = /usr/local/lib/libelpa.a