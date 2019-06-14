function B = curl(mesh,az)
% function B = curl(mesh,az)
%   computes the magnetic flux density for a given distribution of the line-integrated magnetic vector potential
%
% Inputs
%       mesh      :      : 2D FE mesh
%       a         : [Wb] : line-integrated magnetic vector potential, numnode-by-1 vector
%
% Outputs
%       B         : [T]  : magnetic flux density, numelem-by-2 vector
%
% See also
%   grad, div
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

u=[az(mesh.elem(:,1),1) az(mesh.elem(:,2),1) az(mesh.elem(:,3),1)];
% ---------------------- START IMPLEMENTATION TASK 1a ----------------------
% calculate the magnetic flux density from the FEMM solution
B;
% ----------------------- END IMPLEMENTATION TASK 1a -----------------------

