#region: Modules.
import numpy as np
from mpi4py import MPI  
from petsc4py import PETSc
from slepc4py import SLEPc
#endregion

#region: Variables.
#endregion

#region: Functions.
def main():
    comm = MPI.COMM_WORLD
    mpi_rank = comm.Get_rank()
    A = PETSc.Mat().create()
    A.setType(PETSc.Mat.Type.MPIDENSE)
    A.setSizes((4, 4))
    A.setUp()
    A[range(4), range(4)] = np.arange(16).reshape(4, 4)
    A.assemble()

    print(f'Rank: {mpi_rank}, A: {A.getDenseArray()}')

    eps = SLEPc.EPS().create()
    eps.setProblemType(SLEPc.EPS.ProblemType.NHEP)
    eps.setOperators(A)
    eps.setUp()

    eps.solve()

    num_eigs = eps.getConverged()

    for eig_idx in range(num_eigs):
        if mpi_rank==0:
            print(f'eig_idx: {eig_idx}, eig_value: {eps.getEigenvalue(eig_idx)}')
#endregion

#region: Classes.
#endregion

#region: Main.
if __name__=='__main__':
    main()
#endregion