%% Own finite-element solver for simulation the GSI-FAIR-SIS100 magnet
%
% Prof. Dr.-Ing. Herbert De Gersem
% Institut für Theorie Elektromagnetischer Felder (TEMF)
% Technische Universitaet Darmstadt
% www.temf.de

Part5_UseTheHandMadeSolver
--------------------------

You need Octave/Matlab to be installed.
Your Octave/Matlab path should include "Part5_UseTheHandMadeSolver/HDGsoft".

Open the main file "ownfesolver_completed.m" in the Octave/Matlab debugger.
Click through the code to get an idea about the data structures used in a FE solver.
Furthermore, get an idea of the algorithm, especially also the successive-substitution
and Newton methods for dealing with nonlinear materials.

If you are courageous, extend the software for transient FE simulation.
Give the iron of the magnet a small conductivity and implement the backward
Euler method for time stepping. Ramp the current from 0 to 8000 A in 0.5 s.
Keep the field for another 0.5 s and ramp down with the same rate. Calculate
the losses in the iron. 
