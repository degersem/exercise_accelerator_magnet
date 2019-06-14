function mesh_create_regular_mesh(finfilename,foutfilename,pts,plotflag)

% function mesh_create_regular_mesh(finfilename,foutfilename,pts)
% replaces the mesh in a FEMM .ans file by a regular mesh on a rectangle or circle
%
% input parameters
%    finfilename            : file name or file pointer of the original FEMM .ans file
%    foutfilename           : file name or file pointer of the new FEMM .ans file (input and output file name may be the same)
%    pts     possibility 1  : [m,m]   : list of point coordinates
%    pts     possibility 2  :         : rectangle
%        hmesh              : [m]     : mesh length
%        x                  : [m]     : x-coordinates (at least 2)
%        y                  : [m]     : y-coordinates (at least 2)
%        force_even_number  : [0/1]   : force even numbers of mesh edges in the x- and y-direction (optional; default: [0 0])
%    pts     possibility 3  :         : circle
%        hmesh              : [m]     : mesh length
%        center             : [m,m]   : center point (optional; default: [0 0])
%        R                  : [m]     : radii of arc/circle interfaces (if R(1)==0, then disk domain, otherwise annulus)
%        angle              : [rad,rad] :  begin and end angle of the pie (use [0 2*pi] for a full circle; optional; default: [0 2*pi])
%        polygon            : [#]     : number of polygonal corners in a first layer (optional; default: 6, equivalent to a sextagon around the center)
%    plotflag               : 1/0     : plot the mesh or not (optional; default: 0)
%
% output parameters
%    none

% A. Example of use
if nargin==0;
  fprintf('---- Showing the use of mesh_create_regular_mesh ----\n');
  % A.1. Create simple model
  modelname='vierkant';
  openfemm;                                                                % open a connection to FEMM
  newdocument(0);
  mi_addmaterial('AIR',1,1,0,0,0,0,0,0,0,0,0,0,0);
  mi_addboundprop('Z',0,0,0,0,0,0,0,0,0);
  mi_addboundprop('T',1,0,0,0,0,0,0,0,0);
  mi_drawpolygon([0,0;1,0;1,1;0,1]);
  mi_selectsegment(0.5,0); mi_setsegmentprop('Z',0,0,0,0); mi_clearselected;
  mi_selectsegment(0.5,1); mi_setsegmentprop('T',0,0,0,0); mi_clearselected;
  mi_addblocklabel(0.5,0.5); mi_selectlabel(0.5,0.5); mi_setblockprop('AIR',0,0,0,0,0,0);
  mi_probdef(0,'meters','planar',1e-8,0.2,30,1);
  mi_saveas([modelname '.fem']);
  mi_analyse;
  closefemm;
  % A.2. Remesh the model
  hmesh=0.1;
  mesh_create_regular_mesh([modelname '.ans'],[modelname '_regular.ans'],struct('x',[0,1],'y',[0,1],'hmesh',hmesh));
  return;
end

if ~exist('plotflag','var')
  plotflag=0;
end

if ~isstruct(pts)
  % FIRST POSSIBILITY : A LIST OF NODES IS GIVEN
  %% A. Construct a list of mesh points
  node=pts;                                                                % nodes are given
  %% B. Triangulate
  elem=delaunay(node(:,1),node(:,2));                                        % create a triangulation
  %% C. Determine the regions
  numelem=size(elem,1);                                                      % [#]  : number of elements
  idxelem=ones(numelem,1);

else
  if ~isfield(pts,'hmesh')
    error('The third parameter should have a field ''hmesh'' specifying the mesh density');
  end
  if isfield(pts,'xmin') & isfield(pts,'xmax') & isfield(pts,'ymin') & isfield(pts,'ymax')
    warning('Depreciated use of mesh_create_regular_mesh, use "x" and "y" instead of "xmin", "xmax", "ymin" and "ymax"');
    pts.x=[ pts.xmin pts.xmax ];
    pts.y=[ pts.ymin pts.ymax ];
  end
  if isfield(pts,'x') & isfield(pts,'y')
    % SECOND POSSIBILITY : CARTESIAN TENSOR PRODUCT GRID
    if ~isfield(pts,'force_even_number')
      pts.force_even_number=[0 0];
    end
    nx=length(pts.x);                                                      % [#]  : number of points in the x-direction
    ny=length(pts.y);                                                      % [#]  : number of points in the y-direction
    if (nx<2) | (ny<2)
      error('mesh_create_regular_mesh: at least two x-coordinates and two y-coordinates should be given');
    end
    %% A. Construct a list of mesh points
    xaxis=pts.x(1);                                                        % [m]  : discrete x-axis
    for i=2:nx
      numxpoint=max(3,ceil((pts.x(i)-pts.x(i-1))/pts.hmesh));
      if pts.force_even_number(1) & (rem(numxpoint,2)==0)
        numxpoint=numxpoint+1;
      end
      xadd=linspace(pts.x(i-1),pts.x(i),numxpoint);
      xaxis=[ xaxis xadd(2:end) ];
    end
    yaxis=pts.y(1);                                                        % [m]  : discrete y-axis
    for j=2:ny
      numypoint=max(3,ceil((pts.y(j)-pts.y(j-1))/pts.hmesh));
      if pts.force_even_number(2) & (rem(numypoint,2)==0)
        numypoint=numypoint+1;
      end
      yadd=linspace(pts.y(j-1),pts.y(j),numypoint);
      yaxis=[ yaxis yadd(2:end) ];
    end
    [xgrid,ygrid]=meshgrid(xaxis,yaxis);
    node=[ xgrid(:) ygrid(:) ];
    %% B. Triangulate
    elem=delaunay(node(:,1),node(:,2));                                    % create a triangulation
    %% C. Determine the regions
    numelem=size(elem,1);                                                  % [#]  : number of elements
    xyelem=(node(elem(:,1),:)+node(elem(:,2),:)+node(elem(:,3),:))/3;      % [m,m]: coordinates of the element centers
    ielem=floor(interp1(pts.x,0:nx-1,xyelem(:,1),'linear',nx));
    jelem=floor(interp1(pts.y,0:ny-1,xyelem(:,2),'linear',ny));
    idxelem=ielem*(ny-1)+jelem+1;                                          % [@]  : element indices

  elseif isfield(pts,'R')
    % THIRD POSSIBILITY : UNSTRUCTURED CIRCULAR GRID
    %% A. Parameter check
    if ~isfield(pts,'center')
      pts.center=[ 0 0 ];
    end
    if ~isfield(pts,'angle')
      pts.angle=[ 0 2*pi ];
    end
    if ~isfield(pts,'polygon')
      pts.polygon=6;
    end
    if length(pts.angle)==1
      pts.angle=[ 0 pts.angle ];
    end
    fullcircle=(abs(diff(pts.angle)-2*pi)<1e-8);

    %% B. Determine how many points at each of the arc/circle interfaces (numpoint = lys * pts.polygon)
    arclength=diff(pts.angle)*pts.R;                                       % [m]  : arc lengths
    lys=ceil(arclength/pts.hmesh/pts.polygon);                             % [#]  : layer indices
    
    %% C. Define all layers, interpolate between radii when several layers need to be inserted in the same annulus region
    % the following two lines are a short-cut, if the specified mesh size is small enough to avoid successive arc/circle
    % interfaces to have the same number of mesh points
    %lysall=[lys(1):lys(end)]';                                             % [#]  : all layer indices (incremented by 1)
    %Rall=interp1(lys,pts.R,lysall);                                        % [m]  : radii of all layers
    lysall=lys(1);
    Rall=pts.R(1);
    for p=2:length(lys)
      switch lys(p)-lys(p-1)
        case {0,1}
          lysall=[ lysall ; lys(p) ];
          Rall=[ Rall ; pts.R(p) ];
        otherwise
          lysall=[ lysall ; [lys(p-1)+1:lys(p)]' ];
          Rint=linspace(pts.R(p-1),pts.R(p),lys(p)-lys(p-1)+1)';
          Rall=[ Rall ; Rint(2:end) ];
      end
    end
    %[ lysall Rall ]
    
    %% D. Calculate the mesh nodes and triangulate
    node=zeros(0,2);                                                       % [m,m]: nodes
    elem=zeros(0,3);                                                       % [@]  : elements
    prevnode=zeros(0,2);
    for p=1:length(lysall)
      if lysall(p)==0    % central degenerated node
        addnode=[ 0 0 ];
        node=[ node ; addnode ];                                           % [m,m]: add center node
        prevnode=addnode;
      else               % equidistant distribution of nodes along a circle or arc
        a=linspace(pts.angle(1),pts.angle(2),lysall(p)*pts.polygon+1)';
        if fullcircle
          a=a(1:end-1,1);
        end
        addnode=Rall(p)*[ cos(a) sin(a) ];
        prevnumnode=size(node,1);
        node=[ node ; addnode ];
        newnumnode=size(node,1);
        addelem=delaunay([prevnode(:,1);addnode(:,1)],[prevnode(:,2);addnode(:,2)]);
        addelem=addelem+prevnumnode-size(prevnode,1);
        idxnewelem=find(any(ismember(addelem,prevnumnode+1:newnumnode),2)); % [@]   : indices of the new elements
        elem=[ elem ; addelem(idxnewelem,:) ];
        %elem=[ elem ; addelem ];
        prevnode=addnode;
        trimesh(elem(:,1:3),node(:,1),node(:,2)); %axis equal;                    % plot the mesh
      end
    end
    node=node+ones(size(node,1),1)*pts.center;
    
    %% E. Triangulate
    %elem=delaunay(node(:,1),node(:,2));                                        % create a triangulation
    r0=pts.R(1);                                                             % [m]   : first radius
    if r0~=0
      idxinnernode=find(abs(pyth(node)-r0)/r0<1e-6);                         % [@]   : indices of the nodes at the inner circle
      idxinnerelem=find(sum(ismember(elem,idxinnernode),2)~=3);              % [@]   : indices of the elements inside the inner circle
      elem=elem(idxinnerelem,:);
    end

    %% F. Determine the regions
    numelem=size(elem,1);                                                      % [#]  : number of elements
    idxnode=floor(interp1(pts.R,1:length(pts.R),pyth(node),'linear',length(pts.R)));  % [@]  : region indices for the nodes
    idxelem=floor(mean([ idxnode(elem(:,1),1) idxnode(elem(:,2),1) idxnode(elem(:,3),1) ],2));
  end
end
if plotflag
  trimesh(elem(:,1:3),node(:,1),node(:,2)); axis equal;                    % plot the mesh
end

%% Z. Change femmdata
femmdata=read_femmdata(finfilename);                                       % read the original .ans file
femmdata.node=[ node zeros(size(node,1),1) ];
femmdata.elem=[ elem idxelem ];
femmdata=mesh_flip_negative_elements(femmdata);                            % flip element with negative area
femmdata.elem(:,1:4)=femmdata.elem(:,1:4)-1;                               % adapt the indices (from 0 to numnode-1)
save_femmdata(femmdata,foutfilename);                                      % save to the new .ans file
