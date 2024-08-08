"""User provided customizations.

Here one changes the default arguments for compiling _gpaw.so.

Here are all the lists that can be modified:

* libraries
  List of libraries to link: -l<lib1> -l<lib2> ...
* library_dirs
  Library search directories: -L<dir1> -L<dir2> ...
* include_dirs
  Header search directories: -I<dir1> -I<dir2> ...
* extra_link_args
  Arguments forwarded directly to linker
* extra_compile_args
  Arguments forwarded directly to compiler
* runtime_library_dirs
  Runtime library search directories: -Wl,-rpath=<dir1> -Wl,-rpath=<dir2> ...
* extra_objects
* define_macros

To override use the form:

    libraries = ['somelib', 'otherlib']

To append use the form

    libraries += ['somelib', 'otherlib']
"""

# flake8: noqa

# compiler = 'gcc'
# platform_id = ''

# MPI:
import os 
mpi= True 
compiler = 'mpicc'

# Include files:
include_dirs += [f'{os.environ["MPI_GCC_GPU_ROOT"]}/include', f'{os.environ["SCRATCH_GCC_GPU"]}/include']
library_dirs += [f'{os.environ["MPI_GCC_GPU_ROOT"]}/lib', f'{os.environ["SCRATCH_GCC_GPU"]}/lib']
runtime_library_dirs += [f'{os.environ["MPI_GCC_GPU_ROOT"]}/lib', f'{os.environ["SCRATCH_GCC_GPU"]}/lib']

# BLAS.
# extra_link_args += [f'{os.environ["SCRATCH_GCC_GPU"]}/lib/libopenblas.a']
libraries += ['openblas']

# FFTW3.
fftw = True 
# extra_link_args += [f'{os.environ["SCRATCH_GCC_GPU"]}/lib/libfftw3.a']
libraries += ['fftw3']

# ScaLAPACK (version 2.0.1+ required).
scalapack = True 
# extra_link_args += [f'{os.environ["SCRATCH_GCC_GPU"]}/lib/libscalapack.a']
libraries += ['scalapack']

# LibXC.
# extra_link_args += [f'{os.environ["SCRATCH_GCC_GPU"]}/lib/libxc.a']
libraries += ['xc']

# # ELPA.
# elpa = True 
# extra_link_args += [f'{os.environ["SCRATCH_GCC_GPU"]}/libelpa.a']
