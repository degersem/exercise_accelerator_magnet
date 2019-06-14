function [idxnode,snode,idxedge,sedge,sgnedge] = mesh_order_arcsegment(msh,gmy,asg)
% function [idxnode,snode,idxedge,sedge,sgnedge] = mesh_order_arcsegment(msh,gmy,asg)
%   returns the indices of the nodes at an arc segment ordered from the first point to the second point
%
% Inputs
%    msh              :      : 2D FE mesh
%    gmy              :      : 2D geometry
%    asg              : [@]  : arc-segment number
%
% Outputs
%    idxnode          : [@]  : indices of the nodes ordered from the first arc-segment point to the second arc-segment point
%    snode            : [m]  : local coordinate of the nodes (== distances in increasing order to the first arc-segment point)
%    idxedge          : [@]  : indices of the edges ordered from the first arc-segment point to the second arc-segment point
%    sedge            : [m]  : local coordinate of the edges (== distances in increasing order to the first arc-segment point)
%    sgnedge          : [1/-1] : sign indicating whether the edge has the same orientation as the arc segment or not
%
% Author
%   Herbert De Gersem
%
% Remark-1 (HDG) : merge mesh_find_arcsegment and mesh_order_arcsegment
% The first routine adds arc-segment indices to the edges whereas the second
% determines (ordered) edge indices for the arc segments (without adding this
% information to the arc-segment data structure, because that is a table)
% Remark-2 (HDG) : make idxedge to a "signed index list", also indicating
% the relative orientation between edge and geometry
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

if length(asg)>1
  for i=1:length(asg)
    [idxnode,snode,idxedge,sedge]=mesh_order_arcsegment(msh,gmy,asg(i));
    idxn{i}=idxnode; sn{i}=snode; idxe{i}=idxedge; se{i}=sedge;
  end
  [idxnode,snode,idxedge,sedge]=mesh_order_curve(idxn,sn,idxe,se,1,msh);
else

  center=gmy.arcsegments(asg,8:9);                                           % [m,m] : arc center
  radius=gmy.arcsegments(asg,10);                                            % [m]   : arc radius
  refangle=gmy.arcsegments(asg,11);                                          % [rad] : reference angle

  % A. Order edges
  idxedge=find(msh.edge(:,4)==asg);                                          % [@]   : indices of the edges at the arc segment
  rayedge=(msh.node(msh.edge(idxedge,1),1:2)+msh.node(msh.edge(idxedge,2),1:2))/2-ones(length(idxedge),1)*center; % [m,m] : rays from the arc's center to the edge centers
  %angleedge=abs(atan2(rayedge(:,2),rayedge(:,1))-refangle);                  % [rad] : ray angles relatively to the reference angle (it is assumed that arcs are at most 180 degrees)
  angleedge=confine(atan2(rayedge(:,2),rayedge(:,1))-refangle,-pi/6,2*pi-pi/6); % [rad] : ray angles relatively to the reference angle (it is assumed that arcs are at most 180 degrees)
  [dummy,jjj]=sort(angleedge);                                               % []    : sorting vector for increasing angle
  idxedge=idxedge(jjj);                                                      % [@]   : indices of the edges (in increasing distance to the first line-segment point)
  sedge=angleedge(jjj)*radius;                                               % [m] : distance along the arc to the reference point

  % B. Order nodes
  idxnode=unique(msh.edge(idxedge,1:2));                                     % [@]   : indices of the nodes at the line segment
  raynode=msh.node(idxnode,1:2)-ones(length(idxnode),1)*center;              % [m,m] : rays from the arc's center to the nodes
  %anglenode=abs(atan2(raynode(:,2),raynode(:,1))-refangle);                  % [rad] : ray angles relatively to the reference angle (it is assumed that arcs are at most 180 degrees)
  anglenode=confine(atan2(raynode(:,2),raynode(:,1))-refangle,-pi/6,2*pi-pi/6); % [rad] : ray angles relatively to the reference angle (it is assumed that arcs are at most 180 degrees)
  [dummy,iii]=sort(anglenode);                                               % []    : sorting vector for increasing angle
  idxnode=idxnode(iii);                                                      % [@]   : indices of the nodes (ordered from the first to the second angle)
  snode=anglenode(iii)*radius;                                               % [m] : distance along the arc to the reference point

  % C. Determine the relative orientation between edges and arc segments
  numedge=length(idxedge);                                                   % [#]   : number of edges
  sgnedge=zeros(numedge,1);
  sgnedge(find(msh.edge(idxedge,1)==idxnode(1:numedge)))=1;
  sgnedge(find(msh.edge(idxedge,2)==idxnode(1:numedge)))=-1;
end
