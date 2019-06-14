function ndB = prj_el2nd(prb,elB)
% function ndB = prj_el2nd(prb,elB)
%   projects an element-wise solution to a node-wise solution the projection is carried out by weighing by the element areas
%
% Inputs
%       prb       : 2D FEMM problem
%       elB       : properties (one per element)
%
% Outputs
%       ndb       : ???
%
% Author
%   Herbert De Gersem (HDG: replace prb by msh)
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

numelem=size(prb.mesh.elem,1);
numnode=size(prb.mesh.node,1);
nodearea=full(sparse(reshape(prb.mesh.elem(:,1:3),[],1),ones(3*numelem,1),repmat(prb.mesh.area,3,1),numnode,1));
for q=1:size(elB,2)
  ndB(:,q)=full(sparse(reshape(prb.mesh.elem(:,1:3),[],1),ones(3*numelem,1),repmat(elB(:,q).*prb.mesh.area,3,1),numnode,1))./nodearea;
end

end
