function edB = prj_el2ed(msh,elB)
% function edB = prj_el2ed(msh,elB)
%   projects an element-wise solution to an edge-wise solution
%   the projection is carried out by weighing by the element areas
%
% Inputs
%       msh       : 2D mesh data structure
%       elB       : properties (one per element)
%
% Outputs
%       edB       : properties (one per edge)
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

numelem=size(msh.elem,1);
numedge=size(msh.edge,1);
edgearea=full(sparse(reshape(abs(msh.elem2edge(:,1:3)),[],1),ones(3*numelem,1),repmat(msh.area,3,1),numedge,1));
for q=1:size(elB,2)
  edB(:,q)=full(sparse(reshape(abs(msh.elem2edge(:,1:3)),[],1),ones(3*numelem,1),repmat(elB(:,q).*msh.area,3,1),numedge,1))./edgearea;
end
