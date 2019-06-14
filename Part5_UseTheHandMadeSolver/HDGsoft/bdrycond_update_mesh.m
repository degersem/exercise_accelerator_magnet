function [bdrycond,idxdof,numunknown]=bdrycond_update_mesh(bdrycond,msh,gmy,allocation,plotflag)
% function [bdrycond,idxdof,numunknown]=bdrycond_update_mesh(bdrycond,msh,gmy,allocation,plotflag)
%   updates the boundary-condition information according to a particular FE mesh (to be invoked after each mesh-refinement step) here, in practice, the index vectors are updated
%
% Inputs
%    bdrycond           :       : data for boundary conditions (BCs)
%    msh                :       : 2D FE mesh
%    gmy                :       : 2D geometry
%    allocation         : 'node'/'edge'/'face'/'volume' : allocation of the degrees of freedom
%    plotflag           : 1/0   : plot figures (optional; default: 0)
%
% Outputs
%    bdrycond           :       : data for boundary conditions (BCs)
%    idxdof             : [@]   : indices of the degrees of freedom
%    numunknown         : [#]   : number of unknowns (needed for bdrycond_inflate)
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

% A. Parameter control
if ~exist('plotflag','var')
  plotflag=0;
end
reltol=1e-3;

% B. Detect mirror line segments and mirror arc segments for binary boundary conditions
%    Make one of both (arc)segments to master (remove BC identifier)
numbdrycond=length(bdrycond);                                              % [#]   : number of boundary conditions
for bd=1:numbdrycond
  switch bdrycond(bd).type
    case {'airgap','periodic','antiperiodic'} % binary boundary conditions
      if isfield(bdrycond(bd).mirror,'point')                              % binary condition applied to two points
        pt=bdrycond(bd).mirror.point;                                      % [@,@] : connection list for points
        ndslv=pt(1); sslv=0; edslv=zeros(0,1);                             % [@]   : nodal indices and local coordinates at the slave side
        ndmst=pt(2); smst=0; edmst=zeros(0,1);                             % [@]   : nodal indices and local coordinates at the master nodes
      elseif isfield(bdrycond(bd).mirror,'segment')                        % binary condition applied to two line segments
        sg=bdrycond(bd).mirror.segment;                                    % [@,@] : connection list for line segments
        [ndslv,sslv,edslv]=mesh_order_segment(msh,gmy,sg(1));              % [@]   : nodal indices and local coordinates at the slave side
        [ndmst,smst,edmst]=mesh_order_segment(msh,gmy,sg(2));              % [@]   : nodal indices and local coordinates at the master nodes
      elseif isfield(bdrycond(bd).mirror,'arcsegment')                     % binary condition applied to two arc segments
        asg=bdrycond(bd).mirror.arcsegment;                                % [@,@] : connection list for arc segments
        [ndslv,sslv,edslv]=mesh_order_arcsegment(msh,gmy,asg(:,1));        % [@]   : nodal indices and local coordinates at the slave side
        [ndmst,smst,edmst]=mesh_order_arcsegment(msh,gmy,asg(:,2));        % [@]   : nodal indices and local coordinates at the master nodes
      else
        warning('empty boundary');
        ndslv=[]; sslv=[]; edslv=[];
        ndmst=[]; smst=[]; edmst=[];
      end
      % here, we assume a matching grid at the interface
      if length(ndslv)~=length(ndmst)
        error('number of slave nodes (%d) does not match number of master nodes (%d)\n',length(ndslv),length(ndmst));
      end
      if any(abs(sslv-smst)>reltol*max(smst))
        error('non-matching grid at the interface\n');
      end
      bdrycond(bd).mirror.edge=[edslv edmst];                              % [@,@] : connection list for edges
      bdrycond(bd).mirror.node=[ndslv ndmst];                              % [@,@] : connection list for edges

      % X. Further treatment only for air-gap interface conditions
      if strcmp(bdrycond(bd).type,'airgap') % air-gap interface condition
        %xynode=msh.node(ndslv,1:2);
        % [theta,r]=cart2pol(xynode(:,1),xynode(:,2));
        % HDG: try to get theta out of this story, done
        bdrycond(bd).airgap=airgap_operators_update_mesh(bdrycond(bd).airgap,sslv);%,theta);
      end
  end
end

% C. Propagate the boundary conditions from the line and arc segments to the edges
msh.edge(:,5)=0;
for bd=1:numbdrycond
  pt=find(gmy.points(:,6)==bd);
  sg=find(gmy.segments(:,4)==bd);
  asg=find(gmy.arcsegments(:,5)==bd);
  if ~any(pt) & ~any(sg) & ~any(asg)
    warning('Boundary condition %d not found in the mesh\n',bd);
  else
    ed=union(find(ismember(msh.edge(:,3),sg)),find(ismember(msh.edge(:,4),asg)));
    bdrycond(bd).idxedge=ed;
    msh.edge(ed,5)=bd;
  end
end

% D. Propagate the boundary conditions from the edges to the nodes
%    entering the node indices in the boundary-condition data structure
%    do not allow nodes associated from constrained points except for those nodes associated with points have the same boundary condition
%    this replaces the resolving of ambiguities
ptrestrict=find(gmy.points(:,6));                                          % [@]  : indices of the constrained points
ndrestrict=find(ismember(msh.node(:,4),ptrestrict));                       % [@]  : indices of the nodes constrained through the corresponding points
for bd=1:numbdrycond
  ed=find(msh.edge(:,5)==bd);                                              % [@]  : edges with the specified boundary condition
  nd8ed=unique([msh.edge(ed,1);msh.edge(ed,2)]);                           % [@]  : nodes incident to those edges
  pt=find(gmy.points(:,6)==bd);                                            % [@]  : points with the specified boundary condition
  nd8pt=find(ismember(msh.node(:,4),pt));                                  % [@]  : nodes associated with these points
  nd=union(setdiff(nd8ed,ndrestrict),nd8pt);                               % [@]  : indices of all nodes having the specified boundary conditions
  if ismember(bdrycond(bd).type,{'airgap','periodic','antiperiodic'})      % binary boundary condition, make a double column index vector
    ii=find(ismember(bdrycond(bd).mirror.node(:,1),nd));                   % [@]  : occurrences of slave nodes that are affected by the binary constraint
    if length(ii)~=length(nd)
      error('not all binary constrained nodes have been found in the mirror data\n');
    end
    bdrycond(bd).idxnode=bdrycond(bd).mirror.node(ii,1:2);
  else
    bdrycond(bd).idxnode=reshape(nd,[],1);
  end
end

% E. Determine the degrees of freedom
for bd=1:numbdrycond
  bdrycond(bd).idx=bdrycond(bd).(['idx' allocation]);                      % [@]    : copy either idxnode or idxedge into idx
end
numunknown=size(msh.(allocation),1);                                       % [#]    : number of unknowns (== number of nodes, edges, faces or volumes)
idxdof=bdrycond_idxdof(bdrycond,numunknown);                               % [@]    : indices of the degrees of freedom

% F. Provide coordinate information for inhomogeneous Dirichlet boundary conditions
bdlist=find(strcmp({bdrycond.type},'dirichlet'));                          % [@]    : identifiers of the Dirichlet boundary conditions
for ii=1:length(bdlist)
  bd=bdlist(ii);                                                           % [@]    : BC identifier
  if ~isempty(bdrycond(bd).expression)
    switch allocation
      case 'node'
        xy=msh.node(bdrycond(bd).idxnode,1:2);                             % [m,m]  : coordinates
      case 'edge'
        ed=bdrycond(bd).idxedge;
        xy=(msh.node(msh.edge(ed,1),1:2)+msh.node(msh.edge(ed,2),1:2))/2;  % [m,m]  : coordinates
      otherwise
        error('Unknown allocation %s\n',allocation);
    end
    [theta,r]=cart2pol(xy(:,1),xy(:,2));
    if depends_on(bdrycond(bd).expression,'x')                             % Dirichlet data depends on x
      bdrycond(bd).para.x=xy(:,1);
    end
    if depends_on(bdrycond(bd).expression,'y')                             % Dirichlet data depends on y
      bdrycond(bd).para.y=xy(:,2);
    end
    if depends_on(bdrycond(bd).expression,'r')                             % Dirichlet data depends on r
      bdrycond(bd).para.r=r;
    end
    if depends_on(bdrycond(bd).expression,'theta')                         % Dirichlet data depends on theta
      bdrycond(bd).para.theta=theta;
    end
  end
end

% G. Plot boundary conditions
if plotflag
  colour='bgrcmy';
  marker='ox+*sdv^<>ph';
  figure(4); clf; trimesh(msh.elem(:,1:3),msh.node(:,1),msh.node(:,2),'Color','k'); axis equal; hold on;
  xlabel('x (m)'); ylabel('y (m)'); title('boundary conditions');
  for bd=1:numbdrycond
    switch allocation
      case 'node'
        cd1=msh.node(bdrycond(bd).idxnode(:,1),1:2);
      case 'edge'
        ed1=bdrycond(bd).idxedge(:,1);
        cd1=(msh.node(msh.edge(ed1,1),1:2)+msh.node(msh.edge(ed1,2),1:2))/2;
      otherwise
        error('Unknown allocation %s\n',allocation);
    end
    plot(cd1(:,1),cd1(:,2),[colour(rem(bd-1,length(colour))+1) marker(rem(bd-1,length(marker))+1)]);
    switch bdrycond(bd).type
      case {'dirichlet','sibc','robin'}
      case {'airgap','periodic','antiperiodic'}
        switch allocation
          case 'node'
            cd2=msh.node(bdrycond(bd).idxnode(:,2),1:2);
          case 'edge'
            ed2=bdrycond(bd).idxedge(:,2);
            cd2=(msh.node(msh.edge(ed2,1),1:2)+msh.node(msh.edge(ed2,2),1:2))/2;
          otherwise
            error('Unknown allocation %s\n',allocation);
        end
        plot(cd2(:,1),cd2(:,2),[colour(rem(bd-1,length(colour))+1) marker(rem(bd-1,length(marker))+1)]);
        line([cd1(:,1) cd2(:,1)]',[cd1(:,2) cd2(:,2)]','Color',colour(rem(bd-1,length(colour))+1),'LineStyle',':');
      otherwise
        error('Unknown boundary condition %s\n',bdrycond(bd).type);
    end
  end

end

