function ffem = charge_load(mesh,elemrho,edgerho)
% function ffem = CHARGE_LOAD(mesh,elemrho,edgerho)
%   returns the righthandside vector for a set of element-wise constant charge densities
%
% Inputs
%    mesh       :         : 2D FE mesh
%    elemrho    : [C/m^3] : element-wise constant charge densities (optional; default: [])
%    edgerho    : [C/m^2] : edge-wise constant surface charge densities (optional; default: [])
%
% Outputs
%    ffem       : [C]     : righthandside vector
%
% See also
%  divgrad, curlcurl, curlcurl_nonlinear
%
% Author
%   Herbert De Gersem

%% A. Parameter check
if ~exist('elemrho','var')
  elemrho=[];
end
if ~exist('edgerho','var')
  edgerho=[];
end

%% B. Initialisation
numnode=size(mesh.node,1);                                                 % [#]   : number of FE nodes
ffem=zeros(numnode,1);

%% C. Contributions from volumetric charge densities
if ~isempty(elemrho)
  numelem=size(mesh.elem,1);                                               % [#]   : number of FE elements
  if size(elemrho,1)~=numelem
    error('Usage: ffem=charge_load(mesh,prb_block2elem(prb,blockrho))');
  end
  for k=1:numelem
    idx=mesh.elem(k,1:3);
    ffem(idx,:)=ffem(idx,:)+elemrho(k,1)*mesh.lz*mesh.area(k)/3;  
  end
end

%% D. Contributions from surface charge densities
if ~isempty(edgerho)
  numedge=size(mesh.edge,1);                                               % [#]   : number of mesh edges
  if size(edgerho,1)~=numedge
    error('edgerho should have numedge entries');
  end
  ed=find(edgerho~=0);
  nd1=mesh.edge(ed,1);
  nd2=mesh.edge(ed,2);
  edgelength=pyth(mesh.node(nd1,1:2)-mesh.node(nd2,1:2));
  v=edgerho(ed,1).*edgelength/2*mesh.lz;
  ffem(nd1,1)=ffem(nd1,1)+v;
  ffem(nd2,1)=ffem(nd2,1)+v;
end

