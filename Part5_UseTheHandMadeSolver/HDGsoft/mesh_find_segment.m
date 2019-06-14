function [idxedge,idxnode,reldist]=mesh_find_segment(msh,cd12,hmin,reltol)

% function [idxedge,idxnode,reldist]=mesh_find_segment(msh,cd12,hmin,reltol)
% traces a line segment in a triangulation
%
% input parameters
%    msh                             : 2D FE mesh
%    cd12                            : [m,m]  : 2-by-2 : coordinates of begin and end point
%    hmin                            : [m]    : minimal relevant length (optional; default: minimal mesh edge length)
%    reltol                          : []     : relative tolerance (optional; default: 1e-6)
%
% output parameters
%    idxedge                         : [@]    : indices of the edges on the line segment (sorted!)
%    idxnode                         : [@]    : indices of the nodes on the line segment (sorted!)
%    reldist                         : []     : relative coordinate along the line segment (between 0 and 1)
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

if ~exist('hmin','var')
  hmin=[];
end
if ~exist('reltol','var')
  reltol=1e-6;
end
if isempty(hmin)
  hmin=min(mesh_edge_length(msh));                                         % [m]   : minimal mesh-edge length
end

d=pyth(cd12(1,:)-cd12(2,:));                                               % [m]   : segment length
d1=pyth([msh.node(:,1)-cd12(1,1) msh.node(:,2)-cd12(1,2)]);                % [m]   : distance nodes to first segment point
d2=pyth([msh.node(:,1)-cd12(2,1) msh.node(:,2)-cd12(2,2)]);                % [m]   : distance nodes to second segment point
nodeflag=(abs(d1+d2-d)/hmin<reltol);                                       % [1/0] : flag indicating whether the node is at the segment or not
idxnode=reshape(find(nodeflag),[],1);                                      % [@]   : indices of the nodes lying on the segment
reldist=(d1(idxnode,1)-d)/d;                                               % []     : local coordinate along the line segment
[reldist,iii]=sort(reldist);
idxnode=idxnode(iii);
idxedge=mesh_trace_edges(msh,idxnode);                                     % [@]   : indices of the edges lying on the segment
