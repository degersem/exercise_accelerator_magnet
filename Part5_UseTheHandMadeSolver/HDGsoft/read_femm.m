function prb=read_femm(finfilename,extend_FEdata,plotflag,symmetry_info,tol,addinfo)

% function prb=READ_FEMM(finfilename,extend_FEdata,plotflag)
% reads a FEMM-formatted .fem or .ans file into a FE-prb structure
%
% input parameters
%     finfilename           : filename or file pointer
%     extend_FEdata         : 1/0 : extend the FE data structures (optional; default: 1)
%     plotflag              : 1/0 : (optional; default: 0)
%     symmetry_info         : extra information about the symmetry (optional; default: the symmetry specified in the FEMM file)
%         type              : 'planar', 'axisymmetric' or 'radialsymmetric'
%         --- if planar          ---
%         --- if axisymmetric    ---
%         --- if radialsymmetric ---
%             r1                : [m] : inner radius of the radialsymmetric model
%             r2                : [m] : outer radius of the radialsymmetric model
%             rvis              : [m] : visualization radius of the radialsymmetric model
%     tol                   : []  : tolerances, especially for tracing mesh and geometry entries (optional; default values listed below)
%         mesh_connect_geometry   : []   : default 1e-4 : tolerance for connecting mesh and geometry
%         airgap_introduce_cut    : []   : default 1e-4 : tolerance for finding an air-gap interface
%     addinfo               : additional modelling information
%         isatrotorside         :     : function to indicate whether a coordinate is at the rotor side or not

% output parameters
%     prb            : FE-problem structure
%
% see also SAVE_FEMM
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

% A. Parameter control
if ~exist('extend_FEdata','var')
  extend_FEdata=1;
end
if ~exist('plotflag','var')
  plotflag=0;
end
if ~exist('symmetry_info','var')
  symmetry_info=[];
end
if ~exist('tol','var')
  tol=struct;
end
if ~isfield(tol,'mesh_connect_geometry')
  tol.mesh_connect_geometry=1e-4;                % []   : default 1e-4 : tolerance for connecting mesh and geometry
end
if ~isfield(tol,'airgap_introduce_cut')
  tol.airgap_introduce_cut=1e-4;                 % []   : default 1e-4 : tolerance for finding an air-gap interface
end
if ~exist('addinfo','var')
  addinfo=struct('isatrotorside',[]);
end

% B. Read FEMM data file
femmdata=read_femmdata(finfilename);

% C. Adapt indices
%Explanation for adapting the indices: Matlab works from 1 to N, while C++
%works from 0 to N-1
%
femmdata.elem=femmdata.elem+1;
femmdata.segments(:,1:2)=femmdata.segments(:,1:2)+1;
femmdata.arcsegments(:,1:2)=femmdata.arcsegments(:,1:2)+1;

% D. Scale lengths
switch femmdata.LengthUnits
  case 'meters'
    lfac=1;
  case 'centimeters'
    lfac=100;
  case 'millimeters'
    lfac=1000;
  otherwise
    error('unit %s not known\n',femmdata.LengthUnits);
end
femmdata.points(:,1:2)=femmdata.points(:,1:2)/lfac;
femmdata.blocklabels(:,1:2)=femmdata.blocklabels(:,1:2)/lfac;
femmdata.blocklabels(:,6)=femmdata.blocklabels(:,6)/180*pi;                % conversion from degrees to radians (magnetisation angles)
femmdata.Depth=femmdata.Depth/lfac;
femmdata.node(:,1:2)=femmdata.node(:,1:2)/lfac;

% E. General problem information
% E.1. Formulation
physics_type=determine_physics_type(finfilename);
% E.2. Frequency
if isfield(femmdata,'Frequency')
  f=sscanf(femmdata.Frequency,'%d');
else
  f=0;
end
% E.3. Symmetry type
% HDG: on the mid term, get rid of mesh.lz and mesh.shape_function_type
if isempty(symmetry_info)
  switch femmdata.ProblemType
    case 'planar'
      symmetry_info=struct('type','planar','extent',[0 femmdata.Depth],'shape_function_type','linear');
      lz=femmdata.Depth;
      shape_function_type='linear';
    case 'axisymmetric'
      symmetry_info=struct('type','axisymmetric','extent',[-pi pi],'shape_function_type','linear');
      lz=0;
      shape_function_type='axicurl';
    otherwise
      error('ProblemType %s not supported by FEMM',femmdata.ProblemType);
  end
