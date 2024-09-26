import sys
from PyQt5.QtWidgets import QApplication

app = QApplication(sys.argv)

import pyvista as pv
from pyvistaqt import BackgroundPlotter

sphere = pv.Sphere()

plotter = BackgroundPlotter()
plotter.add_mesh(sphere)

sys.exit(app.exec_())