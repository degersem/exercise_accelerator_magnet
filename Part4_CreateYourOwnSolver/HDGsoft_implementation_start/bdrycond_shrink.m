function [Abcs,gbcs] = bdrycond_shrink(bdrycond,idxdof,Afem,gfem,insert_dirichlet)

% function [Abcs,gbcs] = bdrycond_shrink(bdrycond,idxdof,Afem,gfem,insert_dirichlet)
%   inserts the boundary conditions and shrinks the system of equations and righthandside
%
% Inputs
%    bdrycond           :       : data for boundary conditions (BCs)
%    idxdof             : [@]   : indices of the degrees of freedom           (optional; default: [])
%    Afem               : [1/H] : unconstrained FE matrix                     (optional; default: [])
%    gfem               : [A]   : unconstrained righthandside vector          (optional; default: [])
%    insert_dirichlet   : [1/0] : insert nonhomogeneous Dirichlet data or not (optional; default: 1)
%
% Outputs
%    Abcs               : [1/H] : constrained and shrinked FE matrix
%    gbcs               : [A]   : constrained and shrinked righthandside vector
%
% Note
%    "unary" boundary conditions are assigned to nodes (e.g. Dirichlet/Neumann/Robin boundary conditions
%    "binary" boundary conditions connect nodes (e.g. (anti-)periodic boundary conditions and air-gap interface conditions
%    be aware of the fact that the order of applying the boundary/interface conditions should be respected the projectors implementing the boundary conditions do not commute!
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

% A. Initialisation
if ~exist('insert_dirichlet','var')
  insert_dirichlet=1;
end
if ~exist('gfem','var')
  gfem=[];
  insert_dirichlet=1;
end
Abcs=Afem;
gbcs=gfem;

% B. (First!) Binary interface/boundary conditions
allidxslv=[];
allidxmst=[];
for bd=1:length(bdrycond)
  switch bdrycond(bd).type
    case 'dirichlet'
    case 'sibc'
    case 'robin'
    case 'airgap'
    case {'periodic','antiperiodic'}
      X=bdrycond(bd).X;
      idxslv=bdrycond(bd).idx(:,1);
      idxmst=bdrycond(bd).idx(:,2);
      if ~isempty(Afem)
        Abcs(:,idxmst)=Abcs(:,idxmst)+Abcs(:,idxslv)*X;
        Abcs(idxmst,:)=Abcs(idxmst,:)+X'*Abcs(idxslv,:);
      end
      if ~isempty(gfem)
        gbcs(idxmst,:)=gbcs(idxmst,:)+X'*gbcs(idxslv,:);
      end
      allidxslv=[allidxslv; idxslv];
      allidxmst=[allidxmst; idxmst];
    case 'dummy'
    otherwise
      error('Unknown boundary condition %s\n',bdrycond(bd).type);
  end
end
% if length(allidxslv)~=length(unique(allidxslv))
%   error('yyy');
% end
% if length(allidxmst)~=length(unique(allidxmst))
%   error('zzz');
% end
% if ~isempty(intersect(allidxslv,allidxmst))
%   error('aaa');
% end

% C. (Secondly!) Air-gap interface conditions
for bd=1:length(bdrycond)
  if strcmp(bdrycond(bd).type,'airgap')
    X=bdrycond(bd).airgap.R;
    idxslv=bdrycond(bd).idx(:,1);
    idxmst=bdrycond(bd).idx(:,2);
    if ~isempty(Afem)
      Abcs(:,idxmst)=Abcs(:,idxmst)+Abcs(:,idxslv)*X;
      Abcs(idxmst,:)=Abcs(idxmst,:)+X'*Abcs(idxslv,:);
    end
    if ~isempty(gfem)
      gbcs(idxmst,:)=gbcs(idxmst,:)+X'*gbcs(idxslv,:);
    end
  end
end

% D. (Thirdly!) Unary boundary conditions
if insert_dirichlet
  for bd=1:length(bdrycond)
    switch bdrycond(bd).type
      case 'dirichlet'
        if ~isempty(gfem)
          gbcs=gbcs-Abcs(:,bdrycond(bd).idx)*bdrycond(bd).data;            % [A]    : load vector after inserting of the boundary excitations
        end
      case 'sibc'
      case 'robin'
      case 'airgap'
      case {'periodic','antiperiodic'}
    end
  end
end

% E. Shrink
if ~isempty(Afem)
  Abcs=Abcs(idxdof,idxdof);                                                % [A/Wb] : reduce the reluctance matrix up to the degrees of freedom
end
if size(gfem,1)~=0
  gbcs=gbcs(idxdof,:);                                                     % [A]    : reduce the applied current vector up to the degrees of freedom
end
