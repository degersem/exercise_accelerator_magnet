function u2 = bdrycond_applyP(bdrycond,u1,insert_dirichlet)
% function u2 = bdrycond_applyP(bdrycond,u1,insert_dirichlet)
%   applies the boundary conditions to u1 resulting in u2 this corresponds to u2=P*u1 where P is a projector applying the boundary conditions
%
% Inputs
%    bdrycond           :       : data for boundary conditions (BCs)
%    u1                 : [Wb]  : field vector
%    insert_dirichlet   : [1/0] : insert nonhomogeneous Dirichlet data or not (optional; default: 1)
%
% Outputs
%    u2                 : [Wb]  : field vector obeying the boundary conditions
%
% Note
%    "unary" boundary conditions are assigned to nodes (e.g. Dirichlet/Neumann/Robin boundary conditions
%    "binary" boundary conditions connect nodes (e.g. (anti-)periodic boundary conditions and air-gap interface conditions
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

if ~exist('insert_dirichlet','var')
  insert_dirichlet=1;
end

% A. Deal with the possibility of the simultaneous applying of the projector to a multi-column solution
if size(u1,2)>1
  for q=1:size(u1,2)
    u2(:,q)=bdrycond_applyP(bdrycond,u1(:,q),insert_dirichlet);
  end
  return;
end

% A. Initialise
u2=u1;                                                                     % [Wb]   : field vector

% B. (First!) Inflate for the unary boundary conditions
for bd=1:length(bdrycond)
  switch bdrycond(bd).type
    case 'dirichlet'
      if insert_dirichlet
        u2(bdrycond(bd).idx,1)=bdrycond(bd).data;                          % [Wb]   : insert the Dirichlet boundary conditions
      end
    case 'sibc'
    case 'robin'
    case {'airgap','periodic','antiperiodic'}
    case 'dummy'
    otherwise
      error('Unknown boundary condition %s\n',bdrycond(bd).type);
  end
end

% C. (Second!) Inflate for the air-gap interface conditions
for bd=1:length(bdrycond)
  if strcmp(bdrycond(bd).type,'airgap')
    idxslv=bdrycond(bd).idx(:,1);
    idxmst=bdrycond(bd).idx(:,2);
    u2(idxslv,1)=bdrycond(bd).airgap.R*u2(idxmst,1);
  end
end

% D. (Third!) Inflate for the (anti-)periodic boundary conditions
for bd=1:length(bdrycond)
  switch bdrycond(bd).type
    case 'dirichlet'
    case 'sibc'
    case 'robin'
    case 'airgap'
    case {'periodic','antiperiodic'}
      idxslv=bdrycond(bd).idx(:,1);
      idxmst=bdrycond(bd).idx(:,2);
      u2(idxslv,1)=bdrycond(bd).X*u2(idxmst,1);
  end

end
