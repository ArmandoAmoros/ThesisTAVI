# CatheterDOFSim

There 3 runnable files, each one of them is configures in experiment enviroment, which means when run it does certain number of repetitions using the devices in random order

Arduino has to be connected for these files to work

- TaviTest: This file is meant to play with the devices and learn how the catheter moves in its 2DOF.

- TaviFollow: Specify the DOF to be used 1stDOF or 2ndDOF, specify the number of subject (necessary for saving the result files). This simulation displays a red squared to be follow by the virtual catheter.

- TaviMaze: Specify the number of subject (necessary for saving the result files). This simulation displays a maze to navigate trhough with the virtual catheter tip, until colliding with the upper wall.