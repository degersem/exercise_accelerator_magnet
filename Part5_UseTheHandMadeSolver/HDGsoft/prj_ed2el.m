function elHt = prj_ed2el(msh,edHt)
% function elHt = prj_ed2el(msh,edHt)
%   projects an edge-wise field to an element-wise field by averaging per element
%
% Inputs
%       msh       : 2D mesh data structure
%       edHt      : edge-wise field (one row of values per edge)
%
% Outputs
%       elHt      : element-wise field (one row of values per element)
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

warning('not yet tested');
elHt=(edHt(msh.elem2edge(:,1),:)+edHt(msh.elem2edge(:,2),:)+edHt(msh.elem2edge(:,3),:))/2;
