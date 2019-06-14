function idxedge=mesh_trace_edges(msh,idxnode)

% function idxedge=mesh_trace_edges(msh,idxnode)
% traces the edges on a curve in a triangulation
%
% input parameters
%    msh                             : 2D FE mesh
%    idxnode                         : [@]    : indices of the nodes on the curve
%
% output parameters
%    idxedge                         : [@]    : indices of the edges on the line segment (sorted!)
%
% assumption: the nodes are succeeding each other on a curve in the mesh
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

edgeflag=ismember(msh.edge(:,1:2),idxnode);                                % [1/0] :
idxedge=find(edgeflag(:,1) & edgeflag(:,2));                               % [@]   : indices of the edges lying on the segment
[dummy,edgeorder]=ismember(msh.edge(idxedge,1:2),idxnode);                 % [@,@] : orders of the nodes of the temporarily found arc-segment edges
edgeorder=sort(edgeorder,2);
ii=find(diff(edgeorder,1,2)==1);                                           % [@]   : indices of the regular edges (connecting two successive nodes on the arc)
idxedge=reshape(idxedge(ii),[],1);                                         % [@]   : only keep the regular edges
switch length(idxnode)-length(idxedge)
  case 0
    warning('closed curve\n');
  case 1
    % ok
  otherwise
    warning('invalid curve: idxnode=%d and idxedge=%d\n',length(idxnode),length(idxedge));
end
