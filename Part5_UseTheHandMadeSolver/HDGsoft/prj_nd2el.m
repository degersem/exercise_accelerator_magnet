function elJz = prj_nd2el(prb,ndJz)
% function elJz = prj_nd2el(prb,ndJz)
%   projects a node-wise field to an element-wise field by averaging per element
%
% Inputs
%       prb       : 2D FE problem
%       ndJz      : node-wise field (one row of values per node)
%
% Outputs
%       elJz      : element-wise field (one row of values per element)
%
% Author
%   Herbert De Gersem (HDG: replace prb by msh)
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

elJz=(ndJz(prb.mesh.elem(:,1),:)+ndJz(prb.mesh.elem(:,2),:)+ndJz(prb.mesh.elem(:,3)))/3;
