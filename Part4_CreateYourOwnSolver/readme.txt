%% Own finite-element solver for simulation the GSI-FAIR-SIS100 magnet
%
% Prof. Dr.-Ing. Herbert De Gersem
% Institut für Theorie Elektromagnetischer Felder (TEMF)
% Technische Universitaet Darmstadt
% www.temf.de

Part3_CreateYourOwnSolver
-------------------------

You need Octave/Matlab to be installed.
Your Octave/Matlab path should include "Part4_CreateYourOwnSolver/HDGsoft_implementation_start".

Open the main file "ownfesolver_implementation_start_v2.m" in the Octave/Matlab debugger.
Click through the code to get an idea about the data structures used in a FE solver.
Add the necessary implementations in the files
  curl.m; curlcurl_ll.m; curlcurl_ll_nonlinear.m; current_Pstr.m; edgemass_ll.m
  ownfesolver_implementation_start_v2.m (called "driver.m" in the script+)
(see also page 13 of the script)

If you succeed in all implementations, you have been implementing the core of
a FE solver, should be proud of yourself and apply for a position at TEMF in Darmstadt.

Otherwise, congratulations for trying, you get a completed version of the code
in the following part of the exercise.
