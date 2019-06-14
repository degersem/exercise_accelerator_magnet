function [idxedge,idxnode,reldist] = mesh_find_arcsegment(msh,arcsegment,hmin,reltol)

% function [idxedge,idxnode,reldist] = mesh_find_arcsegment(msh,arcsegment,hmin,reltol)
% traces an arc segment in a triangulation
%
% input parameters
%    msh                             : 2D FE mesh
%    arcsegment                      : arc segment information
%    hmin                            : [m]    : minimal relevant length (optional; default: minimal mesh edge length)
%    reltol                          : []     : relative tolerance (optional; default: 1e-6)
%
% output parameters
%    idxedge                         : [@]    : indices of the edges on the arc segment (sorted!)
%    idxnode                         : [@]    : indices of the nodes on the arc segment (sorted!)
%    reldist                         : []     : relative coordinate along the arc segment (between 0 and 1)
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

%% A. Arc-segment information
center=arcsegment(8:9);                                                    % [m,m] : center point
R=arcsegment(10);                                                          % [m]   : radius
a1=arcsegment(11);                                                         % [rad] : begin angle
a2=arcsegment(12);                                                         % [rad] : end angle
a12=confine(a2-a1,-pi/4,2*pi-pi/4);                                        % [rad] : angular length of the arc segment

%% B. Node information
w=[msh.node(:,1)-center(1) msh.node(:,2)-center(2)];                       % [m,m] : radial lines
a=atan2(w(:,2),w(:,1));                                                    % [rad] : angles
reldist=abs(pyth(w)-R)/R;                                                  % []    : relative distance of the nodes to the arc segment
iij=find(anglebetween(a,a1,a2));                                           % [#]   : indices of the nodes within the appropriate angle range
%figure(36); clf; semilogy(sort(reldist(iij))); xlabel('node number'); ylabel('relative distance to arc');

%% C. Search nodes on the arc segment
nodeflag=(reldist<reltol) & anglebetween(a,a1,a2,reltol);                  % [1/0] : flag indicating whether the node is at the segment or not
idxnode_frame=find(nodeflag);                                              % [@]   : indices of the nodes lying on the segment
if isempty(idxnode_frame)
  error('No nodes found at arc segment with center (%8.5e,%8.5e), radius %8.5e and angles %8.5e and %8.5e\n',center(1),center(2),R,a1/pi*180,a2/pi*180);
end
da=confine(a(idxnode_frame,1)-a1,-pi/4,2*pi-pi/4);
[dasorted,iii]=sort(da);                                                   % []    : sorting vector for increasing angle
idxnode_frame=idxnode_frame(iii);                                          % [@]   : indices of the nodes (ordered from the first to the second angle)

%% D. Gradually extend the node set to a connected node set by inspecting edges
% assumption: the nodes found above are connected by straight lines, possibly with intermediate nodes
idxedge=[];
idxnode=idxnode_frame(1);
for i=1:length(idxnode_frame)-1
  [idxedge_part,idxnode_part,reldist_part]=mesh_find_segment(msh,msh.node(idxnode_frame([i i+1]),1:2),hmin,reltol);
  idxedge=[idxedge ; idxedge_part];
  idxnode=[idxnode ; idxnode_part(2:end)];
end
da=confine(a(idxnode,1)-a1,-pi/4,2*pi-pi/4);
reldist=da/a12;                                                            % []   : relative distance along the arc

%% E. Plot result
plotflag=0;
if plotflag
  figure(305); clf; geometry_plot_arcsegments(arcsegment); hold on; axis equal;
  plot(msh.node(idxnode,1),msh.node(idxnode,2),'bx');
  plot(msh.node(idxnode_frame,1),msh.node(idxnode_frame,2),'rx');
end