end
switch symmetry_info.type
  case 'planar'
  case 'axisymmetric'
  case 'radialsymmetric'
    lz=diff(symmetry_info.extent);                                         % [m]   : radial length
    shape_function_type='radialcurl';                                      % shape_function
    if ~isfield(symmetry_info,'rvis')
      symmetry_info.rvis=mean(symmetry_info.extent);                       % [m]   : radius for visualisation and for reference
    end
    femmdata.ProblemType='radialsymmetric';
    femmdata.Depth=lz;
end

% E. Adapt solution and scale geometry/mesh
switch symmetry_info.type
  case 'planar'            % FEMM stores Az in the case of planar symmetry
    femmdata.node(:,3)=femmdata.node(:,3).*femmdata.Depth;
  case 'axisymmetric'      % FEMM stores 2*pi*r*Atheta
    % do nothing
  case 'radialsymmetric'   % FEMM stores Ar in the case or radial symmetry
    femmdata.node(:,3)=femmdata.node(:,3).*femmdata.Depth;
    rvis=symmetry_info.rvis;                                               % [m]  : radius for visualisation and for reference
    femmdata.points(:,1)=femmdata.points(:,1)/rvis;                        % converting the perimeter coordinates into theta coordinates
    femmdata.blocklabels(:,1)=femmdata.blocklabels(:,1)/rvis;              % converting the perimeter coordinates into theta coordinates
    femmdata.node(:,1)=femmdata.node(:,1)/rvis;                            % converting the perimeter coordinates into theta coordinates
end

