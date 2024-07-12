# arch.mk for BerkeleyGW codes
#
# suitable for Frontera at TACC, Cascade Lake (CLX) architecture
# Uses intel compilers + impi
#
# BERKELEYGW DOES NOT WORK WITH INTEL/18 DUE TO A COMPILER BUG!
# ------------------------------------------------------------
#
# You'll need to run:
# module load arpack impi intel/19.0.5 phdf5
#
# Use 'make -j 8' for parallel build on Frontera
#
# Zhenglu Li, MDB
# March 2024, Berkeley
#

COMPFLAG  = -DINTEL
PARAFLAG  = -DMPI -DOMP 
MATHFLAG  = -DUSESCALAPACK -DUNPACKED -DUSEFFTW3 -DHDF5 -DUSEELPA
# Only uncomment DEBUGFLAG if you need to develop/debug BerkeleyGW.
# The output will be much more verbose, and the code will slow down by ~20%.
#DEBUGFLAG = -DDEBUG

FCPP    = cpp -C -nostdinc
F90free = mpiifx -xCORE-AVX512 -free -qopenmp -ip -no-ipo
LINK    = mpiifx -xCORE-AVX512 -qopenmp -ip -no-ipo
# We need the -O2 to pass the testsuite.
# FOPTS   = -O2 -fp-model source
FOPTS   = -O3 -fp-model source
FNOOPTS = -O2 -fp-model source -no-ip
#FOPTS   = -g -O0 -check all -Warn all -traceback
#FNOOPTS = $(FOPTS)
MOD_OPT = -module 
INCFLAG = -I

C_PARAFLAG = -DPARA -DMPICH_IGNORE_CXX_SEEK
CC_COMP = mpiicpx -xCORE-AVX512
C_COMP  = mpiicx -xCORE-AVX512
C_LINK  = mpiicpx -xCORE-AVX512
C_OPTS  = -O3 -ip -no-ipo -qopenmp
C_DEBUGFLAG =

REMOVE  = /bin/rm -f

# Math Libraries
#
MKLPATH      = $(MKLROOT)/lib/intel64

FFTWLIB      =	-Wl,--start-group \
		$(MKLPATH)/libmkl_intel_lp64.a \
		$(MKLPATH)/libmkl_intel_thread.a \
		$(MKLPATH)/libmkl_core.a \
		-Wl,--end-group -liomp5 -lpthread -lm -ldl
FFTWINCLUDE  = $(MKLROOT)/include/fftw


LAPACKLIB    = -Wl,--start-group \
		$(MKLPATH)/libmkl_intel_lp64.a \
		$(MKLPATH)/libmkl_intel_thread.a \
		$(MKLPATH)/libmkl_core.a \
		$(MKLPATH)/libmkl_blacs_intelmpi_lp64.a \
		-Wl,--end-group -liomp5 -lpthread -lm -ldl
SCALAPACKLIB = $(MKLPATH)/libmkl_scalapack_lp64.a

HDF5PATH     = /usr/local/lib
HDF5LIB      =	$(HDF5PATH)/libhdf5hl_fortran.a \
		$(HDF5PATH)/libhdf5_hl.a \
		$(HDF5PATH)/libhdf5_fortran.a \
		$(HDF5PATH)/libhdf5.a 
HDF5INCLUDE  = /usr/local/include 

ELPAINCLUDE=/usr/local/include
ELPALIB=/usr/local/lib/libelpa.a

TESTSCRIPT = 