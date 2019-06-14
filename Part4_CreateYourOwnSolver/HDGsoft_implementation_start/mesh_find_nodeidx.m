function idx=mesh_find_nodeidx(mesh,cd)

% function idx=mesh_find_nodeidx(mesh,cd)
% searches the indices of the nodes closest to the given coordinates
%
% input parameters
%    mesh             : 2D FE mesh
%    cd               : [m,m]  : coordinates
%
% output parameters
%    idx              : [@]    : indices
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

idx=zeros(0,1);
for q=1:size(cd,1)
  [dummy,i]=min(pyth([ mesh.node(:,1)-cd(q,1) mesh.node(:,2)-cd(q,2) ]));
  idx=[idx ; i];
end
%figure(1); clf; plot(mesh.node(idx,1),mesh.node(idx,2),'x'); axis equal;

