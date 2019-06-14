function msh = mesh_connect_geometry(msh,gmy,repairflag,tolerance,plotflag)
    % function msh = mesh_connect_geometry(msh,gmy,repairflag,tolerance,plotflag)
    %   connects nodes and edges to the geometry (points, segments and arc segments)
    %
    % Inputs
    %    msh             :       : 2D FE mesh
    %    gmy             :       : 2D geometry
    %    repairflag      : [1/0] : indicates whether nodes at arc segments should be put exactly at the arc or not (optional; default: 1)
    %    tolerance       : []    : tolerance (optional; default: 1e-2)
    %    plotflag        : [1/0] : shows pictures or not (optional; default: 0)
    %
    % Outputs
    %    msh             :       : FEMM data structure
    %
    % Note
    %    make sure that the tolerance is high enough to find all nodes on arc segments because FEMM possibly puts arc nodes at the center of straight arc segments if an unfortunate combinations of elementsizes are used for model creation
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

    if ~exist('repairflag','var')
      repairflag=1;
    end
    if ~exist('tolerance','var')
      tolerance=1e-4;
    end
    if ~exist('plotflag','var')
      plotflag=0;
    end

    % A. Initialisation
    if ~isfield(msh,'edge')
      msh=mesh_add_edge_data(msh);
    end
    numnode=size(msh.node,1);                                                  % [#]   : number of nodes
    msh.node(:,4:7)=zeros(numnode,4);                                          % [m,m] : extend the node structure with segment-connection and arc-segment-connection information
    numedge=size(msh.edge,1);                                                  % [#]   : number of edges
    msh.edge(:,3:4)=zeros(numedge,2);                                          % [@,@] : extend the edge structure with segment-connection and arc-segment-connection information
    hmin=min(mesh_edge_length(msh))/10;                                        % [m]   : minimal mesh-edge length
    cd=msh.node(:,1:2);                                                        % [m,m] : nodal coordinates

    % B. Connect to points
    for pt=1:size(gmy.points,1)
      cdpt=gmy.points(pt,1:2);                                                 % [m,m] : coordinate of point
      idxpoint=find(pyth([cd(:,1)-cdpt(:,1) cd(:,2)-cdpt(:,2)])/hmin<tolerance); % [@]   : indices of the nodes incident to a geometry point
      msh.node(idxpoint,4)=pt;
    end

    % C. Connect to segments
    for sg=1:size(gmy.segments,1)
      cd1=gmy.points(gmy.segments(sg,1),1:2);                                  % [m,m] : first segment point
      cd2=gmy.points(gmy.segments(sg,2),1:2);                                  % [m,m] : second segment point
      [idxedge,idxnode,reldist]=mesh_find_segment(msh,[cd1;cd2],hmin,tolerance); % [@,@,]: trace line segment in the FE mesh
%       d=pyth(cd1-cd2);                                                         % [m]   : segment length
%       d1=pyth([cd(:,1)-cd1(:,1) cd(:,2)-cd1(:,2)]);                            % [m]   : distance nodes to first segment point
%       d2=pyth([cd(:,1)-cd2(:,1) cd(:,2)-cd2(:,2)]);                            % [m]   : distance nodes to second segment point
%       nodeflag=(abs(d1+d2-d)/hmin<tolerance);                                  % [1/0] : flag indicating whether the node is at the segment or not
%       edgeflag=map_indices(nodeflag,msh.edge(:,1:2));                          % [1/0] : 
%       idxnode=find(nodeflag);                                                  % [@]   : indices of the nodes lying on the segment
%       idxedge=find(edgeflag(:,1) & edgeflag(:,2));                             % [@]   : indices of the edges lying on the segment
      msh.node(idxnode,5)=sg;
      msh.edge(idxedge,3)=sg; 
      msh.node(idxnode,7)=reldist;                                         % []     : local coordinate along the line segment
    end

    % D. Connect to arc segments
    for asg=1:size(gmy.arcsegments,1)
      
      % THE LINES BELOW ARE SHIFTED TO THE FUNCTION mesh_find_arcsegment_problematic
%       % D.1. Arc information
%       center=gmy.arcsegments(asg,8:9);                                         % [m,m] : center point
%       R=gmy.arcsegments(asg,10);                                               % [m]   : radius
%       a1=gmy.arcsegments(asg,11);                                              % [rad] : begin angle
%       a2=gmy.arcsegments(asg,12);                                              % [rad] : end angle
%       a12=confine(a2-a1,-pi/4,2*pi-pi/4);                                      % [rad] : angular length of the arc segment
%       % D.2. Node information
%       w=[cd(:,1)-center(:,1) cd(:,2)-center(:,2)];                             % [m,m] : radial lines
%       a=atan2(w(:,2),w(:,1));                                                  % [rad] : angles
%       relrad=abs(pyth(w)-R)/R;                                                 % []    : relative distance of the nodes to the arc segment
%       iij=find(anglebetween(a,a1,a2));                                          % [#]   : indices of the nodes within the appropriate angle range
%       %figure(36); clf; semilogy(sort(relrad(iij))); xlabel('node number'); ylabel('relative distance to arc');
%       % HDG: make the search below only for the nodes within the appropriate angle range
%       tol=tolerance;                                                           % []    : relative tolerance for finding nodes at an arc segment
%       idxedge=[]; idxnode=[];
%       while (tol<=1e-2) & (length(idxedge)~=length(idxnode)-1) % procedure for retrieving all nodes on arcs that are refined without shape reconstruction (in FEMM)
%         % D.2. Search nodes
%         nodeflag=(relrad<tol) & anglebetween(a,a1,a2);                        % [1/0] : flag indicating whether the node is at the segment or not
%         idxnode=find(nodeflag);                                                % [@]   : indices of the nodes lying on the segment
%         if isempty(idxnode)
%           error('No nodes found at arc segment %d\n',asg);
%         end
%         da=confine(a(idxnode,1)-a1,-pi/4,2*pi-pi/4);
%         [dasorted,iii]=sort(da);                                               % []    : sorting vector for increasing angle
%         idxnode=idxnode(iii);                                                  % [@]   : indices of the nodes (ordered from the first to the second angle)
%         % D.3. Search edges
%         edgeflag=ismember(msh.edge(:,1:2),idxnode);                            % [1/0] :
%         idxedge=find(edgeflag(:,1) & edgeflag(:,2));                           % [@]   : indices of the edges lying on the segment
%         [dummy,edgeorder]=ismember(msh.edge(idxedge,1:2),idxnode);             % [@,@] : orders of the nodes of the temporarily found arc-segment edges
%         edgeorder=sort(edgeorder,2);
%         ii=find(diff(edgeorder,1,2)==1);                                       % [@]   : indices of the regular edges (connecting two successive nodes on the arc)
%         idxedge=idxedge(ii);                                                   % [@]   : only keep the regular edges
%         % D.4. Increase tolerance
%         if length(idxedge)~=length(idxnode)-1
%           %iiii=find(relrad(ii)<0.01);
%           %figure(37); clf; mesh_plot(msh,struct('node',ii(iiii)));
%           %figure(37); clf; geometry_plot(gmy); hold on; mesh_plot(msh,struct('node',idxnode,'edge',idxedge),struct('elem',[]));
%           warning('Increasing tolerance for finding edges and nodes on an arc by a factor 10');
%           tol=tol*10;
%         end
%       end
%       if (length(idxedge)~=length(idxnode)-1)
%         figure(48); clf; geometry_plot(gmy); hold on; mesh_plot(msh,struct('edge',idxedge,'node',idxnode),struct('elem',[]));
%         error('Number of arc-segment edges does not equal the number of arc-segment nodes minus one\n');
%       elseif tol~=tolerance
%         warning('Arc-segment only found all when applying a relative tolerance of %13.6e\n',tol);
%       end
%       idxclosenode=setdiff(find((relrad<tol) & anglebetween(a,a1,a2)),idxnode);
%       if any(idxclosenode)
%         warning('%d nodes are close to but not on the arc segment, possibly bad mesh\n',length(idxclosenode));
%       end

      %[idxedge,idxnode,reldist]=mesh_find_arcsegment_problematic(msh,gmy.arcsegments(asg,:),hmin,tolerance);
      [idxedge,idxnode,reldist]=mesh_find_arcsegment(msh,gmy.arcsegments(asg,:),hmin,tolerance);
%       if repairflag    % shifted outside the loop
%         msh.node(idxnode,1:2)=ones(length(idxnode),1)*center+R*[cos(a(idxnode,1)) sin(a(idxnode,1))];  % [m,m] : put all nodes exactly on the arc
%       end
      msh.node(idxnode,6)=asg;
      msh.edge(idxedge,4)=asg;
      msh.node(idxnode,7)=reldist;                                         % []     : local coordinate along the arc segment
    end
    if repairflag
      msh.node=geometry_reconstruct_arcs(gmy,msh.node);
    end

    % E. Make the point connection prioritary with respect to the line-segment and arc-segment connections
    % HDG: is this necessary?
    %idxpointconnected=find(msh.node(:,4));                                     % [@]   : indices of the point connected nodes
    %msh.node(idxpointconnected,5:6)=0;                                         % [@]   : discard the line- and arc-segment connections

    % G. Plot
    if plotflag
      colour='bgrcmy';
      marker='ox+*sdv^<>ph';
      % G.1. Plot points
      figure(1); clf; trimesh(msh.elem(:,1:3),msh.node(:,1),msh.node(:,2),'Color','k'); axis equal; hold on;
      xlabel('x (m)'); ylabel('y (m)'); title('points');
      for pt=1:length(gmy.points)
        idxnode=find(msh.node(:,4)==pt);
        plot(msh.node(idxnode,1),msh.node(idxnode,2),['r' marker(rem(pt-1,length(marker))+1)]);
      end
      % G.2. Plot line segments
      figure(2); clf; trimesh(msh.elem(:,1:3),msh.node(:,1),msh.node(:,2),'Color','k'); axis equal; hold on;
      xlabel('x (m)'); ylabel('y (m)'); title('line segments');
      for sg=1:length(gmy.segments)
        idxedge=find(msh.edge(:,3)==sg);
        cd1=msh.node(msh.edge(idxedge,1),1:2);
        cd2=msh.node(msh.edge(idxedge,2),1:2);
        line([cd1(:,1)';cd2(:,1)'],[cd1(:,2)';cd2(:,2)'],'Color','b');
        idxnode=find(msh.node(:,5)==sg);
        plot(msh.node(idxnode,1),msh.node(idxnode,2),['b' marker(rem(sg-1,length(marker))+1)]);
      end
      % G.3. Plot arc segments
      figure(3); clf; trimesh(msh.elem(:,1:3),msh.node(:,1),msh.node(:,2),'Color','k'); axis equal; hold on;
      xlabel('x (m)'); ylabel('y (m)'); title('arc segments');
      for asg=1:length(gmy.arcsegments)
        idxedge=find(msh.edge(:,4)==asg);
        cd1=msh.node(msh.edge(idxedge,1),1:2);
        cd2=msh.node(msh.edge(idxedge,2),1:2);
        line([cd1(:,1)';cd2(:,1)'],[cd1(:,2)';cd2(:,2)'],'Color','b');
        idxnode=find(msh.node(:,6)==asg);
        plot(msh.node(idxnode,1),msh.node(idxnode,2),['b' marker(rem(asg-1,length(marker))+1)]);
      end
      
end

