import sys
from PyQt5.QtWidgets import QApplication, QLabel

app = QApplication(sys.argv)

import pyvista as pv
from pyvistaqt import BackgroundPlotter

sphere = pv.Sphere()

plotter = BackgroundPlotter()
plotter.add_mesh(sphere, show_edges=True)

sys.exit(app.exec_())