% % G. Find the boundary nodes (obsolete, replaced by the bdrycond data structure)
% prb.idxdir=find(prb.node(:,3)==0);                                       % []     : indices of the Dirichlet constraints (HDG: dangerous)
% prb.idxdof=setdiff(1:prb.numnode,prb.idxdir);                            % []     : indices of the degrees of freedom
% prb.numdof=length(prb.idxdof);                                           % [#]    : number of degrees of freedom

% I. Initialise the problem data structures
%prb.idxelem=prb.blocklabels(prb.elem(:,4),3);                             % indices of the regions
frm=struct('physics_type',physics_type,'frequency',f);                     % [Hz]   : frequency
para=[];                                                                   %        : parameters
mtl=material_initialise_from_femmdata(femmdata,physics_type);              %        : materials
rgn=femmdata.blocklabels;                                                  %        : regions
wrs=wire_initialise_from_femmdata(femmdata);                               %        : wires  ?? electric circuits?
switch physics_type
  case 'magnetic'
    wrs=wire_initialise_from_femmdata(femmdata);                           %        : wires
  case 'electric'
    wrs=[];
  case 'thermal'
  case 'electrokinetic'
end
bcs=bdrycond_initialise_from_femmdata(femmdata);                           %        : initialise the boundary-conditions data structure
gmy=struct('points',femmdata.points,'segments',femmdata.segments,'arcsegments',femmdata.arcsegments);           % geometry
[gmy,wrs,bcs]=wire_bdrycond_initialise_from_pointprop(femmdata,gmy,wrs,bcs);

% HDG: on the mid term, get rid of symmetry_type and lz
msh=struct('original_unit',femmdata.LengthUnits,'symmetry_info',symmetry_info,'symmetry_type',femmdata.ProblemType,...
 'depth',femmdata.Depth,'lz',lz,'node',femmdata.node,'elem',femmdata.elem);          %        : mesh 

% I. Extend the FEMM data structures
if extend_FEdata
  gmy=geometry_extend_info(gmy);                                           %        : extend the geometrical information
  msh=mesh_add_edge_data(msh);                                             %        : add edge data (needed for mesh refinement)
  repair_arcs=1;                                                           % [1/0]  : repair arcs (shift refinement nodes on the arc segments)
  msh=mesh_connect_geometry(msh,gmy,repair_arcs,tol.mesh_connect_geometry,plotflag); %        : add connection to geometry information (needed for shape reconstruction while mesh refining)
  [bcs,gmy]=bdrycond_treat_binaries(bcs,gmy,plotflag);                     %        : detect slave and master sides of binary BCs
%  [bcs,msh,gmy]=airgap_introduce_cut(bcs,msh,gmy,tol.airgap_introduce_cut,addinfo,1); % introduce an air-gap cut (for air-gap interface conditions)
  gmy=geometry_propagate_bdrycond_segment2point(gmy,bcs,plotflag);         %        : propagate BC information from line/arc segments to points, account for priority rules
end
msh=mesh_linear_shape_functions(msh,shape_function_type);                  %        : add information for linear shape functions

% K. Combine everything in the problem data structure
prb=struct('formulation',frm,'para',para,'material',mtl,'region',rgn,'wire',wrs,'bdrycond',bcs,'geometry',gmy,'mesh',msh);

% blocklabels (region) data
% for rg=1:size(rgn,1)
%   fprintf('Region %d\n',rg);
%   fprintf('    1,2   : coordinate               : (%13.6e,%13.6e) m\n',rgn(rg,1),rgn(rg,2));
%   fprintf('    3     : material identifier      : %d\n',rgn(rg,3));
%   fprintf('    4     :\n');
%   fprintf('    5     : conductor identifier     : %d\n',rgn(rg,5));
%   fprintf('    6     :\n');
%   fprintf('    7     :\n');
%   fprintf('    8     : number of turns          : %d\n',rgn(rg,8));
%   fprintf('    9     :\n');
%   fprintf('    10    :\n');
% end

% % B.4. Find the wires (HDG: obsolete since "circuits" in FEMM)
% clear wire;
% wr=0; proceed=1;
% idxinsulation=idxdof;                                         % []     : indices of the nodes strictly inside the insulation material
% Qwirelist=zeros(0,3);
% while proceed
%   wr=wr+1;
%   lb=sprintf('W%d',wr);                                       % []     : label
%   rg=findlab(regilab,lb);                                     % []     : associated region number
%   if ~isnan(rg)
%     wire(wr).label=lb;                                        % []     : wire label
%     wire(wr).rg=rg;                                           % []     : region number
%     wire(wr).k=find(idxelem==rg);                             % []     : indices of the elements inside the wire
%     kconj=setdiff(1:numelem,wire(wr).k);                      % []     : indices of the elements outside the wire
%     wire(wr).i=unique(prb.elem(wire(wr).k,1:3));              % []     : indices of the nodes at the wire cross-section
%     wire(wr).itld=intersect(wire(wr).i,unique(prb.elem(kconj,1:3))); % [] : indices of the nodes at the wire surface
%     idxinsulation=setdiff(idxinsulation,wire(wr).i);          % []     : remove the indices of the nodes of the wire
%     numnid=length(wire(wr).i);
%     E=ones(numnid,1);
%     regicond(rg)=sigmaCu;
%     Qwirelist=[Qwirelist; wire(wr).i wr*E E];
%     if plotflag
%       figure(3); clf; plot(prb.node(wire(wr).i,1),prb.node(wire(wr).i,2),'x');
%       hold on; plot(prb.node(wire(wr).itld,1),prb.node(wire(wr).itld,2),'rx');
%       axis equal; xlabel('x (m)'); ylabel('y (m)'); title(sprintf('nodes at the surface of wire %s',wire(wr).label));
%     end
%   else
%     proceed=0;
%   end
% end
% numwire=wr-1;                                                 % [#]    : number of wires
% Qwire=sparse(Qwirelist(:,1),Qwirelist(:,2),Qwirelist(:,3),numnode,numwire); % []     : wire connection matrix
% Qwirered=Qwire(idxdof,:);                                     % []     : reduced wire connection matrix
% Xstr=sparse([wire.rg],1:numwire,ones(numwire,1));             % []     : connection matrix
% Pstr=current_Pstr(prb,Xstr);                                  % []     : stranded-conductor coupling block
% Pstrred=Pstr(idxdof,:);                                       % []     : reduce the stranded-conductor coupling block up to the degrees of freedom
